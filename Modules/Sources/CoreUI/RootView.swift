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
                .registerSegmentNavigationHandler(store: store, path: $navigationPath)
                .registerExerciseNavigationHandler(store: store, path: $navigationPath)
                .registerSelectExerciseHandler(store: store)
                .registerEditWorkoutHandler(store: store)
                .registerEditSetHandler(store: store)
                .registerAddSetHandler(store: store)
        }
        .environment(\.appActions, appActions)
    }
}

#Preview {
    @Previewable @State var store = WorkoutStore.previewFile()
    
    RootView(workoutStore: store)
}
