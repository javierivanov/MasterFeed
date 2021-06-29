//
//  FollowingsResponse.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 13-05-21.
//

import Foundation

struct TwitterUser: Codable {
    var description: String
    var username: String
    var name: String
    var verified: Bool
    var url: String
    var id: String
    var profile_image_url: String
}



struct FollowingsResponse: Codable {
    var data: [TwitterUser]
    var meta: Meta?
}
