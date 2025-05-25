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
            VStack(alignment: .center, spacing: 20) {
                Text(feedModel.error.localizedDescription).font(.title).padding()
                Text(feedModel.error.recoverySuggestion ?? "").font(.title3).padding()
                Button(action: {
                    Task {
                        // Retry loading subscriptions if in error state
                        await feedModel.loadSubscriptionsAsync(forceRefresh: true)
                        // Optionally, try to fetch sources again if subscriptions load successfully
                        // This depends on the desired app logic post-retry.
                        // if feedModel.state == .done {
                        //    try? await feedModel.fetchSourcesAsync()
                        // }
                    }
                }, label: {
                    Text("Retry")
                })
            }
        default: // .done, .fetchingFeeds (Spinner is handled by blockingViewText)
            AppTabView()
                .onAppear(perform: {
                    // Initial fetch of sources when the view appears
                    // This should ideally only run if sources haven't been fetched recently
                    // or if subscriptions are present.
                    // fetchSourcesAsync now has guards for this.
                    Task {
                        do {
                            try await feedModel.fetchSourcesAsync()
                        } catch {
                            // Handle or log error from onAppear fetch
                            print("Error fetching sources on appear: \(error)")
                        }
                    }
                })
                .onReceive(feedModel.refreshTimer, perform: { _ in
                    // Refresh Content While App State is in foreground based on timer
                    print("Refresh timer triggered, fetching sources.")
                    Task {
                        do {
                            try await feedModel.fetchSourcesAsync()
                        } catch {
                            // Handle or log error from timer refresh
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
                            // EmptyView() is more appropriate than Color.clear for no overlay
                            EmptyView()
                        }
                    }
                    // Consider .animation(.easeInOut, value: feedModel.blockingViewText) for smoother transitions
                    .animation(.easeInOut, value: feedModel.blockingViewText != nil) 
                )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Ensure the preview FeedModel is also @MainActor if it does async work directly in init
        // For previews, often a nosetup FeedModel is fine.
        ContentView().environmentObject(FeedModel(nosetup: true)) // Using nosetup for preview
    }
}
