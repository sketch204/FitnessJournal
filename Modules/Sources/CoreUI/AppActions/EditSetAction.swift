//
//  EditSetAction.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-30.
//

import Core
import Data
import SwiftUI

struct EditSetAction: AppAction, Hashable, Identifiable {
    let navigation: SetNavigation
    
    var id: SetNavigation {
        navigation
    }
    
    init(navigation: SetNavigation) {
        self.navigation = navigation
    }
    
    init(workoutId: Workout.ID, segmentId: Segment.ID, setId: Segment.Set.ID) {
        self.init(navigation: SetNavigation(workoutId: workoutId, segmentId: segmentId, setId: setId))
    }
}

fileprivate extension EditSetAction {
    struct Handler: ViewModifier {
        @Environment(\.appActions) var appActions
        
        @State private var action: EditSetAction?
        
        let store: WorkoutStore
        
        func body(content: Content) -> some View {
            content
                .onReceive(appActions.events(for: EditSetAction.self), perform: { action in
                    self.action = action
                })
                .sheet(item: $action) { action in
                    NavigationStack {
                        SetEditView(
                            store: store,
                            navigation: action.navigation
                        )
                    }
                    .presentationDetents([.medium, .large])
                }
        }
    }
}

extension View {
    func registerEditSetHandler(store: WorkoutStore) -> some View {
        modifier(EditSetAction.Handler(store: store))
    }
}
