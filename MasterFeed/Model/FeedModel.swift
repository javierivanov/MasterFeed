//
//  FeedModel.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 09-05-21.
//

import Foundation
import Combine
import UnsupervisedTextClassifier
import Network


// MARK: - Feed Status
enum FeedState: Int, CaseIterable {
    case preparing // checking for user
    case onboarding // no user
    case fetchingSubscriptions // fetching subs
    case fetchingFeeds // fetching feeds
    case error
    case done // display feed
}

// MARK: - User Defaults Keys
enum UserKeys: String, CaseIterable {
    case last_subscription_update
    case last_feed_update
    case user_subscription
    case use_easyreading
    case user_data
    case user_category
    case user_easyreading
}

//// MARK: - Categories TypeAlias
//typealias Categories = [String: String]

// MARK: - Categories
struct Categories: Codable {
    let categories: [String: String]
    let icons: [String: String]
}



// MARK: - FeedModel
class FeedModel: ObservableObject {
    
    @Published var user: UserAccount?
    @Published var subscriptions: [UserSubscription] = [] {
        willSet {
            guard !newValue.isEmpty else { return }
            DispatchQueue.global(qos: .background).async {
                self.userSubscriptions = newValue
            }
        }
    }
    
    var cluster: Cluster?
    
    var coverage: [Array<CorrelationResult>.Index: Coverage] = [:]
    
    @Published var defaultEasyReading: Bool = true {
        willSet {
            userEasyReading = newValue
        }
    }
    
    @Published var defaultCategory: String = "Latest" {
        willSet {
            userCategory = newValue
        }
    }
    
    private var state_: FeedState = .preparing
    @Published var state: FeedState = .preparing {
        willSet {
            print("state: \(newValue)")
        }
    }
    
    @Published var segmentResults: [SegmentResultGroup] = []
    
    var refreshTimer = Timer.TimerPublisher(interval: 60, runLoop: .main, mode: .common).autoconnect()
    
    @Published var error: FeedError = .unhandledError(msg: "Unknown Error")
    @Published var blockingViewText: String?
    
    //    private(set) var refreshControl: RefreshControl!
    private(set) var categories: Categories!
    private(set) var categoryList: [String]!
    
    let defaults = UserDefaults()
    
    private var lastFeedUpdate: Date? {
        get { defaults.object(forKey: UserKeys.last_feed_update.rawValue) as? Date }
        set { defaults.set(newValue, forKey: UserKeys.last_feed_update.rawValue) }
    }
    
    
    private var lastSubscriptionUpdate: Date? {
        get { defaults.object(forKey: UserKeys.last_subscription_update.rawValue) as? Date }
        set { defaults.set(newValue, forKey: UserKeys.last_subscription_update.rawValue) }
    }
    
    private var userSubscriptions: [UserSubscription]? {
        get {
            guard let data = defaults.data(forKey: UserKeys.user_subscription.rawValue) else { return nil }
            return try? PropertyListDecoder().decode([UserSubscription].self, from: data)
        }
        set {
            if let data = try? PropertyListEncoder().encode(newValue) {
                defaults.set(data, forKey: UserKeys.user_subscription.rawValue)
            }
        }
    }
    
    private var userCategory: String {
        get { defaults.string(forKey: UserKeys.user_category.rawValue) ?? "Latest"}
        set { defaults.setValue(newValue, forKey: UserKeys.user_category.rawValue) }
    }
    
    private var userEasyReading: Bool {
        get { defaults.object(forKey: UserKeys.user_easyreading.rawValue) as? Bool ?? true }
        set { defaults.setValue(newValue, forKey: UserKeys.user_easyreading.rawValue) }
    }
    
    private var userData: UserAccountStorable? {
        get {
            guard let data = defaults.data(forKey: UserKeys.user_data.rawValue) else { return nil }
            return try? PropertyListDecoder().decode(UserAccountStorable.self, from: data)
        }
        set {
            if let data = try? PropertyListEncoder().encode(newValue) {
                defaults.set(data, forKey: UserKeys.user_data.rawValue)
            }
        }
    }
    
