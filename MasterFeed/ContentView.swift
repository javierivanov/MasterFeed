//
//  ContentView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 10-05-21.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var feedModel: FeedModel // FeedModel is @MainActor
    
    var body: some View {
        
        switch feedModel.state {
        case .preparing:
            ProgressView()
        case .onboarding:
            OnboardingView()
        case .fetchingSubscriptions:
            ProgressView("Refreshing Subscriptions")
        case .error:
            // MODIFIED HERE: Enhanced error display
            VStack(alignment: .center, spacing: 20) {
                switch feedModel.error {
                case .noNetwork:
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    Text("No Internet Connection")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    Text("Please check your connection and try again.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    retryButton
                    
                case .timeoutResponse:
                    Image(systemName: "timer")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    Text("Request Timed Out")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    // Using localizedDescription for more detail, or a custom suggestion.
                    Text(feedModel.error.localizedDescription ?? "Please try again.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    retryButton
                    
                case .version:
                    Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    Text(feedModel.error.localizedDescription ?? "App version not supported.")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    Text("Please update the app from the App Store.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    // No Retry button for version error
                    
                case .unhandledError(let msg):
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    Text("An unexpected error occurred.")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    Text(msg) // Display the specific error message
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    retryButton
                    
                // It's good practice to have a default for enums,
                // though FeedError is non-frozen, so compiler might not warn if all cases are covered.
                // Using @unknown default for future-proofing if FeedError adds cases.
                @unknown default:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    Text("An error occurred.")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    Text(feedModel.error.localizedDescription ?? "Please try again later.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    retryButton
                }
            }
            .padding() // Add some padding around the VStack for better spacing from screen edges

        default: // .done, .fetchingFeeds (Spinner is handled by blockingViewText)
            AppTabView()
                .onAppear(perform: {
                    Task {
                        do {
                            try await feedModel.fetchSourcesAsync()
                        } catch {
                            print("Error fetching sources on appear: \(error)")
                        }
                    }
                })
                .onReceive(feedModel.refreshTimer, perform: { _ in
                    print("Refresh timer triggered, fetching sources.")
                    Task {
                        do {
                            try await feedModel.fetchSourcesAsync()
                        } catch {
                            print("Error fetching sources on timer refresh: \(error)")
                        }
                    }
                })
                .blur(radius: feedModel.blockingViewText != nil ? 5.0 : 0)
                .disabled(feedModel.blockingViewText != nil)
                .overlay(
                    Group {
                        if let blockingViewText = feedModel.blockingViewText {
                            ProgressView(blockingViewText)
                                .padding()
                                .background(Color.secondary.opacity(0.3))
                                .cornerRadius(10)
                        } else {
                            EmptyView()
                        }
                    }
                    .animation(.easeInOut, value: feedModel.blockingViewText != nil) 
                )
        }
    }
    
    // Extracted retry button for reuse
    private var retryButton: some View {
        Button(action: {
            Task {
                await feedModel.loadSubscriptionsAsync(forceRefresh: true)
                // Optionally, attempt to fetch sources if subscriptions succeed
                // if feedModel.state == .done || feedModel.state == .fetchingFeeds { // Or a more specific success check
                //    try? await feedModel.fetchSourcesAsync()
                // }
            }
        }, label: {
            Text("Retry")
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static func errorPreview(error: FeedError) -> some View {
        let model = FeedModel(nosetup: true)
        model.state = .error
        model.error = error
        return ContentView().environmentObject(model)
    }
    
    static var previews: some View {
        Group {
            ContentView().environmentObject(FeedModel(nosetup: true))
                .previewDisplayName("Default State")
            
            errorPreview(error: .noNetwork)
                .previewDisplayName("No Network Error")
            
            errorPreview(error: .timeoutResponse)
                .previewDisplayName("Timeout Error")
            
            errorPreview(error: .version)
                .previewDisplayName("Version Error")
            
            errorPreview(error: .unhandledError(msg: "A detailed unhandled error message goes here."))
                .previewDisplayName("Unhandled Error")
        }
    }
}
