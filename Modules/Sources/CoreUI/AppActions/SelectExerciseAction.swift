//
//  SelectExerciseAction.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-30.
//

import Core
import Data
import SwiftUI

struct SelectExerciseAction: AppAction, Hashable, Identifiable {
    let id: UUID = UUID()
    let onSelect: (Exercise) -> Void
    
    static func == (lhs: SelectExerciseAction, rhs: SelectExerciseAction) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

fileprivate extension SelectExerciseAction {
    struct Handler: ViewModifier {
        @Environment(\.appActions) private var appActions
        
        @State private var nestedAppActions = AppActions()
        @State private var path = NavigationPath()
        @State private var action: SelectExerciseAction?
        
        let store: WorkoutStore
        
        func body(content: Content) -> some View {
            content
                .onReceive(appActions.events(for: SelectExerciseAction.self)) { event in
                    if action == nil {
                        action = event
                    }
                }
                .sheet(item: $action) { action in
                    NavigationStack(path: $path) {
                        ExerciseLookupView(store: store, onSelect: action.onSelect)
                            .registerExerciseNavigationHandler(store: store, path: $path)
                    }
                    .environment(\.appActions, nestedAppActions)
                }
        }
    }
}

extension View {
    func registerSelectExerciseHandler(store: WorkoutStore) -> some View {
        modifier(SelectExerciseAction.Handler(store: store))
    }
}

extension AppActions {
    func selectExercise(_ onSelect: @escaping (Exercise) -> Void) {
        perform(SelectExerciseAction(onSelect: onSelect))
    }
}
