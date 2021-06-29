//
//  TimeLineResponse.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 13-05-21.
//

import Foundation
import UnsupervisedTextClassifier

let dateFormatter = ISO8601DateFormatter()

struct TimeLineResponse : Codable {
    var data: [Tweet]
    var meta: Meta?
}



struct Tweet: Codable, Article, Identifiable {
    
    struct PublicMetrics: Codable {
        var retweet_count: Int
        var reply_count: Int
        var like_count: Int
        var quote_count: Int
                
    }

    
    var id: String
    var text: String?
    var url: URL?
    var keywords: [String]?
    var imageLarge: URL?
    var imageSmall: URL?
    var source: String?
    var textsMap: [[String]]?
    var urlTitle: String?
    var tweetText: String?
    var created_at: Date?
    var metrics: PublicMetrics?
    var context_annotations: [TweetContextAnnotations]?
    var filterKeywords: Set<String>? = []
    var categories: [String] = []
    
    enum TweetCodeKeys: String, CodingKey {
        case id
        case text
        case entities
        case created_at
        case context_annotations
        case public_metrics
    }
    
    
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: TweetCodeKeys.self)
        
        id = try values.decode(String.self, forKey: .id)
        var textInner = try values.decode(String.self, forKey: .text)
        
        let entities = try? values.decode(TweetEntities.self, forKey: .entities)
        
        entities?.urls?.filter {$0.url != nil}.filter {textInner.contains($0.url!)}.forEach { url in
            textInner = NSString(string: textInner).replacingOccurrences(of: url.url!, with: "")
            if let images = url.images?.sorted(by: {$0.width < $1.width}), images.count > 1{
                self.imageSmall = images.first != nil ? URL(string: images.first!.url) : nil
                self.imageLarge = images.last != nil ? URL(string: images.last!.url) : nil
            }

            if let status = url.status, status == 200 {
                self.url = URL(string: url.unwound_url ?? url.url!)
                self.urlTitle = url.title
            }
        }
        
        keywords = entities?.annotations?.map({$0.normalized_text})
        keywords?.forEach {filterKeywords?.insert($0)}
        
        tweetText = textInner.trimmingCharacters(in: [" "])
        urlTitle = urlTitle?.trimmingCharacters(in: [" "])
        
        
        if let urlTitle = urlTitle, urlTitle.isEmpty || urlTitle.split(separator: " ").count <= 3 {
            self.urlTitle = nil
        }
        
        text = urlTitle ?? tweetText
        
        if let text = text, text.isEmpty || text.split(separator: " ").count <= 3 {
            self.text = nil
        }
        
        created_at = dateFormatter.date(from: try values.decode(String.self, forKey: .created_at).replacingOccurrences(of: ".", with: "+"))
        
        metrics = try values.decode(PublicMetrics.self, forKey: .public_metrics)
        context_annotations = try? values.decode([TweetContextAnnotations].self, forKey: .context_annotations)
        
        let mapping: [String: String] = [
            "travel": "Travel",
            "watch": "Video",
            "politics": "Politics",
            "policy": "Politics",
            "senate": "Politics",
            "sports": "Sports",
            "health": "Health",
            "world": "World",
            "international": "World",
            "uk": "UK",
            "us": "US",
            "u.s.": "US",
            "u.k.": "UK",
            "eu": "Europe",
            "europe": "Europe",
            "tech": "Technology",
            "tech-news": "Technology",
            "science": "Technology",
            "china": "World",
            "middle-east": "World",
            "americas": "US",
            "entertainment": "Entertainment",
            "celebrities": "Entertainment",
            "business": "Business",
            "markets": "Business",
            "money": "Business",
            "stock": "Business",
            "opinion": "Opinion",
            "film": "Entertainment",
            "tv": "Entertainment",
            "music": "Entertainment",
            "books": "Entertainment"
        ]
        
        let hostMapping: [String: String] = [
            "twitter.com": "Twitter",
            "youtube.com": "YouTube",
            "youtu.be": "YouTube"
        ]
        
        categories.append(contentsOf: url?.pathComponents.filter({$0 != "/"}).filter { part in mapping.keys.contains(part.lowercased())}.map({mapping[$0, default: "Latest"]}) ?? [])
        categories.append(contentsOf: hostMapping.keys.filter { url?.host?.contains($0) ?? false }.compactMap({hostMapping[$0]}))
        
    }
    
    
}


