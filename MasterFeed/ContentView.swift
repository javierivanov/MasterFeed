//
//  ContentView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 10-05-21.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var feedModel: FeedModel
    
    var body: some View {

        switch feedModel.state {
        case .preparing:
        // checking for user
            ProgressView("MasterFeed")
        case .onboarding:
        // no user
            OnboardingView()
        case .fetchingSubscriptions:
        // fetching subs or feeds
            ProgressView("Refreshing Subscriptions")
        case .error:
            Text("UnexpectedError").font(.title)
        default:
            // display feed
            AppTabView()
                .onAppear(perform: {
                    feedModel.fetchSources()
                })
                .onReceive(feedModel.refreshTimer, perform: { _ in
                    // Refresh Content While App State is in foreground.
                    feedModel.fetchSources()
                })
                .blur(radius: feedModel.blockingViewText != nil ? 5.0 : 0)
                .disabled(feedModel.blockingViewText != nil)
                .overlay(
                    Group {
                        if let blockingViewText = feedModel.blockingViewText {
                            ProgressView(blockingViewText)
                        } else {
                            Color.clear
                        }
                    }.animation(.easeInOut))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(FeedModel())
    }
}
