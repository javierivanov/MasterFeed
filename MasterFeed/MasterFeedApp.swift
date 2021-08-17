//
//  MasterFeedApp.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 29-03-21.
//

import SwiftUI
import OAuthSwift
import BackgroundTasks

@main
struct MasterFeedApp: App {
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var feedModel = FeedModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(feedModel)
        }
        .onChange(of: scenePhase, perform: { scene in
            if scene == .background {
                print("background")
                appDelegate.feedModel = feedModel
                appDelegate.scheduleAppRefresh()
                //appDelegate.scheduleAppComputing()
            }
        })
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    
    var feedModel: FeedModel?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Registering")
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.jfuentes.MasterFeed.refresh", using: nil) { task in
            self.handleRefresh(task: task as! BGAppRefreshTask)
        }
        
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.jfuentes.MasterFeed.sort", using: nil) { task in
//            self.handleComputing(task: task as! BGProcessingTask)
//        }
        
        return true
    }
    
    
    func scheduleAppRefresh() {
        
        let request = BGAppRefreshTaskRequest(identifier: "com.jfuentes.MasterFeed.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60) // Fetch no earlier than 15 minutes from now
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Scheduled refresh")
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
//    func scheduleAppComputing() {
//        let request = BGAppRefreshTaskRequest(identifier: "com.jfuentes.MasterFeed.sort")
//        request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60) // Fetch no earlier than 15 minutes from now
//        do {
//            try BGTaskScheduler.shared.submit(request)
//        } catch {
//            print("Could not schedule app refresh: \(error)")
//        }
//    }
    
    
    func handleRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        guard  let feedModel = feedModel else {
            return
        }
        
        feedModel.fetchSources()
    }
    
//    func handleComputing(task: BGProcessingTask) {
//
//    }
}
