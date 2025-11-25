//
//  ContentView.swift
//  BabyFeedTracker
//
//  Created by Akim Gauthier  on 24/11/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {

    var body: some View {
        InteractiveBottleView()
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
