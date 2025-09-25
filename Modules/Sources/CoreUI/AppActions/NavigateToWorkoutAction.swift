//
//  NavigateAction.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-25.
//

import Core
import Data
import SwiftUI

struct NavigateToWorkoutAction: AppAction {
    let workoutId: Workout.ID
}

fileprivate extension NavigateToWorkoutAction {
    struct Handler: ViewModifier {
        @Environment(\.appActions) private var appActions

        let store: WorkoutStore
        @Binding var navigationPath: NavigationPath
        
        func body(content: Content) -> some View {
            content
                .onReceive(appActions.events(for: NavigateToWorkoutAction.self)) { action in
                    navigationPath.append(action.workoutId)
                }
                .navigationDestination(for: Workout.ID.self) { id in
                    WorkoutView(store: store, workoutId: id)
                }
        }
    }
}

extension View {
    func registerWorkoutNavigationHandler(store: WorkoutStore, path: Binding<NavigationPath>) -> some View {
        modifier(NavigateToWorkoutAction.Handler(store: store, navigationPath: path))
    }
}
