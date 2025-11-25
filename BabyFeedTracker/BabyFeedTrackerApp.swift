//
//  BabyFeedTrackerApp.swift
//  BabyFeedTracker
//
//  Created by Akim Gauthier  on 24/11/2025.
//

import SwiftUI
import CoreData

@main
struct BabyFeedTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
