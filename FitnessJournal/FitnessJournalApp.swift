//
//  FitnessJournalApp.swift
//  FitnessJournal
//
//  Created by Inal Gotov on 2025-08-31.
//

import Core
import CoreUI
import SwiftUI

@main
struct FitnessJournalApp: App {
    let store = WorkoutStore.preview()
    
    var body: some Scene {
        WindowGroup {
            RootView(workoutStore: store)
        }
    }
}
