//
//  SearchResponse.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 02-08-21.
//

import Foundation



struct SearchResponse: Codable {
    var id: Int
    var id_str: String
    var name: String
    var screen_name: String
    var verified: Bool
    var followers_count: Int
    var profile_image_url_https: String
}
