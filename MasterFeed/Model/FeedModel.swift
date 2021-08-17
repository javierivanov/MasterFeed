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
    var categories: [String: [String]]
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
    
    var clusters: [String: Cluster]?
    
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
    
    @Published var segmentResultsCategoryIndex: [[SegmentResultGroup]] = Array(repeating: [], count: categoryList.count)
    
    static let refreshTime: Double = 60*15
    
    var refreshTimer = Timer.TimerPublisher(interval: refreshTime, runLoop: .main, mode: .common).autoconnect()
    
    @Published var error: FeedError = .unhandledError(msg: "Unknown Error")
    @Published var blockingViewText: String?
    
    
    @Published var recommendedSources: [String: [UserSubscription]] = [:]
    @Published var visibleCategories: Set<String> = []
    @Published var currentVisibleCategory: String?
    
    private(set) var categoriesMapping: [String: [String]]!
    private(set) var sourceCategoryMap: [String: String]!
    static var categoryList: [String] = ["News", "Politics",  "Business", "Health", "UK", "US", "World", "Europe", "Technology", "Entertainment","Travel", "Video", "Opinion"]
    static var categoryListIndex: [String: Int] = categoryList.enumerated().reduce(into: [String: Int](), {res, next in res[next.element] = next.offset})
    
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
    
    
    // MARK: - Cancellables -
    
    var subsCancellable: AnyCancellable?
    var fecthCancellable: AnyCancellable?
    var sortCancellables: [String: AnyCancellable] = [:]
    var coverageCancellable: AnyCancellable?
    var userLookupCancellable: [String: AnyCancellable] = [:]

    
    // MARK: -- INIT
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
                for index in self.segmentResultsCategoryIndex.indices {
                    self.segmentResultsCategoryIndex[index] = []
                }
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
            
            subsCancellable = TwitterServices(user: user).subscriptionsPublisher
                .map { subs in Array(Set(userSubscriptions).union(subs)) }
                .map { subs in subs.filter(filterUserSubscriptionWithoutCategory) }
                .map { subs in subs.map(transformUserSubscriptionWithCategory) }
                .map { subs in subs.sorted(by: {$0.name < $1.name})}
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
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
                }, receiveValue: { subs in
                    subscriptions = subs
                })
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
    func fetchSources(_ category: String? = nil, sortResults: Bool = true) {
        guard !subscriptions.isEmpty,
              state_ == .done,
              let user = user else { return }
        
        guard (lastFeedUpdate ?? Date()).distance(to: Date()) >= Self.refreshTime || segmentResultsCategoryIndex.allSatisfy({ $0.isEmpty }) else { return }
        
        self.setState(.fetchingFeeds)

        
        fecthCancellable = TwitterServices(user: user).feedPublisher(subscriptions: subscriptions)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {completion in
                switch completion {
                case .failure(let error): self.setState(newState: .error) { self.error = .unhandledError(msg: error.localizedDescription) }
                case .finished:
                    self.lastFeedUpdate = Date()
                    self.setState(.done)
                }
            }, receiveValue: { clusters in
                self.clusters = clusters.reduce(into: [String: Cluster](), {res, next in
                    res[next.category] = next
                })
                if sortResults {
                    Self.categoryList.forEach { category in
                        self.sortFeeds(category: category)
                    }
                }
            })
    }
    
    func sortFeeds(category: String) {
        
        guard let clusters = clusters, let cluster = clusters[category] else {
            return
        }
        
        guard self.sortCancellables[category] == nil else {
            return
        }
        
        DispatchQueue.main.async {
            self.visibleCategories.insert(category)
        }
        
        self.sortCancellables[category] = Just(cluster)
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .flatMap(\.publisherV2)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { segmentResult in
                self.sortCancellables[category] = nil
                let segmentsFiltered = segmentResult.sorted { a, b in a.resultGroup.count > b.resultGroup.count }
                let maxSize = segmentResult.count < 6 ? segmentResult.count : 6
                if maxSize > 0 {
                    self.segmentResultsCategoryIndex[Self.categoryListIndex[category]!].append(contentsOf: segmentsFiltered[0..<maxSize])
                }
                self.visibleCategories.remove(category)
                self.currentVisibleCategory = category
            })
    }
}

// MARK: - Categories

extension FeedModel {
    
    func transformUserSubscriptionWithCategory(_ subscription: UserSubscription) -> UserSubscription {
        var sub = subscription
        sub.category = sourceCategoryMap[sub.username, default: "News"]
        return sub
    }
    
    func filterUserSubscriptionWithoutCategory(_ sub: UserSubscription) -> Bool {
        sourceCategoryMap.keys.contains(sub.username)
    }
    
    func loadCategories() {
        guard let url = Bundle.main.url(forResource: "categories", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let catsMapping = try? JSONDecoder().decode(Categories.self, from: data) else {
            fatalError()
        }
        categoriesMapping = catsMapping.categories
        var maps = [String: String]()
        catsMapping.categories.keys.forEach { key in
            catsMapping.categories[key]?.forEach { value in
                maps[value] = key
            }
        }
        sourceCategoryMap = maps
    }
    
    
    
    func loadUserLookup(_ usernames: [String], category: String) {
        
        usernames.forEach { username in
            userLookupCancellable[username] = TwitterServices(user: user!).userLookupPublisher(username, category: category)
                .receive(on: DispatchQueue.main)
                .sink { _ in
                } receiveValue: { result in
                    self.objectWillChange.send()
                    self.recommendedSources[category, default: []].append(result)
                }
        }
        
    }
    
//    func currentCategories() -> [String] {
//        var categories = ["Latest"]
//        segmentResults.forEach { segment in
//            segment.resultGroup.forEach { result in
//                categories.append(contentsOf: (result.article as! Tweet).categories)
//            }
//        }
//        return Array(Set(categories)).sorted()
//    }
    
    
}


// MARK: - Preview Samples

extension FeedModel {
    
    static func sampleSubs() -> FeedModel {
        let feedModel = FeedModel(nosetup: true)
        let sampleSubs: [UserSubscription] = [
            UserSubscription(username: "sample_User", name: "Sample User", pic_url: "", id: "1234", active: true, category: "Politics"),
            UserSubscription(username: "sample_User2", name: "Sample User2", pic_url: "", id: "1235", active: false, category: "Politics")
        ]
        feedModel.subscriptions = sampleSubs
        return feedModel
    }
    
    
    static func sampleSubsList() -> [UserSubscription] {
        return [
            UserSubscription(username: "sample_User", name: "Sample User", pic_url: "", id: "1234", active: true, category: "News"),
            UserSubscription(username: "sample_User2", name: "Sample User2", pic_url: "", id: "1235", active: false, category: "Politics")
        ]
    }
}
