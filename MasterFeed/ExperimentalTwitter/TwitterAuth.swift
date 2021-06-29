//
//  TwitterAuth.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 07-05-21.
//
//
//import Foundation
//import OAuthSwift
//import Security
//
//class TwitterAuth: ObservableObject {
//    
//    enum UserStatus {
//        case logged
//        case notLogged
//        case expired
//        case waiting
//    }
//    
//    @Published var authUrl: URL?
//    @Published var showSheet: Bool = false
//    @Published var userLogged: UserStatus = .waiting
//    
//    
//    var oAuth: OAuth1Swift?
//    var client: OAuthSwiftClient?
//    
////    init() {
////        self.resetOAuth()
//        
////        client = OAuthSwiftClient(consumerKey: TWITTER_CONSUMER_KEY,
////                                  consumerSecret: TWITTER_CONSUMER_SECRET,
////                                  oauthToken: TWITTER_TOKEN,
////                                  oauthTokenSecret: TWITTER_TOKEN_SECRET,
////                                  version: .oauth1)
//        
////    }
//    
////    func checkUserAuthentication() {
////        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
////                                    kSecMatchLimit as String: kSecMatchLimitOne,
////                                    kSecReturnAttributes as String: true,
////                                    kSecReturnData as String: true]
////        var item: CFTypeRef?
////        let status = SecItemCopyMatching(query as CFDictionary, &item)
////        guard status == errSecItemNotFound else {
////            return
////        }
////        guard status == errSecSuccess else {return}
////        
////        guard let existingItem = item as? [String : Any],
////            let passwordData = existingItem[kSecValueData as String] as? Data,
////            let secret = String(data: passwordData, encoding: String.Encoding.utf8),
////            let token = existingItem[kSecAttrAccount as String] as? String
////        else {
////            return
////        }
////        
////        //        client = OAuthSwiftClient(consumerKey: TWITTER_CONSUMER_KEY,
////        //                                  consumerSecret: TWITTER_CONSUMER_SECRET,
////        //                                  oauthToken: TWITTER_TOKEN,
////        //                                  oauthTokenSecret: TWITTER_TOKEN_SECRET,
////        //                                  version: .oauth1)
////        
////    }
//    
//    func resetOAuth() {
//        self.oAuth = OAuth1Swift(
//            consumerKey:    TWITTER_CONSUMER_KEY,
//            consumerSecret: TWITTER_CONSUMER_SECRET,
//            requestTokenUrl: "https://api.twitter.com/oauth/request_token",
//            authorizeUrl:    "https://api.twitter.com/oauth/authorize",
//            accessTokenUrl:  "https://api.twitter.com/oauth/access_token")
//    }
//    
//    func authorize() {
//        DispatchQueue.global(qos: .userInteractive).async { [self] in
//            defer {startAuthorization()}
//            resetOAuth()
//        }
//    }
//    
//    
//    func startAuthorization() {
//        
//        DispatchQueue.main.async {
//            self.showSheet = true
//        }
//        guard let oAuth = oAuth else {return}
//        oAuth.authorize(withCallbackURL: "twitterclient://") { result in
//            switch result {
//            case .success(let (credential, response, _)):
//                print(credential)
//                let responseDict:[String: String] = response?.dataString()?
//                    .split(separator: "&")
//                    .map {$0.split(separator: "=")}
//                    .map {($0.first, $0.last)}
//                    .reduce([:]) {prev, res in
//                        var prevNew = prev
//                        prevNew?[String(res.0!)] = String(res.1!)
//                        return prevNew
//                    } as! [String : String]
//                print(responseDict)
//                DispatchQueue.main.async {
//                    self.showSheet = false
//                }
//                
//            case .failure(let error):
//                print(error)
//                DispatchQueue.main.async {
//                    self.showSheet = false
//                }
//                self.oAuth = nil
//            }
//        }
//        
//        oAuth.authorizeURLHandler = OAuthSwiftURLHandler(self)
//        
//    }
//    
//    final class OAuthSwiftURLHandler: OAuthSwiftURLHandlerType {
//        
//        let oAuthParent: TwitterAuth
//        
//        init(_ parent: TwitterAuth) {
//            oAuthParent = parent
//        }
//        
//        func handle(_ url: URL) {
//            oAuthParent.authUrl = url
////            print("url: \(url)")
//        }
//    }
//    
//}

