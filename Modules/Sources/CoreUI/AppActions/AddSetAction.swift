//
//  AddSetAction.swift
//  Modules
//
//  Created by Inal Gotov on 2025-10-08.
//

import Core
import Data
import SwiftUI

struct AddSetAction: AppAction, Hashable, Identifiable {
    let navigation: SegmentNavigation
    
    var id: SegmentNavigation {
        navigation
    }
    
    init(navigation: SegmentNavigation) {
        self.navigation = navigation
    }
    
    init(workoutId: Workout.ID, segmentId: Segment.ID) {
        self.init(navigation: SegmentNavigation(workoutId: workoutId, segmentId: segmentId))
    }
}

fileprivate extension AddSetAction {
    struct Handler: ViewModifier {
        @Environment(\.appActions) var appActions
        
        let store: WorkoutStore
        
        func body(content: Content) -> some View {
            content
                .onReceive(appActions.events(for: AddSetAction.self)) { action in
                    let set = store.createSet(
                        newSet(navigation: action.navigation),
                        segmentId: action.navigation.segmentId,
                        workoutId: action.navigation.workoutId
                    )
                    
                    guard let set else { return }
                    
                    appActions.perform(
                        EditSetAction(
                            workoutId: action.navigation.workoutId,
                            segmentId: action.navigation.segmentId,
                            setId: set.id
                        )
                    )
                }
        }
        
        private func newSet(navigation: SegmentNavigation) -> Segment.Set {
            guard let segment = store.segment(for: navigation),
                  let latestSet = store.latestSet(with: segment.exercise)
            else {
                return Segment.Set(
                    weight: Weight(distribution: .total(50), units: .pounds),
                    repetitions: 0
                )
            }
            
            return latestSet.duplicated(newId: true)
        }
    }
}

extension View {
    func registerAddSetHandler(store: WorkoutStore) -> some View {
        modifier(AddSetAction.Handler(store: store))
    }
}

extension AppActions {
    func addSet(navigation: SegmentNavigation) {
        perform(AddSetAction(navigation: navigation))
    }
    
    func addSet(workoutId: Workout.ID, segmentId: Segment.ID) {
        perform(AddSetAction(workoutId: workoutId, segmentId: segmentId))
    }
}
