//
//  Twitter.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 14-04-21.
//

import SwiftUI
import Combine
import OAuthSwift
import UnsupervisedTextClassifier

fileprivate struct TwitterAPI {
    var user_id: String?
    var id: String?
    var searchTerm: String?
    var page: Int?
    var username: String?
    
    var followingUser: String { get { "https://api.twitter.com/2/users/\(user_id ?? "")/following?user.fields=verified,url,description,profile_image_url,id"} }
    var tweets: String { get { "https://api.twitter.com/2/users/\(id ?? "")/tweets?tweet.fields=created_at,public_metrics,context_annotations,entities" } }
    var search: String {
        get {
            let base = "https://api.twitter.com/1.1/users/search.json?q=\(searchTerm?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            if let page = page {
                return base.appending("&page=\(page)")
            }
            return base
        }
    }
    var userlookup: String { get { "https://api.twitter.com/2/users/by/username/\(username ?? "")?user.fields=profile_image_url" } }
    
}

//curl "https://api.twitter.com/2/users/2244994945/tweets?expansions=attachments.poll_ids,attachments.media_keys,author_id,entities.mentions.username,geo.place_id,in_reply_to_user_id,referenced_tweets.id,referenced_tweets.id.author_id&tweet.fields=attachments,author_id,context_annotations,conversation_id,created_at,entities,geo,id,in_reply_to_user_id,lang,possibly_sensitive,public_metrics,referenced_tweets,reply_settings,source,text,withheld&user.fields=created_at,description,entities,id,location,name,pinned_tweet_id,profile_image_url,protected,public_metrics,url,username,verified,withheld&place.fields=contained_within,country,country_code,full_name,geo,id,name,place_type&poll.fields=duration_minutes,end_datetime,id,options,voting_status&media.fields=duration_ms,height,media_key,preview_image_url,type,url,width,public_metrics,non_public_metrics,organic_metrics,promoted_metrics&max_results=5"


// MARK: - Twitter Services
struct TwitterServices {
    let user: UserAccount

}

// MARK: - Twitter Services API

extension TwitterServices {
    
//    MARK: - Search Publisher
    func searchPublisher(_ searchTerm: String, page: Int? = nil) -> AnyPublisher<[UserSubscription], Error> {
        let request = user.client.makeRequest(TwitterAPI(searchTerm: searchTerm, page: page).search, method: .GET)
        guard let urlRequest = try? request?.makeRequest() else { return Fail(error: FeedError.unhandledError(msg: "Failed to make request")).eraseToAnyPublisher() }
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: [SearchResponse].self, decoder: JSONDecoder())
            .retry(2)
            .flatMap(\.publisher)
            .filter(TwitterAPI.filterNotVerifiedAccounts(_:))
            .map(TwitterAPI.searchSourceToSubscription)
            .collect()
            .eraseToAnyPublisher()
    }
}

extension TwitterServices {
    func userLookupPublisher(_ username: String, category: String) -> AnyPublisher<UserSubscription, Error> {
        let request = user.client.makeRequest(TwitterAPI(username: username).userlookup, method: .GET)
        guard let urlRequest = try? request?.makeRequest() else { return Fail(error: FeedError.unhandledError(msg: "Failed to make request")).eraseToAnyPublisher() }

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: UserLookupResponseData.self, decoder: JSONDecoder())
            .map(\.data)
            .map { TwitterAPI.userLookupTransform($0, category: category) }
            .eraseToAnyPublisher()
    }
}

extension TwitterServices {
    
