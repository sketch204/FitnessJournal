//
//  EditWorkoutAction.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-30.
//

import Core
import Data
import SwiftUI

struct EditWorkoutAction: AppAction, Hashable, Identifiable {
    let workoutId: Workout.ID
    
    var id: Workout.ID {
        workoutId
    }
}

fileprivate extension EditWorkoutAction {
    struct Handler: ViewModifier {
        @Environment(\.appActions) var appActions
        
        @State private var action: EditWorkoutAction?
        
        let store: WorkoutStore
        
        func body(content: Content) -> some View {
            content
                .onReceive(appActions.events(for: EditWorkoutAction.self)) { action in
                    self.action = action
                }
                .sheet(item: $action) { action in
                    NavigationStack {
                        WorkoutDateEditView(store: store, workoutId: action.workoutId)
                    }
                    .presentationDetents([.medium])
                }
        }
    }
}

extension View {
    func registerEditWorkoutHandler(store: WorkoutStore) -> some View {
        modifier(EditWorkoutAction.Handler(store: store))
    }
}
