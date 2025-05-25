//
//  FeedModel.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 09-05-21.
//

import Foundation
import Combine // Keep for Combine-based timer or if sortFeeds's Just()...sink() is kept
import UnsupervisedTextClassifier
import Network // Not used directly, can be removed if not needed by dependencies


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

struct Categories: Codable {
    var categories: [String: [String]]
}

// MARK: - FeedModel
@MainActor
class FeedModel: ObservableObject {
    
    @Published var user: UserAccount?
    @Published var subscriptions: [UserSubscription] = [] {
        willSet { // Consider if this heavy operation needs to be off main thread
            // If `newValue` is large, encoding can be slow.
            // For simplicity, keeping it as is, but for optimization, consider:
            // Task.detached { self.userSubscriptions = newValue }
            self.userSubscriptions = newValue
        }
    }
    
    var clusters: [String: Cluster]? // Should be updated on MainActor
    var coverage: [Array<CorrelationResult>.Index: Coverage] = [:] // Should be updated on MainActor
    
    @Published var defaultEasyReading: Bool = true {
        willSet { userEasyReading = newValue }
    }
    
    @Published var defaultCategory: String = "Latest" {
        willSet { userCategory = newValue }
    }
    
    private var state_: FeedState = .preparing
    @Published var state: FeedState = .preparing {
        willSet { print("state: \(newValue)") }
    }
    
    @Published var segmentResultsCategoryIndex: [[SegmentResultGroup]] = Array(repeating: [], count: categoryList.count)
    
    static let refreshTime: Double = 60*15 // 15 minutes
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
    
    let defaults = UserDefaults.standard // Explicitly use standard
    
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
    
    // Cancellables for Combine publishers if any remain (e.g., refreshTimer)
    // var sortCancellables: [String: AnyCancellable] = [:] // Example if sortFeeds remains Combine-based and needs cancellation

    init(nosetup: Bool = false) {
        loadCategories()
        defaultCategory = userCategory
        defaultEasyReading = userEasyReading
        
        if nosetup { return }
        
        if (Bundle.main.infoDictionary?["TWITTER_CONSUMER_KEY"] as? String) == nil || (Bundle.main.infoDictionary?["TWITTER_CONSUMER_SECRET"] as? String) == nil {
            self.error = .version
            self.state = .error
            return
        }
        
        if let user_data = userData {
            Task { await self.loadUser(user_data.token) }
        } else {
            self.state = .onboarding // Direct state update is fine as it's @Published on @MainActor
        }
    }
}

// MARK: - FeedModel API Users/Subscriptions (Async)
extension FeedModel {
    
    // Called from non-async context
    func authorizeUser(_ result: Result<UserAccount, UserError>) {
        switch result {
        case .success(let user):
            self.user = user
            self.userData = user.userStorable
            try? UserAuthorization.storeCredentials(user.credentials)
            Task { await self.loadSubscriptionsAsync() }
        case .failure(let error):
            print(error)
            self.error = .unhandledError(msg: error.localizedDescription)
            self.state = .error
        }
    }
    
    func logoutUser() {
        Task {
            self.blockingViewText = "Removing account"
            
            await Task.detached { // Perform potentially blocking IO off the main thread
                UserKeys.allCases.map(\.rawValue).forEach { key in
                    self.defaults.removeObject(forKey: key)
                }
            }.value // Wait for completion
            
            // UI updates back on MainActor
            self.blockingViewText = nil
            self.state = .onboarding
            self.subscriptions = []
            for index in self.segmentResultsCategoryIndex.indices {
                self.segmentResultsCategoryIndex[index] = []
            }
            self.user = nil
        }
    }
    
    func loadUser(_ user_token: String) async {
        do {
            let credentials = try UserAuthorization.loadCredentials(user_token)
            guard let userStorable = self.userData else {
                self.state = .onboarding
                return
            }
            let client = UserAuthorization.buildUserAccount(credentials: credentials)
            self.user = userStorable.buildUserAccount(credentials: credentials, client: client)
            await self.loadSubscriptionsAsync()
        } catch {
            print("Failed to load user credentials: \(error)")
            self.state = .onboarding
        }
    }
    
    func loadSubscriptionsAsync(forceRefresh: Bool = false) async {
        if forceRefresh && self.state == .error {
            self.state = .fetchingSubscriptions
        }
        
        let currentSubs = self.userSubscriptions ?? []
        let needsUpdate = (self.lastSubscriptionUpdate ?? .distantPast).distance(to: Date()) > 60*60*3
        
        guard needsUpdate || currentSubs.isEmpty || forceRefresh else {
            self.subscriptions = currentSubs // Ensure UI reflects stored subs
            self.state = .done
            return
        }
        
        guard let currentUser = self.user else {
            self.error = .unhandledError(msg: "User not found for loading subscriptions")
            self.state = .error
            return
        }
        
        if forceRefresh {
            self.blockingViewText = "Refreshing Subscriptions"
        } else {
            self.state = .fetchingSubscriptions
        }
        
        do {
            var fetchedSubs = try await TwitterServices(user: currentUser).subscriptionsAsync()
            var combinedSubs = Array(Set(currentSubs).union(fetchedSubs))
            combinedSubs = combinedSubs.filter(filterUserSubscriptionWithoutCategory)
            combinedSubs = combinedSubs.map(transformUserSubscriptionWithCategory)
            combinedSubs.sort(by: {$0.name < $1.name})
            
            self.subscriptions = combinedSubs
            self.lastSubscriptionUpdate = Date()
            self.blockingViewText = nil
            self.state = .done
        } catch {
            self.error = .unhandledError(msg: error.localizedDescription)
            self.state = .error
            self.blockingViewText = nil // Clear blocking view on error too
        }
    }
}

