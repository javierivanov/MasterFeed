//
//  User.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 09-05-21.
//

import Foundation
import OAuthSwift



// MARK: - UserAccount

struct UserAccount {

    // MARK: - UserCredentials
    struct Credentials {
        var token: String
        var secret: String
    }
    
    var credentials: Credentials
    var client: OAuthSwiftClient
    var username: String
    var user_id: String
    var user_pic: URL?
    
    
    var userStorable: UserAccountStorable {
        get {
            UserAccountStorable(token: credentials.token,
                                username: username,
                                user_id: user_id,
                                user_pic: user_pic?.absoluteString)
        }
    }
}

// MARK: - UserAccount for UserDefauls storage
struct UserAccountStorable: Codable {
    var token: String // maybe not
    var username: String
    var user_id: String
    var user_pic: String?
    
    func buildUserAccount(credentials: UserAccount.Credentials, client: OAuthSwiftClient) -> UserAccount {
        UserAccount(credentials: credentials,
                                client: client,
                                username: username,
                                user_id: user_id,
                                user_pic: user_pic != nil ? URL(string: user_pic!) : nil)
    }
    
}
