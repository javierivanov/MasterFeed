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
    var followingUser: String { get { "https://api.twitter.com/2/users/\(user_id ?? "")/following?user.fields=verified,url,description,profile_image_url,id"} }
    var tweets: String { get { "https://api.twitter.com/2/users/\(id ?? "")/tweets?tweet.fields=created_at,public_metrics,context_annotations,entities" } }
}

//curl "https://api.twitter.com/2/users/2244994945/tweets?expansions=attachments.poll_ids,attachments.media_keys,author_id,entities.mentions.username,geo.place_id,in_reply_to_user_id,referenced_tweets.id,referenced_tweets.id.author_id&tweet.fields=attachments,author_id,context_annotations,conversation_id,created_at,entities,geo,id,in_reply_to_user_id,lang,possibly_sensitive,public_metrics,referenced_tweets,reply_settings,source,text,withheld&user.fields=created_at,description,entities,id,location,name,pinned_tweet_id,profile_image_url,protected,public_metrics,url,username,verified,withheld&place.fields=contained_within,country,country_code,full_name,geo,id,name,place_type&poll.fields=duration_minutes,end_datetime,id,options,voting_status&media.fields=duration_ms,height,media_key,preview_image_url,type,url,width,public_metrics,non_public_metrics,organic_metrics,promoted_metrics&max_results=5"


// MARK: - Twitter Services
struct TwitterServices {
    let user: UserAccount

    func fetchSources(_ userid: String = "2750478267") {
        
        class SampleSubs: Subscriber {

            
            
            func receive(subscription: Subscription) {
                self.subscription = subscription
                self.subscription?.request(.unlimited)
            }
            
            func receive(_ input: SegmentResultGroup) -> Subscribers.Demand {
                
                
                print(input.correlation)

                input.resultGroup.forEach{
                    print($0.similarity, $0.article.text as Any)
                }
                
                
                
//                print(input.corrMatrix?.sorted(by: {$0.score > $1.score})[0...10].map {
//                    ($0.score, (input.keywords[$0.tokens.a], input.keywords[$0.tokens.b]))
//                } as Any)
//
//                input.groupResults.forEach {
//                    print(Set($0.map(\.article).compactMap(\.keywords).reduce([], +)))
//                    $0.forEach({
//                        print($0.similarity, $0.article.text as Any)
//                    })
//                    print("-----")
//                }
//
//
                return .unlimited
            }
            
            func receive(completion: Subscribers.Completion<Never>) {
                print("done :D \(completion)")
            }
            
            typealias Input = SegmentResultGroup
            typealias Failure = Never
            var subscription: Subscription?
            
            
        }
        
        let sampleSub = SampleSubs()
        
        Just(Array(Set(["2097571","428333","9300262","807095", "1367531", "9300262", "16343974", "1652541", "3108351","14511951", "6433472", "4970411","487118986","7587032", "16973333"])))
            .flatMap { (ids: [String]) -> AnyPublisher<Tweet, Never> in
                let tasks = ids.map { (id: String) -> AnyPublisher<Tweet, Never> in
                    let request = user.client.makeRequest(URL(string: "https://api.twitter.com/2/users/\(id)/tweets?tweet.fields=entities")!, method: .GET)
                    let urlRequest = try? request?.makeRequest()
                    return URLSession.shared.dataTaskPublisher(for: urlRequest!)
                        .map { (data, response) -> Data in return data }
                        .decode(type: TimeLineResponse.self, decoder: JSONDecoder())
                        .catch {error -> Just<TimeLineResponse> in
                            Just(TimeLineResponse(data: Array<Tweet>(), meta: nil))
                        }
                        .map {$0.data} //.map {(timeline: TimeLineResponse) -> [Tweet] in timeline.data }
                        .map(Tweet.addSourceToTweets(id: id))
                        .map(Tweet.extractKeywords)
                        .flatMap(\.publisher)
                        .eraseToAnyPublisher()
                }
                return Publishers.MergeMany(tasks).eraseToAnyPublisher()
            }
            .collect()
            .map(Cluster.init(articles:))
            .flatMap(\.publisher)
            .receive(subscriber: sampleSub)

    }
}

// MARK: - Twitter Services API

extension TwitterServices {
    
    // MARK: Subscriptions Publisher
    var subscriptionsPublisher: AnyPublisher<[UserSubscription], Never> {
        
        let request = user.client.makeRequest(TwitterAPI(user_id: user.user_id).followingUser, method: .GET)
        guard let urlRequest = try? request?.makeRequest() else { return Just([]).eraseToAnyPublisher() }
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map { (data, response) -> Data in return data }
            .decode(type: FollowingsResponse.self, decoder: JSONDecoder())
            .catch { _ in Just(FollowingsResponse(data: Array<TwitterUser>(), meta: nil)) }
            .map(\.data)
            .map(twitterUsersTransform(twitterUsers:))
            .eraseToAnyPublisher()
    }
    
    // MARK: Feed Publisher
    func feedPublisher(subscriptions: [UserSubscription]) -> AnyPublisher<SegmentResultGroup, Never> {
        Just(Dictionary(uniqueKeysWithValues: zip(subscriptions.map(\.id), subscriptions)))
            .flatMap(requestSourcesPublisher(ids:))
            
            .map(Cluster.init(articles:))
            .flatMap(\.publisher)
            .eraseToAnyPublisher()
    }
}

// MARK: - Helper functions

extension TwitterServices {
    
    private func twitterUsersTransform(twitterUsers: [TwitterUser]) -> [UserSubscription] {
        twitterUsers.filter { $0.verified }.map { twitterUser -> UserSubscription in
            UserSubscription(username: twitterUser.username, name: twitterUser.name, pic_url: twitterUser.profile_image_url, id: twitterUser.id)
        }
    }
    
    private func requestSourcesPublisher(ids: [String: UserSubscription]) -> AnyPublisher<[Tweet], Never> {
//        print("ids.values.filter({$0.active}).count: \(ids.values.filter({$0.active}).count)")
        let tasks = ids.filter {$0.value.active}.keys.map { (id: String) -> AnyPublisher<Tweet, Never> in
            let request = user.client.makeRequest(URL(string: TwitterAPI(id: id).tweets)!, method: .GET)
            let urlRequest = try? request?.makeRequest()
            return URLSession.shared.dataTaskPublisher(for: urlRequest!)
                .retry(2)
                .map { (data, response) -> Data in return data }
                .decode(type: TimeLineResponse.self, decoder: JSONDecoder())
                .catch { error  -> Just<TimeLineResponse> in
                    print("error \(error)")
                    return Just(TimeLineResponse(data: Array<Tweet>(), meta: nil))
                }
                .map(\.data) //.map { (timeline: TimeLineResponse) -> [Tweet] in timeline.data }
                .map(Tweet.filterNil(tweets:))
                .map(Tweet.addSourceToTweets(id: ids[id]?.name ?? id))
                .map(Tweet.removeHighOccurrences(tweets:)) //avoid repeated suffixes and prefixes like: "Headline | CBS News"
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
