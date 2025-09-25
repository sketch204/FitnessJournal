//
//  RootView.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-25.
//

import Core
import Data
import SwiftUI

public struct RootView: View {
    @State private var navigationPath = NavigationPath()
    private let store: WorkoutStore
    
    private let appActions = AppActions()
    
    public init(workoutStore: WorkoutStore) {
        self.store = workoutStore
    }
    
    public var body: some View {
        NavigationStack(path: $navigationPath) {
            WorkoutsListView(store: store)
                .registerWorkoutNavigationHandler(store: store, path: $navigationPath)
                .registerExerciseNavigationActionHandler(store: store, path: $navigationPath)
        }
        .environment(\.appActions, appActions)
    }
}

#Preview {
    let store = WorkoutStore.preview()
    
    RootView(workoutStore: store)
}
