//
//  UserAuthorization.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 09-05-21.
//

import Foundation
import OAuthSwift


let TWITTER_CONSUMER_KEY = (Bundle.main.infoDictionary?["TWITTER_CONSUMER_KEY"] as? String) ?? ""
let TWITTER_CONSUMER_SECRET = (Bundle.main.infoDictionary?["TWITTER_CONSUMER_SECRET"] as? String) ?? ""
let TWITTER_URL_SCHEME = "twitterclient://"


// MARK: - UserAuthorization
class UserAuthorization: ObservableObject {
    @Published var authUrl: URL?
    @Published var displayLogin: Bool = false
    
    private(set) var oAuth: OAuth1Swift?
}


// MARK: - Token Generation

extension UserAuthorization: OAuthSwiftURLHandlerType {
    func handle(_ url: URL) {
        DispatchQueue.main.async {
            self.authUrl = url
        }
    }
    
    func tokenGeneration(feedModel: FeedModel) {
        
        DispatchQueue.main.async {
            self.displayLogin = true
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.oAuth = OAuth1Swift(
                consumerKey:    TWITTER_CONSUMER_KEY,
                consumerSecret: TWITTER_CONSUMER_SECRET,
                requestTokenUrl: "https://api.twitter.com/oauth/request_token",
                authorizeUrl:    "https://api.twitter.com/oauth/authorize",
                accessTokenUrl:  "https://api.twitter.com/oauth/access_token")
            self.oAuth?.authorizeURLHandler = self
            self.authorize(feedModel: feedModel)
        }
    }
}


// MARK: - Authorization

extension UserAuthorization {
    func authorize(feedModel: FeedModel) {
        guard oAuth != nil else {
            DispatchQueue.main.async {
                self.displayLogin = false
            }
            return
        }
        oAuth?.authorize(withCallbackURL: TWITTER_URL_SCHEME) { result in
            
            // Turn off display for login view, not needed after a completion received.
            DispatchQueue.main.async {
                feedModel.state = .preparing
                self.displayLogin = false
            }
   
            let newResult = result
                .mapError { error -> UserError in
                    return UserError.errorCode(code: error.errorCode, description: error.description)
                }.flatMap { (_, response, _) -> Result<UserAccount, UserError> in
                    
                    guard let response = response else { return Result.failure(UserError.malformedDict) }
                    
                    let responseDict = self.buildResponseDict(response: response)
                    
                    do {
                        return Result.success(try self.buildUserAccount(responseDict: responseDict))
                    } catch UserError.malformedDict {
                        return Result.failure(UserError.malformedDict)
                    } catch {
                        return Result.failure(UserError.unhandledError(error: error))
                    }

                }
            
            feedModel.authorizeUser(newResult)
        }
    }
}

// MARK: - Helper functions
extension UserAuthorization {
    private func buildUserAccount(responseDict: [String: String]) throws -> UserAccount {
        
        //            user_id
        //            oauth_token_secret
        //            oauth_token
        //            screen_name
        
        guard let username = responseDict["screen_name"],
              let user_id = responseDict["user_id"],
              let token = responseDict["oauth_token"],
              let secret = responseDict["oauth_token_secret"] else {
            throw UserError.malformedDict
        }
        let client = OAuthSwiftClient(consumerKey: TWITTER_CONSUMER_KEY,
                                consumerSecret: TWITTER_CONSUMER_SECRET,
                                oauthToken: token,
                                oauthTokenSecret: secret,
                                version: .oauth1)
        let credentials = UserAccount.Credentials(token: token, secret: secret)
        return UserAccount(credentials: credentials, client: client, username: username, user_id: user_id, user_pic: nil)
    }
    
    private func buildResponseDict(response: OAuthSwiftResponse) -> [String: String] {
        return response.dataString()?
            .split(separator: "&")
            .map {$0.split(separator: "=")}
            .map {($0.first, $0.last)}
            .reduce([:]) {prev, res in
                var prevNew = prev
                prevNew?[String(res.0!)] = String(res.1!)
                return prevNew
            } as! [String : String]
    }
    
    static func buildUserAccount(credentials: UserAccount.Credentials) -> OAuthSwiftClient {
        return OAuthSwiftClient(consumerKey: TWITTER_CONSUMER_KEY,
                                consumerSecret: TWITTER_CONSUMER_SECRET,
                                oauthToken: credentials.token,
                                oauthTokenSecret: credentials.secret,
                                version: .oauth1)
    }
}

// MARK: - Secure credentials storage

extension UserAuthorization {
    
    // MARK: - Storing Credentials
    static func storeCredentials(_ credentials: UserAccount.Credentials) throws {
        
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: credentials.token,
                                    kSecValueData as String: credentials.secret.data(using: .utf8)!]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }
    
    
    // MARK: - Loading Credentials
    static func loadCredentials(_ token: String) throws -> UserAccount.Credentials {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true,
                                    kSecAttrAccount as String: token]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        
        guard let existingItem = item as? [String : Any],
            let secretData = existingItem[kSecValueData as String] as? Data,
            let secret = String(data: secretData, encoding: String.Encoding.utf8)
        else {
            throw KeychainError.unexpectedPasswordData
        }
        print("\(token):\(secret)")
        return UserAccount.Credentials(token: token, secret: secret)
        
    }
    // MARK: - Updating Credentials
    static func updateCredentials(_ credentials: UserAccount.Credentials) throws {
        
    }
    
    
}
