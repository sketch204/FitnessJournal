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
                    NavigationStack {
                        ExerciseLookupView(store: store, onSelect: action.onSelect)
                    }
                }
        }
    }
}

extension View {
    func registerSelectExerciseHandler(store: WorkoutStore) -> some View {
        modifier(SelectExerciseAction.Handler(store: store))
    }
}
