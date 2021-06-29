//
//  MasterFeedApp.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 29-03-21.
//

import SwiftUI
import OAuthSwift

@main
struct MasterFeedApp: App {
    
    let persistenceController = PersistenceController.shared
    @StateObject var feedModel = FeedModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(feedModel)
        }
    }
}
