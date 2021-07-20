////
////  TimeLineResponseV2.swift
////  MasterFeed
////
////  Created by Javier Fuentes on 12-07-21.
////
//
//// This file was generated from JSON Schema using quicktype, do not modify it directly.
//// To parse the JSON, add this file to your project and do:
////
////   let twitterCategories = try? newJSONDecoder().decode(TwitterCategories.self, from: jsonData)
//
////
//// Hashable or Equatable:
//// The compiler will not be able to synthesize the implementation of Hashable or Equatable
//// for types that require the use of JSONAny, nor will the implementation of Hashable be
//// synthesized for types that have collections (such as arrays or dictionaries).
//
//import Foundation
//import UnsupervisedTextClassifier
//
//let ISODateFormatter = ISO8601DateFormatter()
//
//
//// MARK: - Tweet
//struct Tweet: Codable, Hashable, Article {
//    // Article
//    var keywords: [String]?
//    var url: URL?
//    // Tweet data extraction
//    var entities: TweetEntities?
//    var publicMetrics: TweetPublicMetrics?
//    var id: String?
//    var text: String?
//    var contextAnnotations: [TweetContextAnnotation]?
//    var createdAt: Date?
//
//    // Tweet data added
//    var image: URL? {
//        guard let _image = _image else { return nil }
//        return URL(string: _image)
//    }
//    fileprivate var _image: String?
//    var urlText: String?
//
//    var categories: [String] = []
//    var filterKeywords: Set<String>? = []
//    var source: String?
//
//    enum CodingKeys: String, CodingKey {
//        case entities = "entities"
//        case publicMetrics = "public_metrics"
//        case id = "id"
//        case text = "text"
//        case contextAnnotations = "context_annotations"
//        case createdAt = "created_at"
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        id = try values.decode(String.self, forKey: .id)
//        var tweetText = try values.decode(String.self, forKey: .text)
//        var urlText: String?
//        let entities = try? values.decode(TweetEntities.self, forKey: .entities)
//
//        entities?.urls?.filter {$0.url != nil}.filter {tweetText.contains($0.url!)}.forEach { url in
//            tweetText = NSString(string: tweetText).replacingOccurrences(of: url.url!, with: "")
//            if let images = url.images?.sorted(by: {$0.width < $1.width}), images.count > 1{
//                self._image = images.last?.url
//            }
////            if self.url == nil && url.unwoundurl != nil || url.expandedurl != nil {
////                self.url = URL(string: url.expandedurl ?? url.unwoundurl ?? url.url!)
////            }
////            if self.urlText == nil && url.title != nil {
////                self.urlText = url.title
////            }
//
//            if let status = url.status, status == 200 {
//                self.url = URL(string: url.unwoundurl ?? url.url!)
//                self.urlText = url.title
//            }
//
//        }
//        keywords = entities?.annotations?.compactMap(\.normalizedText)
//        keywords?.forEach {filterKeywords?.insert($0)}
//
//
//        tweetText = tweetText.trimmingCharacters(in: [" "])
//        urlText = urlText?.trimmingCharacters(in: [" "])
//        self.urlText = urlText
//
//        if let urlTitle = urlText, urlTitle.isEmpty || urlTitle.split(separator: " ").count <= 3 {
//            self.urlText = nil
//        }
//
//        text = urlText ?? tweetText
//
//        if let text = text, text.isEmpty || text.split(separator: " ").count <= 3 {
//            self.text = nil
//        }
//
//        createdAt = ISODateFormatter
//            .date(from: try values.decode(String.self, forKey: .createdAt)
//                    .replacingOccurrences(of: ".", with: "+"))
//        publicMetrics = try? values.decode(TweetPublicMetrics.self, forKey: .publicMetrics)
//        contextAnnotations = try? values.decode([TweetContextAnnotation].self, forKey: .contextAnnotations)
//        let mapping: [String: String] = [
//            "travel": "Travel",
//            "watch": "Video",
//            "politics": "Politics",
//            "policy": "Politics",
//            "senate": "Politics",
//            "sports": "Sports",
//            "health": "Health",
//            "world": "World",
//            "international": "World",
//            "uk": "UK",
//            "us": "US",
//            "u.s.": "US",
//            "u.k.": "UK",
//            "eu": "Europe",
//            "europe": "Europe",
//            "tech": "Technology",
//            "tech-news": "Technology",
//            "science": "Technology",
//            "china": "World",
//            "middle-east": "World",
//            "americas": "US",
//            "entertainment": "Entertainment",
//            "celebrities": "Entertainment",
//            "business": "Business",
//            "markets": "Business",
//            "money": "Business",
//            "stock": "Business",
//            "opinion": "Opinion",
//            "film": "Entertainment",
//            "tv": "Entertainment",
//            "music": "Entertainment",
//            "books": "Entertainment"
//        ]
//
//        let hostMapping: [String: String] = [
//            "twitter.com": "Twitter",
//            "youtube.com": "YouTube",
//            "youtu.be": "YouTube"
//        ]
//
//        categories.append(contentsOf: url?.pathComponents.filter({$0 != "/"}).filter { part in mapping.keys.contains(part.lowercased())}.map({mapping[$0, default: "Latest"]}) ?? [])
//        categories.append(contentsOf: hostMapping.keys.filter { url?.host?.contains($0) ?? false }.compactMap({hostMapping[$0]}))
//    }
//
//}
//
//
////
//// Hashable or Equatable:
//// The compiler will not be able to synthesize the implementation of Hashable or Equatable
//// for types that require the use of JSONAny, nor will the implementation of Hashable be
//// synthesized for types that have collections (such as arrays or dictionaries).
//
//// MARK: - TimeLineResponse
//struct TimeLineResponse: Codable, Hashable {
//    var data: [Tweet]
//    var meta: TimeLineMeta
//
//    enum CodingKeys: String, CodingKey {
//        case data = "data"
//        case meta = "meta"
//    }
//}
//
//
////
//// Hashable or Equatable:
//// The compiler will not be able to synthesize the implementation of Hashable or Equatable
//// for types that require the use of JSONAny, nor will the implementation of Hashable be
//// synthesized for types that have collections (such as arrays or dictionaries).
//
//// MARK: - TweetContextAnnotation
//struct TweetContextAnnotation: Codable, Hashable {
//    var domain: TweetDomain?
//    var entity: TweetDomain?
//
//    enum CodingKeys: String, CodingKey {
//        case domain = "domain"
//        case entity = "entity"
//    }
//}
//
////
//// Hashable or Equatable:
//// The compiler will not be able to synthesize the implementation of Hashable or Equatable
//// for types that require the use of JSONAny, nor will the implementation of Hashable be
//// synthesized for types that have collections (such as arrays or dictionaries).
//
//// MARK: - TweetDomain
//struct TweetDomain: Codable, Hashable {
//    var id: String?
//    var name: String?
//    var domainDescription: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id = "id"
//        case name = "name"
//        case domainDescription = "description"
//    }
//}
//
////
//// Hashable or Equatable:
//// The compiler will not be able to synthesize the implementation of Hashable or Equatable
//// for types that require the use of JSONAny, nor will the implementation of Hashable be
//// synthesized for types that have collections (such as arrays or dictionaries).
//
//// MARK: - TweetEntities
//struct TweetEntities: Codable, Hashable {
//    var annotations: [TweetAnnotation]?
//    var urls: [TweetURL]?
//
//    enum CodingKeys: String, CodingKey {
//        case annotations = "annotations"
//        case urls = "urls"
//    }
//}
//
////
//// Hashable or Equatable:
//// The compiler will not be able to synthesize the implementation of Hashable or Equatable
//// for types that require the use of JSONAny, nor will the implementation of Hashable be
//// synthesized for types that have collections (such as arrays or dictionaries).
//
//// MARK: - TweetAnnotation
//struct TweetAnnotation: Codable, Hashable {
//    var start: Int?
//    var end: Int?
//    var probability: Double?
//    var type: TweetType?
//    var normalizedText: String?
//
//    enum CodingKeys: String, CodingKey {
//        case start = "start"
//        case end = "end"
//        case probability = "probability"
//        case type = "type"
//        case normalizedText = "normalized_text"
//    }
//}
//
//enum TweetType: String, Codable, Hashable {
//    case organization = "Organization"
//    case person = "Person"
//    case place = "Place"
//}
//
////
//// Hashable or Equatable:
//// The compiler will not be able to synthesize the implementation of Hashable or Equatable
//// for types that require the use of JSONAny, nor will the implementation of Hashable be
//// synthesized for types that have collections (such as arrays or dictionaries).
//
//// MARK: - TweetURL
//struct TweetURL: Codable, Hashable {
//    var start: Int
//    var end: Int
//    var url: String?
//    var expandedurl: String?
//    var displayurl: String?
//    var images: [TweetImage]?
//    var status: Int?
//    var title: String?
//    var urlDescription: String?
//    var unwoundurl: String?
//
//    enum CodingKeys: String, CodingKey {
//        case start = "start"
//        case end = "end"
//        case url = "url"
//        case expandedurl = "expanded_url"
//        case displayurl = "display_url"
//        case images = "images"
//        case status = "status"
//        case title = "title"
//        case urlDescription = "description"
//        case unwoundurl = "unwound_url"
//    }
//}
//
////
//// Hashable or Equatable:
//// The compiler will not be able to synthesize the implementation of Hashable or Equatable
//// for types that require the use of JSONAny, nor will the implementation of Hashable be
//// synthesized for types that have collections (such as arrays or dictionaries).
//
//// MARK: - TweetImage
//struct TweetImage: Codable, Hashable {
//    var url: String
//    var width: Int
//    var height: Int
//
//    enum CodingKeys: String, CodingKey {
//        case url = "url"
//        case width = "width"
//        case height = "height"
//    }
//}
//
////
//// Hashable or Equatable:
//// The compiler will not be able to synthesize the implementation of Hashable or Equatable
//// for types that require the use of JSONAny, nor will the implementation of Hashable be
//// synthesized for types that have collections (such as arrays or dictionaries).
//
//// MARK: - TweetPublicMetrics
//struct TweetPublicMetrics: Codable, Hashable {
//    var retweetCount: Int?
//    var replyCount: Int?
//    var likeCount: Int?
//    var quoteCount: Int?
//
//    enum CodingKeys: String, CodingKey {
//        case retweetCount = "retweet_count"
//        case replyCount = "reply_count"
//        case likeCount = "like_count"
//        case quoteCount = "quote_count"
//    }
//}
//
////
//// Hashable or Equatable:
//// The compiler will not be able to synthesize the implementation of Hashable or Equatable
//// for types that require the use of JSONAny, nor will the implementation of Hashable be
//// synthesized for types that have collections (such as arrays or dictionaries).
//
//// MARK: - TimeLineMeta
//struct TimeLineMeta: Codable, Hashable {
//    var oldestid: String?
//    var newestid: String?
//    var resultCount: Int?
//    var nextToken: String?
//
//    enum CodingKeys: String, CodingKey {
//        case oldestid = "oldest_id"
//        case newestid = "newest_id"
//        case resultCount = "result_count"
//        case nextToken = "next_token"
//    }
//}
//
//
//
//extension Tweet {
//
//    static func removeOldOcurrences(tweets: [Tweet]) -> [Tweet] {
//        tweets.filter { tweet in
//            tweet.createdAt?.distance(to: Date()) ?? 0 < 60*60*24*7
//        }
//    }
//
//    static func removeHighOccurrences(tweets: [Tweet]) -> [Tweet] {
//        var tweets = tweets
//        struct InnerPos: Hashable, Equatable {
//            var str: Substring
//            var pos: Int
//        }
//
//        let prefixes = tweets
//            .compactMap(\.text)
//            .flatMap({$0.split(separator: " ").enumerated()})
//            .reduce(into: [:], {counter, piece in
//                counter[InnerPos(str: piece.element, pos: piece.offset), default: 0] += 1
//            })
//        let suffixes = tweets
//            .compactMap(\.text)
//            .flatMap({$0.split(separator: " ").reversed().enumerated()})
//            .reduce(into: [:], {counter, piece in
//                counter[InnerPos(str: piece.element, pos: piece.offset), default: 0] += 1
//            })
//
//        let notNilCounter = tweets.filter {$0.text != nil}.count
//
//        let filteredPrefixes = prefixes.filter { Double($0.value) >= Double(notNilCounter)*0.9 }
//        let filteredSuffixes = suffixes.filter { Double($0.value) >= Double(notNilCounter)*0.9 }
//
//        if filteredPrefixes.count > 0 {
//            tweets = tweets.filter { $0.text != nil}.map { tweet in
//                var tweet = tweet
//                tweet.text = tweet.text!.split(separator: " ")
//                    .enumerated()
//                    .map { InnerPos(str: $0.element, pos: $0.offset) }
//                    .filter { !filteredPrefixes.keys.contains($0) }
//                    .map(\.str)
//                    .joined(separator: " ")
//                return tweet
//            }
//        }
//        if filteredSuffixes.count > 0 {
//            tweets = tweets.filter {$0.text != nil}.map { tweet in
//                var tweet = tweet
//                tweet.text = tweet.text!.split(separator: " ")
//                    .reversed()
//                    .enumerated()
//                    .map { InnerPos(str: $0.element, pos: $0.offset) }
//                    .filter { !filteredSuffixes.keys.contains($0) }
//                    .reversed()
//                    .map(\.str)
//                    .joined(separator: " ")
//                return tweet
//            }
//        }
//        return tweets
//    }
//
//    static func addSourceToTweets(id: String) -> ([Tweet]) -> [Tweet] {
//        func mapping(tweets: [Tweet]) -> [Tweet] {
//            tweets.map { tweet -> Tweet in
//                var newTweet = tweet
//                newTweet.source = id
//                return newTweet
//            }
//        }
//        return mapping
//    }
//}
//
//extension Tweet {
//    static func filterNil(tweets: [Tweet]) -> [Tweet] {
//        tweets.filter { tweet in
//            return tweet.url != nil && tweet.text != nil && !tweet.text!.isEmpty
//        }
//    }
//}
//
//extension Tweet {
//
//    func domainsList(from categories: Categories) -> [String] {
//        Set(contextAnnotations?.compactMap { annotation -> String? in
//            let token = annotation.domain?.id ?? "0"
//            return categories.categories[token]
//        } ?? []).sorted()
//    }
//
//    func entitiesList() -> [String] {
//        Set(contextAnnotations?.compactMap { annotation -> String? in
//            if source?.contains(annotation.entity?.name ?? "") ?? false {
//                return nil
//            }
//            return annotation.entity?.name
//        } ?? []).sorted()
//    }
//
//}
