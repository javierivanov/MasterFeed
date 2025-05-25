import XCTest
@testable import MasterFeed // Import your app module

class FeedModelTests: XCTestCase {

    var appBundleIdentifier: String?
    var feedModel: FeedModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        // It's generally better to use a specific suite name for UserDefaults
        // rather than the main app's bundle ID to avoid conflicts if tests run on a device.
        // However, following instructions to use app's bundle ID.
        appBundleIdentifier = Bundle.main.bundleIdentifier
        XCTAssertNotNil(appBundleIdentifier, "App bundle identifier should not be nil.")

        // Ensure a clean slate for UserDefaults for each test,
        // though tearDown will also clean up.
        if let bundleID = appBundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        
        // Initialize feedModel here to be used by tests
        // FeedModel itself uses UserDefaults.standard, which is what we are testing.
        feedModel = FeedModel(nosetup: true) // Use nosetup to prevent automatic user loading
    }

    override func tearDownWithError() throws {
        if let bundleID = appBundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        feedModel = nil
        appBundleIdentifier = nil
        try super.tearDownWithError()
    }

    func testLogoutUser() async throws {
        // Arrange:
        
        // 1. Set dummy UserAccount in FeedModel (if logoutUser logic depends on it)
        // For this test, we are more interested in UserDefaults and state.
        // Let's assume logoutUser internally handles user being nil or not.
        // However, setting some initial state that logoutUser clears is good.
        let dummyCredentials = UserCredentials(oauth_token: "dummyToken", oauth_token_secret: "dummySecret", user_id: "dummyUserID")
        let dummyClient = UserAuthorization.buildUserAccount(credentials: dummyCredentials) // Assuming this returns a non-nil OAuth1Swift
        feedModel.user = UserAccount(user_id: "dummyUserID", name: "Dummy User", username: "dummyUsername", credentials: dummyCredentials, client: dummyClient)


        // 2. Set dummy data in UserDefaults that logoutUser should clear.
        let defaults = UserDefaults.standard
        
        // UserData
        let dummyUserStorable = UserAccountStorable(user_id: "dummyUserID", name: "Dummy User", username: "dummyUsername", token: "dummyToken")
        if let userData = try? PropertyListEncoder().encode(dummyUserStorable) {
            defaults.set(userData, forKey: UserKeys.user_data.rawValue)
        } else {
            XCTFail("Failed to encode dummyUserStorable for UserDefaults setup.")
        }

        // UserSubscriptions
        let dummySubscription = UserSubscription(username: "testSub", name: "Test Sub", pic_url: "", id: "sub123", active: true, category: "News")
        if let subscriptionData = try? PropertyListEncoder().encode([dummySubscription]) {
            defaults.set(subscriptionData, forKey: UserKeys.user_subscription.rawValue)
        } else {
            XCTFail("Failed to encode dummySubscription for UserDefaults setup.")
        }
        
        // Other keys (optional, but good for completeness if logoutUser clears all UserKeys)
        defaults.set(Date(), forKey: UserKeys.last_feed_update.rawValue)
        defaults.set("TestCategory", forKey: UserKeys.user_category.rawValue)
        defaults.set(false, forKey: UserKeys.user_easyreading.rawValue)

        // Ensure data is actually set before logout
        XCTAssertNotNil(defaults.data(forKey: UserKeys.user_data.rawValue), "UserDefaults user_data should be set before logout.")

        // Act:
        // logoutUser is marked @MainActor in FeedModel (implicitly because FeedModel is @MainActor)
        // XCTest runs tests on a background thread by default.
        // To call logoutUser, we need to ensure it's called from the MainActor or the test needs to be structured appropriately.
        // Since FeedModel is @MainActor, and logoutUser internally dispatches to Task.detached for some parts,
        // calling it directly from an async test function should be fine, as the test function itself can hop to MainActor if needed.
        // However, logoutUser itself has Task {} which might introduce delays.
        // We need to wait for its effects.
        
        // Perform the logout. logoutUser itself uses Task { await MainActor.run {} }
        // and Task.detached {}. We need to wait for these to reasonably complete.
        // The `await` here waits for the Task created inside logoutUser to initiate.
        // The internal Task.detached will run independently.
        // The state changes are dispatched to MainActor.
        
        await feedModel.logoutUser() // This will kick off the async work within logoutUser

        // We need to wait for the asynchronous operations within logoutUser to complete.
        // logoutUser has an internal `await Task.sleep(2_000_000_000)` (2 seconds).
        // So we must wait at least that long.
        // For robust tests, expectations might be better, but a simple sleep can work for this known delay.
        try await Task.sleep(nanoseconds: 2_500_000_000) // Wait slightly longer than the internal sleep

        // Assert:
        XCTAssertNil(feedModel.user, "User should be nil after logout.")
        XCTAssertEqual(feedModel.state, .onboarding, "FeedModel state should be .onboarding after logout.")
        
        // Assert UserDefaults are cleared
        XCTAssertNil(defaults.object(forKey: UserKeys.user_data.rawValue), "UserDefaults user_data should be cleared.")
        XCTAssertNil(defaults.object(forKey: UserKeys.user_subscription.rawValue), "UserDefaults user_subscription should be cleared.")
        XCTAssertNil(defaults.object(forKey: UserKeys.last_feed_update.rawValue), "UserDefaults last_feed_update should be cleared.")
        XCTAssertNil(defaults.object(forKey: UserKeys.user_category.rawValue), "UserDefaults user_category should be cleared.")
        XCTAssertNil(defaults.object(forKey: UserKeys.user_easyreading.rawValue), "UserDefaults user_easyreading should be cleared.")
        
        // A more robust check for all keys if logoutUser is expected to clear everything in UserKeys.allCases
        UserKeys.allCases.forEach { keyCase in
            XCTAssertNil(defaults.object(forKey: keyCase.rawValue), "UserDefaults key \(keyCase.rawValue) should be cleared.")
        }
    }
}
