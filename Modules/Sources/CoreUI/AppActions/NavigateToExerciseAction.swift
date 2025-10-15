//
//  NavigateToExerciseAction.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-30.
//

import Core
import Data
import SwiftUI

struct NavigateToExerciseAction: AppAction {
    let exerciseId: Exercise.ID
}

fileprivate extension NavigateToExerciseAction {
    struct Handler: ViewModifier {
        @Environment(\.appActions) var appActions
        
        let store: WorkoutStore
        @Binding var navigationPath: NavigationPath
        
        func body(content: Content) -> some View {
            content
                .onReceive(appActions.events(for: NavigateToExerciseAction.self)) { action in
                    navigationPath.append(action.exerciseId)
                }
                .navigationDestination(for: Exercise.ID.self) { exerciseId in
                    ExerciseView(store: store, exerciseId: exerciseId)
                }
        }
    }
}

extension View {
    func registerExerciseNavigationHandler(store: WorkoutStore, path: Binding<NavigationPath>) -> some View {
        modifier(NavigateToExerciseAction.Handler(store: store, navigationPath: path))
    }
}

extension AppActions {
    func navigate(to exerciseId: Exercise.ID) {
        perform(NavigateToExerciseAction(exerciseId: exerciseId))
    }
}