    // MARK: -Subscriptions Publisher
    var subscriptionsPublisher: AnyPublisher<[UserSubscription], Error> {
        
        let request = user.client.makeRequest(TwitterAPI(user_id: user.user_id).followingUser, method: .GET)
        guard let urlRequest = try? request?.makeRequest() else { return Fail(error: FeedError.unhandledError(msg: "Failed to make request")).eraseToAnyPublisher() }
        
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: FollowingsResponse.self, decoder: JSONDecoder())
            //.catch { _ in Just(FollowingsResponse(data: Array<TwitterUser>(), meta: nil)) }
            .map(\.data)
            .map(twitterUsersTransform(twitterUsers:))
            .eraseToAnyPublisher()
    }
    
    // MARK: Feed Publisher
    func feedPublisher(subscriptions: [UserSubscription]) -> AnyPublisher<[Cluster], Error> {
        Just(Dictionary(uniqueKeysWithValues: zip(subscriptions.map(\.id), subscriptions)))
            .flatMap(requestSourcesPublisher(ids:))
            .map { articles in
                var art_per_cat: [String: [Article]] = [:]
                
                articles.forEach { tweet in
                    tweet.categories.forEach { cat in
                        art_per_cat[cat, default: []].append(tweet)
                    }
                }
                
                return art_per_cat.keys.map { key in
                    Cluster(articles: art_per_cat[key]!, category: key, maxSimilarity: 2.0/3.0)
                }
            }
            .eraseToAnyPublisher()
        
    }
}

// MARK: - Helper functions


extension TwitterAPI {
    static func userLookupTransform(_ user: UserLookupResponse, category: String) -> UserSubscription {
        UserSubscription(username: user.username,
                         name: user.name,
                         pic_url: user.profile_image_url,
                         id: user.id,
                         active: true,
                         category: category,
                         inMemory: true)
    }
}

extension TwitterAPI {
    static func filterNotVerifiedAccounts(_ search: SearchResponse) -> Bool {
        search.verified
    }
    static func searchSourceToSubscription(_ search: SearchResponse) -> UserSubscription {
        UserSubscription(username: search.screen_name,
                         name: search.name,
                         pic_url: search.profile_image_url_https,
                         id: search.id_str,
                         active: true,
                         category: "News",
                         inMemory: true)
    }
}

extension TwitterServices {
    
    private func twitterUsersTransform(twitterUsers: [TwitterUser]) -> [UserSubscription] {
        twitterUsers.filter { $0.verified }.map { twitterUser -> UserSubscription in
            UserSubscription(username: twitterUser.username, name: twitterUser.name, pic_url: twitterUser.profile_image_url, id: twitterUser.id, category: "News")
        }
    }
    
    private func requestSourcesPublisher(ids: [String: UserSubscription]) -> AnyPublisher<[Tweet], Error> {
        let tasks = ids.filter {$0.value.active}.keys.map { (id: String) -> AnyPublisher<Tweet, Error> in
            let request = user.client.makeRequest(URL(string: TwitterAPI(id: id).tweets)!, method: .GET)
            let urlRequest = try? request?.makeRequest()
            print("Request: \(id)")
            return URLSession.shared.dataTaskPublisher(for: urlRequest!)
                .retry(3)
                .map(\.data)
                .decode(type: TimeLineResponse.self, decoder: JSONDecoder())
//                .catch { error  -> Just<TimeLineResponse> in
//                    print("error: \(error)")
//                    return Just(TimeLineResponse(data: Array<Tweet>(), meta: nil))
//                }
                .map(\.data) //.map { (timeline: TimeLineResponse) -> [Tweet] in timeline.data }
                .map(Tweet.filterNil(tweets:))
                .map(Tweet.addSourceToTweets(name: ids[id]!.name, username: ids[id]!.username, category: ids[id]!.category))
                .map(Tweet.removeHighOccurrences(tweets:)) //avoid repeated suffixes and prefixes like: "Headline | CBS News"
                .map(Tweet.removeOldOcurrences(tweets:))
                .map(Tweet.extractKeywords(articles:))
                .flatMap(\.publisher)
                .eraseToAnyPublisher()
        }
        return Publishers.MergeMany(tasks)
            .collect()
            .map { tweets in
                var uniqueTweets: [Tweet] = []
                var repeatedUrls: Set<URL> = []
                for tweet in tweets {
                    if let url = tweet.url, !repeatedUrls.contains(url) {
                        repeatedUrls.insert(url)
                        uniqueTweets.append(tweet)
                    }
                }
                return uniqueTweets
            }
            .eraseToAnyPublisher()
    }
}
