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
    @StateObject var feedModel = FeedModel() // Already @MainActor
    
    init() {
        registerBackgroundTasks()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView() // ContentView will call feedModel.fetchSourcesAsync()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(feedModel)
        }
        .onChange(of: scenePhase, perform: { newScenePhase in
            if newScenePhase == .background {
                print("App moved to background, scheduling refresh task.")
                scheduleAppRefresh()
            }
        })
    }
    
    func registerBackgroundTasks() {
        print("Registering background tasks")
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.jfuentes.MasterFeed.refresh", using: nil) { task in
            // Ensure task is an BGAppRefreshTask
            guard let refreshTask = task as? BGAppRefreshTask else {
                print("Wrong task type registered or received.")
                task.setTaskCompleted(success: false)
                return
            }
            
            print("Handling background refresh task.")
            self.handleRefresh(task: refreshTask)
        }
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.jfuentes.MasterFeed.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: FeedModel.refreshTime) // Use refreshTime from FeedModel
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background refresh task scheduled.")
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    // Async handler for the background task
    func handleRefresh(task: BGAppRefreshTask) {
        // Schedule the next refresh task
        scheduleAppRefresh()
        
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        
        // Task expiration handler
        task.expirationHandler = {
            operationQueue.cancelAllOperations()
            // Mark the task as completed with failure if it expires
            // This might happen if the async work takes too long
            print("Background task expired.")
            task.setTaskCompleted(success: false) 
        }

        // Perform the refresh operation asynchronously
        print("Starting background fetchSourcesAsync.")
        
        // Create a new Task to run the async function
        let refreshOperation = Task {
            do {
                try await feedModel.fetchSourcesAsync()
                if !Task.isCancelled {
                    print("Background refresh task completed successfully.")
                    task.setTaskCompleted(success: true)
                } else {
                    print("Background refresh task was cancelled.")
                    task.setTaskCompleted(success: false)
                }
            } catch {
                print("Background refresh task failed with error: \(error)")
                task.setTaskCompleted(success: false)
            }
        }
        
        // Add a way to cancel the Task if the BGTask itself is cancelled (e.g. by expirationHandler)
        // However, direct cancellation of a Swift Task from outside is complex.
        // The expirationHandler should setTaskCompleted.
        // We rely on fetchSourcesAsync to respect Task.isCancelled internally if it's a long operation.
        _ = refreshOperation // Keep a reference if needed, or manage cancellation
    }
}