struct TweetContextAnnotations: Codable {
    struct Domain: Codable {
        var id: String?
        var name: String?
        var description: String?
    }
    struct Entity: Codable {
        var id: String?
        var name: String?
        var description: String?
    }
    
    var domain: Domain?
    var entity: Entity?
    
}

struct TweetEntities: Codable {
    
    struct Image: Codable {
        var url: String
        var width: Int
        var height: Int
    }
    
    struct URL: Codable {
        var start: Int
        var end: Int
        var url: String?
        var expanded_url: String?
        var display_url: String?
        var images: [Image]?
        var status: Int?
        var title: String?
        var description: String?
        var unwound_url: String?
    }

    struct Annotation: Codable {
        var start: Int
        var end: Int
        var probability: Double
        var type: String
        var normalized_text: String
    }
    var urls: [URL]?
    var annotations: [Annotation]?
}



extension Tweet {
    static func removeHighOccurrences(tweets: [Tweet]) -> [Tweet] {
        var tweets = tweets
        struct InnerPos: Hashable, Equatable {
            var str: Substring
            var pos: Int
        }
        
        let prefixes = tweets
            .compactMap(\.text)
            .flatMap({$0.split(separator: " ").enumerated()})
            .reduce(into: [:], {counter, piece in
                counter[InnerPos(str: piece.element, pos: piece.offset), default: 0] += 1
            })
        let suffixes = tweets
            .compactMap(\.text)
            .flatMap({$0.split(separator: " ").reversed().enumerated()})
            .reduce(into: [:], {counter, piece in
                counter[InnerPos(str: piece.element, pos: piece.offset), default: 0] += 1
            })
        
        let notNilCounter = tweets.filter {$0.text != nil}.count
        
        let filteredPrefixes = prefixes.filter { Double($0.value) >= Double(notNilCounter)*0.9 }
        let filteredSuffixes = suffixes.filter { Double($0.value) >= Double(notNilCounter)*0.9 }
        
        if filteredPrefixes.count > 0 {
            tweets = tweets.filter { $0.text != nil}.map { tweet in
                var tweet = tweet
                tweet.text = tweet.text!.split(separator: " ")
                    .enumerated()
                    .map { InnerPos(str: $0.element, pos: $0.offset) }
                    .filter { !filteredPrefixes.keys.contains($0) }
                    .map(\.str)
                    .joined(separator: " ")
                return tweet
            }
        }
        if filteredSuffixes.count > 0 {
            tweets = tweets.filter {$0.text != nil}.map { tweet in
                var tweet = tweet
                tweet.text = tweet.text!.split(separator: " ")
                    .reversed()
                    .enumerated()
                    .map { InnerPos(str: $0.element, pos: $0.offset) }
                    .filter { !filteredSuffixes.keys.contains($0) }
                    .reversed()
                    .map(\.str)
                    .joined(separator: " ")
                return tweet
            }
        }
        return tweets
    }
    
    static func addSourceToTweets(id: String) -> ([Tweet]) -> [Tweet] {
        func mapping(tweets: [Tweet]) -> [Tweet] {
            tweets.map { tweet -> Tweet in
                var newTweet = tweet
                newTweet.source = id
                return newTweet
            }
        }
        return mapping
    }
}

extension Tweet {
    static func filterNil(tweets: [Tweet]) -> [Tweet] {
        tweets.filter { tweet in
            return tweet.url != nil && tweet.text != nil && !tweet.text!.isEmpty
        }
    }
}

extension Tweet {
    
    func domains(from categories: Categories) -> [String] {
        Set(context_annotations?.compactMap { annotation -> String? in
            let token = annotation.domain?.id ?? "0"
            return categories.categories[token]
        } ?? []).sorted()
    }
    
    func entities() -> [String] {
        Set(context_annotations?.compactMap { annotation -> String? in
            if source?.contains(annotation.entity?.name ?? "") ?? false {
                return nil
            }
            return annotation.entity?.name
        } ?? []).sorted()
    }
    
    
}
