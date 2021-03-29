//
//  MasterFeedApp.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 29-03-21.
//

import SwiftUI

@main
struct MasterFeedApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
