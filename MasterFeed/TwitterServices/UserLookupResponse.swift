//
//  UserLookupResponse.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 02-08-21.
//

import Foundation


struct UserLookupResponseData: Codable {
    let data: UserLookupResponse
}


struct UserLookupResponse: Codable {
    var id: String
    var profile_image_url: String
    var name: String
    var username: String
}
