//
//  Meta.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 13-05-21.
//

import Foundation


struct Meta: Codable {
    var result_count: Int
    var previous_token: String?
    var next_token: String?
    var oldest_id: String?
    var newest_id: String?
}
