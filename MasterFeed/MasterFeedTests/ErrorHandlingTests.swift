import XCTest
@testable import MasterFeed

class ErrorHandlingTests: XCTestCase {

    func testFeedErrorLocalizedDescriptions() {
        // Test .noNetwork case
        XCTAssertEqual(FeedError.noNetwork.localizedDescription, "No Internet Connection",
                       "Localized description for .noNetwork did not match expected value.")

        // Test .timeoutResponse case
        XCTAssertEqual(FeedError.timeoutResponse.localizedDescription, "The request timed out. Please try again.",
                       "Localized description for .timeoutResponse did not match expected value.")

        // Test .version case
        XCTAssertEqual(FeedError.version.localizedDescription, "This version is not supported. Please Update The App In The AppStore.",
                       "Localized description for .version did not match expected value.")

        // Test .unhandledError case
        let testMessage = "This is a specific test message for unhandled error."
        XCTAssertEqual(FeedError.unhandledError(msg: testMessage).localizedDescription, testMessage,
                       "Localized description for .unhandledError did not match expected value.")
        
        // Test .unhandledError with an empty message
        XCTAssertEqual(FeedError.unhandledError(msg: "").localizedDescription, "",
                       "Localized description for .unhandledError with empty message did not match expected value.")
    }

    // Optional: Add tests for recoverySuggestion if implemented
    /*
    func testFeedErrorRecoverySuggestions() {
        // Example:
        // XCTAssertEqual(FeedError.noNetwork.recoverySuggestion, "Please check your network settings and try again.")
    }
    */
}
