//
//  NavigateToExerciseAction.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-25.
//

import Core
import Data
import SwiftUI

struct NavigateToExerciseAction: AppAction {
    let navigation: ExerciseNavigation
}

extension NavigateToExerciseAction {
    fileprivate struct Handler: ViewModifier {
        @Environment(\.appActions) var appActions
        
        let store: WorkoutStore
        @Binding var path: NavigationPath
        
        func body(content: Content) -> some View {
            content
                .onReceive(appActions.events(for: NavigateToExerciseAction.self)) { action in
                    print("Navigating to \(action.navigation)")
                    path.append(action.navigation)
                }
                .navigationDestination(for: ExerciseNavigation.self) { navigation in
                    ExerciseView(store: store, navigation: navigation)
                }
        }
    }
}

extension View {
    func registerExerciseNavigationActionHandler(store: WorkoutStore, path: Binding<NavigationPath>) -> some View {
        modifier(NavigateToExerciseAction.Handler(store: store, path: path))
    }
}