    init(nosetup: Bool = false) {
        // Loading default values
        loadCategories()
        defaultCategory = userCategory
        defaultEasyReading = userEasyReading
        
        //RefreshControl
        //        refreshControl = RefreshControl(feedModel: self)
        
        if nosetup { // Avoid user setup
            return
        }
        
        // Check keys
        if (Bundle.main.infoDictionary?["TWITTER_CONSUMER_KEY"] as? String) == nil || (Bundle.main.infoDictionary?["TWITTER_CONSUMER_SECRET"] as? String) == nil {
            self.error = .version
            self.state = .error
            return
        }
        
        
        // Quick user setup
        if let user_data = userData {
            loadUser(user_data.token)
        } else {
            setState(.onboarding)
        }
    }
    
}

// MARK: - FeedModel API Users/Subscriptions-

extension FeedModel {
    
    func authorizeUser(_ result: Result<UserAccount, UserError>) {
        
        switch result {
        case .success(let user):
            DispatchQueue.main.async {
                defer {
                    try? UserAuthorization.storeCredentials(user.credentials)
                }
                self.user = user
                self.userData = user.userStorable
                self.loadSubscriptions()
            }
        case .failure(let error):
            print(error)
        // Alert?
        }
    }
    
    func logoutUser() {
        DispatchQueue.main.async {
            self.blockingViewText = "Removing account"
        }
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now()+2) {
            
            UserKeys.allCases.map(\.rawValue).forEach {
                self.defaults.removeObject(forKey: $0)
            }
            
            self.setState(newState: .onboarding, additionalChanges: {
                self.blockingViewText = nil
                self.subscriptions = []
                self.segmentResults = []
                self.user = nil
            })
        }
    }
    
    
    // TODO: Add throwing exception with error handling.
    func loadUser(_ user_token: String) {
        DispatchQueue.global(qos: .userInteractive).async {
            guard let credentials = try? UserAuthorization.loadCredentials(user_token),
                  let user = self.userData else {
                self.setState(.onboarding)
                return
            } // Maybe add throw exception
            let client = UserAuthorization.buildUserAccount(credentials: credentials)
            
            DispatchQueue.main.async {
                self.user = user.buildUserAccount(credentials: credentials, client: client)
                self.loadSubscriptions()
            }
        }
    }
    
    
    
    func loadSubscriptions(forceRefresh: Bool = false) {
        
        DispatchQueue.global(qos: .userInteractive).async { [self] in
            
            if forceRefresh && state == .error {
                self.setState(.fetchingSubscriptions)
            }
            
            let userSubscriptions = userSubscriptions ?? []
            
            let cond1 = (lastSubscriptionUpdate ?? Date()).distance(to: Date()) > 60*60*3
            let cond2 = userSubscriptions.isEmpty
            
            guard cond1 || cond2 || forceRefresh else {
                setState(newState: .done, additionalChanges: {
                    self.subscriptions = userSubscriptions
                })
                return
            }
            
            guard let user = user else {
                setState(newState: .error, additionalChanges: {
                    self.error = .unhandledError(msg: "User not found")
                })
                return
            }
            
            DispatchQueue.main.async {
                if forceRefresh {
                    //self.status = .fetchingSubscriptionsLocally
                    self.blockingViewText = "Refreshing Subscriptions"
                } else {
                    self.state = .fetchingSubscriptions
                }
            }
            
            TwitterServices(user: user).subscriptionsPublisher
                .map{ subs in Array(Set(userSubscriptions).union(subs)) }
                .map { subs in subs.sorted(by: {$0.name < $1.name})}
                .handleEvents(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let fail):
                        self.setState(newState: .error, additionalChanges: {
                            self.error = .unhandledError(msg: fail.localizedDescription)
                        })
                    case .finished:
                        self.lastSubscriptionUpdate = Date()
                        setState(newState: .done, additionalChanges: {
                            self.blockingViewText = nil
                        })
                    }
                    
                })
                .receive(on: DispatchQueue.main)
                .catch { _ in
                    Just<[UserSubscription]>([])
                }
                .assign(to: &$subscriptions)
        }
    }
    
}