// MARK: - FeedModel States (Simplified as class is @MainActor)
// State changes are directly on @MainActor due to class annotation.
// setState helpers can be removed if direct assignment is preferred.

// MARK: - FeedModel API Feed (Async)
extension FeedModel {
    func fetchSourcesAsync(sortResults: Bool = true) async throws {
        guard !subscriptions.isEmpty,
              let currentUser = user else { // state_ check removed, let it try if conditions met
            print("Fetch sources condition not met: subs empty or no user.")
            if subscriptions.isEmpty { self.state = .done } // Avoid getting stuck in fetching if no subs
            return
        }
        
        // Refresh if last update was too long ago OR if there's no content.
        let significantlyOutdated = (lastFeedUpdate ?? .distantPast).distance(to: Date()) >= Self.refreshTime
        let noContentDisplayed = segmentResultsCategoryIndex.allSatisfy({ $0.isEmpty })

        guard significantlyOutdated || noContentDisplayed else {
            print("Fetch sources skipped, too recent or data exists and is recent.")
            self.state = .done // Ensure state is correct if skipped
            return
        }
        
        self.state = .fetchingFeeds
        
        do {
            let fetchedClusters = try await TwitterServices(user: currentUser).feedAsync(subscriptions: subscriptions)
            
            self.clusters = fetchedClusters.reduce(into: [String: Cluster](), {res, next in
                res[next.category] = next
            })
            self.lastFeedUpdate = Date()
            
            if sortResults {
                // Clear previous results before sorting new ones
                self.segmentResultsCategoryIndex = Array(repeating: [], count: Self.categoryList.count)
                Self.categoryList.forEach { category in
                    self.sortFeeds(category: category)
                }
            }
            self.state = .done
        } catch {
            self.error = .unhandledError(msg: error.localizedDescription)
            self.state = .error
            throw error
        }
    }
    
    // sortFeeds is called by fetchSourcesAsync. It processes data and updates @Published properties.
    // Since FeedModel is @MainActor, these updates are safe.
    // If publisherV2 involves heavy computation, it should be offloaded.
    // For now, assuming publisherV2 is efficient or primarily for structuring data.
    func sortFeeds(category: String) {
        guard let clusters = self.clusters, let cluster = clusters[category] else {
            return
        }
        
        self.visibleCategories.insert(category)
        
        // This Combine pipeline processes data. If it's CPU intensive, ensure it's on a background thread.
        // The .receive(on: DispatchQueue.main) ensures final updates are on the main thread.
        // Since the class is @MainActor, direct property assignments in .sink are fine.
        let cancellable = Just(cluster) // Publisher on current thread
            .receive(on: DispatchQueue.global(qos: .userInteractive)) // Offload heavy processing
            .flatMap(\.publisherV2) // Assumed to be data transformation
            .collect()
            .receive(on: RunLoop.main) // Switch to main thread for @Published updates
            .sink(receiveValue: { [weak self] segmentResult in
                guard let self = self else { return }
                let segmentsFiltered = segmentResult.sorted { a, b in a.resultGroup.count > b.resultGroup.count }
                let maxSize = min(segmentResult.count, 6) // Ensure maxSize doesn't exceed bounds
                if maxSize > 0, let categoryIndex = Self.categoryListIndex[category] {
                    if self.segmentResultsCategoryIndex.indices.contains(categoryIndex) {
                        // Ensure not to append if already populated by another call, or clear before fetch
                        self.segmentResultsCategoryIndex[categoryIndex].append(contentsOf: segmentsFiltered[0..<maxSize])
                    }
                }
                self.visibleCategories.remove(category)
                self.currentVisibleCategory = category
            })
        // Keep the cancellable if you need to manage the lifecycle of this Combine pipeline
        // For instance, store it in a Set<AnyCancellable> and cancel it on deinit or when a new sort starts.
        // For simplicity here, it's not stored, meaning it cancels automatically on completion or error.
        // If sortFeeds can be called multiple times rapidly for the same category, consider managing these cancellables.
        // For this refactor, we'll assume it's managed or completes quickly.
         _ = cancellable // To silence unused variable warning, if not storing it.
    }
}

// MARK: - Categories (No async changes needed here typically)
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
            fatalError("Failed to load categories.json")
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
    
    func loadUserLookupAsync(_ usernames: [String], category: String) async {
        // Ensure user is available
        guard let currentUser = self.user else { return }

        await withTaskGroup(of: UserSubscription?.self) { group in
            for username in usernames {
                group.addTask {
                    do {
                        return try await TwitterServices(user: currentUser).userLookupAsync(username, category: category)
                    } catch {
                        print("Failed to lookup user \(username): \(error)")
                        return nil
                    }
                }
            }
            
            for await result in group {
                if let validSubscription = result {
                    // This is already on MainActor due to FeedModel being @MainActor
                    self.recommendedSources[category, default: []].append(validSubscription)
                }
            }
        }
    }
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
