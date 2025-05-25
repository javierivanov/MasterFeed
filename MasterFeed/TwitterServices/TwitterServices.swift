//
//  Twitter.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 14-04-21.
//

import SwiftUI
import Combine // Keep for now, might be removable if all publishers are gone
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

// MARK: - Twitter Services
struct TwitterServices {
    let user: UserAccount
}

// MARK: - Twitter Services API Async
extension TwitterServices {

    // MARK: - Search Async
    func searchAsync(_ searchTerm: String, page: Int? = nil) async throws -> [UserSubscription] {
        let request = user.client.makeRequest(TwitterAPI(searchTerm: searchTerm, page: page).search, method: .GET)
        guard let urlRequest = try request?.makeRequest() else {
            throw FeedError.unhandledError(msg: "Failed to make search request")
        }
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        // Add retry logic if needed, URLSession doesn't have it built-in for async/await like Combine's .retry()
        // For simplicity in this refactor, retry is omitted. Can be added with a loop and delay.
        
        let decodedResponse = try JSONDecoder().decode([SearchResponse].self, from: data)
        
        return decodedResponse
            .filter(TwitterAPI.filterNotVerifiedAccounts(_:))
            .map(TwitterAPI.searchSourceToSubscription)
    }

    // MARK: - User Lookup Async
    func userLookupAsync(_ username: String, category: String) async throws -> UserSubscription {
        let request = user.client.makeRequest(TwitterAPI(username: username).userlookup, method: .GET)
        guard let urlRequest = try request?.makeRequest() else {
            throw FeedError.unhandledError(msg: "Failed to make user lookup request")
        }

        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let decodedResponse = try JSONDecoder().decode(UserLookupResponseData.self, from: data)
        return TwitterAPI.userLookupTransform(decodedResponse.data, category: category)
    }

    // MARK: - Subscriptions Async
    // Corrected: subscriptionsAsync is now a method that directly returns the value or throws.
    func subscriptionsAsync() async throws -> [UserSubscription] {
        let request = self.user.client.makeRequest(TwitterAPI(user_id: self.user.user_id).followingUser, method: .GET)
        guard let urlRequest = try request?.makeRequest() else {
            throw FeedError.unhandledError(msg: "Failed to make subscriptions request")
        }
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let decodedResponse = try JSONDecoder().decode(FollowingsResponse.self, from: data)
        return self.twitterUsersTransform(twitterUsers: decodedResponse.data)
    }
    
    // MARK: Feed Async
    func feedAsync(subscriptions: [UserSubscription]) async throws -> [Cluster] {
        let idsMap = Dictionary(uniqueKeysWithValues: zip(subscriptions.map(\.id), subscriptions))
        let articles = try await requestSourcesAsync(ids: idsMap)
        
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

    // MARK: - Request Sources Async (Helper for Feed Async)
    private func requestSourcesAsync(ids: [String: UserSubscription]) async throws -> [Tweet] {
        let activeSubscriptionIDs = ids.filter { $0.value.active }.keys
        
        var allTweets: [Tweet] = []
        
        try await withThrowingTaskGroup(of: [Tweet].self) { group in
            for id in activeSubscriptionIDs {
                guard let subscriptionInfo = ids[id] else { continue }
                
                group.addTask {
                    let request = self.user.client.makeRequest(URL(string: TwitterAPI(id: id).tweets)!, method: .GET)
                    guard let urlRequest = try? request?.makeRequest() else {
                        print("Failed to make request for id: \(id)")
                        return [] // Return empty for this task if request creation fails
                    }
                    
                    // Simple retry mechanism (can be more sophisticated)
                    var attempts = 0
                    while attempts < 3 {
                        do {
                            print("Requesting Tweets for: \(id), attempt: \(attempts + 1)")
                            let (data, _) = try await URLSession.shared.data(for: urlRequest)
                            let decodedResponse = try JSONDecoder().decode(TimeLineResponse.self, from: data)
                            
                            let tweets = decodedResponse.data
                            let filteredNil = Tweet.filterNil(tweets: tweets)
                            let withSource = Tweet.addSourceToTweets(name: subscriptionInfo.name, username: subscriptionInfo.username, category: subscriptionInfo.category)(filteredNil)
                            let withoutHighOccurrences = Tweet.removeHighOccurrences(tweets: withSource)
                            let withoutOldOccurrences = Tweet.removeOldOcurrences(tweets: withoutHighOccurrences)
                            return Tweet.extractKeywords(articles: withoutOldOccurrences)
                        } catch {
                            attempts += 1
                            if attempts >= 3 {
                                print("Failed to fetch tweets for id: \(id) after 3 attempts. Error: \(error)")
                                // Decide if this should throw or return empty/partial
                                // For now, return empty for this specific source on failure
                                return []
                            }
                            // Non-blocking sleep
                            try await Task.sleep(nanoseconds: 1_000_000_000) // Wait 1 second before retrying
                        }
                    }
                    return [] // Should not be reached if loop logic is correct
                }
            }
            
            for try await tweetsFromSource in group {
                allTweets.append(contentsOf: tweetsFromSource)
            }
        }
        
        // Deduplicate tweets by URL
        var uniqueTweets: [Tweet] = []
        var repeatedUrls: Set<URL> = []
        for tweet in allTweets {
            if let url = tweet.url, !repeatedUrls.contains(url) {
                repeatedUrls.insert(url)
                uniqueTweets.append(tweet)
            } else if tweet.url == nil { // Keep tweets without URLs if that's desired
                 uniqueTweets.append(tweet)
            }
        }
        return uniqueTweets
    }
}


// MARK: - Helper functions (Synchronous, no changes needed here for async unless they call async funcs)
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
}

// MARK: - Combine-based Publishers (Kept for reference, can be removed later)
/*
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
            .flatMap(requestSourcesPublisher(ids:)) // This would need to use the async version or be refactored
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
*/
