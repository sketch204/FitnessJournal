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
    @AppStorage("__dataStore") private var dataStore: PersistenceType = .file
    var persistor: WorkoutStorePersistor {
        switch dataStore {
        case .file: .file
        case .memory: .memory
        case .preview: .preview()
        }
    }
    
    @State var store: WorkoutStore?
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let store {
                    RootView(workoutStore: store)
                } else {
                    ProgressView()
                }
            }
            .onAppear {
                store = WorkoutStore(persistor: persistor)
            }
        }
    }
}
