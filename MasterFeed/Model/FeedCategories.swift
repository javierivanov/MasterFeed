//
//  FeedCategories.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 12-06-21.
//

import Foundation


struct SchemaExtraction: Codable {
    
    enum SchemaExtractionKeys: String, CodingKey {
        case articleSection, genre, keywords
    }
    
    var articleSection: String?
    var genre: String?
    var keywords: [String]?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: SchemaExtractionKeys.self)
        articleSection = try? values.decode(String.self, forKey: .articleSection).lowercased().split(separator: " ").last?.description
        genre = try? values.decode(String.self, forKey: .genre).lowercased().split(separator: " ").last?.description
        keywords = try? values.decode([String].self, forKey: .keywords).map(\.localizedLowercase)
    }
    
}