// MARK: - FeedModel States
extension FeedModel {
    private func setState(_ newState: FeedState) {
        // TODO: enforce safe changes.
        self.state_ = newState
        DispatchQueue.main.async {
            self.state = newState
            self.blockingViewText = nil
        }
    }
    
    private func setState(newState: FeedState, additionalChanges: @escaping () -> Void) {
        // TODO: enforce safe changes.
        self.state_ = newState
        DispatchQueue.main.async {
            self.state = newState
            additionalChanges()
        }
    }
    
}


// MARK: - FeedModel API Feed

extension FeedModel {
    func fetchSources() {
        guard !subscriptions.isEmpty,
              state_ == .done,
              let user = user else { return }
        
        guard (lastFeedUpdate ?? Date()).distance(to: Date()) >= 15*60 || segmentResults.isEmpty else { return }
        
        self.setState(.fetchingFeeds)

        TwitterServices(user: user).feedPublisher(subscriptions: subscriptions)
            .collect()
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.setState(newState: .error, additionalChanges: {
                        self.error = .unhandledError(msg: error.localizedDescription)
                    })
                case .finished:
                    self.lastFeedUpdate = Date()
                    self.setState(.done)
                }
            })
            .catch { _ in
                Just<[SegmentResultGroup]>([])
            }
            .assign(to: &$segmentResults)
    }
    
}

// MARK: - Categories

extension FeedModel {
    func loadCategories() {
        if let url = Bundle.main.url(forResource: "categories", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let categories_ = try? JSONDecoder().decode(Categories.self, from: data){
            categories = categories_
            categoryList = Array(categories_.icons.keys).sorted()
        } else {
            categories = Categories(categories: ["0": "Latest"], icons: ["Latest": "newspaper"])
            categoryList = ["Latest"]
        }
    }
    
    func filterSegments(for category: String = "Latest") -> [SegmentResultGroup] {
        
        guard category != "Latest" else {
            return segmentResults
        }
        
        return segmentResults.compactMap { segment in
            var segment = segment
            segment.resultGroup = segment.resultGroup.filter { result in
                let tweet = result.article as! Tweet
                return tweet.categories.contains(category)
            }
            return segment.resultGroup.count > 0 ? segment : nil
        }
    }
    
    func currentCategories() -> [String] {
        var categories = ["Latest"]
        segmentResults.forEach { segment in
            segment.resultGroup.forEach { result in
                categories.append(contentsOf: (result.article as! Tweet).categories)
            }
        }
        return Array(Set(categories)).sorted()
    }
    
    
}


// MARK: - Coverage -
extension FeedModel {
    
    func computeCoverage(index: Array<CorrelationResult>.Index) {
        guard let cluster = cluster else { return }
        var coverage = self.coverage[index, default: Coverage()].$sortedArticles
        cluster.tokenSimilarities(tokenIndex: index)
            .collect()
            .map { resultGroup -> [Tweet] in resultGroup.map {$0.article as! Tweet} }
            .receive(on: DispatchQueue.main)
            .assign(to: &coverage)
    }
}


// MARK: - Preview Samples

extension FeedModel {
    
    static func sampleSubs() -> FeedModel {
        let feedModel = FeedModel(nosetup: true)
        let sampleSubs: [UserSubscription] = [
            UserSubscription(username: "sample_User", name: "Sample User", pic_url: "", id: "1234", active: true),
            UserSubscription(username: "sample_User2", name: "Sample User2", pic_url: "", id: "1235", active: false)
        ]
        feedModel.subscriptions = sampleSubs
        return feedModel
    }
}
