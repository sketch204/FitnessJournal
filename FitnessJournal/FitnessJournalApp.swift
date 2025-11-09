//
//  FitnessJournalApp.swift
//  FitnessJournal
//
//  Created by Inal Gotov on 2025-08-31.
//

import Core
import CoreUI
import Persistance
import SwiftUI

@main
struct FitnessJournalApp: App {
    let persistor: FileWorkoutStorePersistor

    @State var store: WorkoutStore
    @State var isDebugMenuPresented: Bool = false

    init() {
        let persistor = FileWorkoutStorePersistor.file

        self.persistor = persistor
        _store = State(initialValue: WorkoutStore(persistor: persistor))
    }

    var body: some Scene {
        WindowGroup {
            Group {
                RootView(workoutStore: store)
                    .onTapGesture(count: 5) {
                        isDebugMenuPresented = true
                    }
                    .sheet(isPresented: $isDebugMenuPresented) {
                        DebugMenu(store: store, persistor: persistor)
                    }
            }
            .overlay(alignment: .top) {
                if store.isPersistentWritesDisabled {
                    Text("Read-Only Mode")
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red.gradient)
                        }
                }
            }
        }
    }
}
