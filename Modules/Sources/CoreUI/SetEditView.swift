//
//  SetEditView.swift
//  Modules
//
//  Created by Inal Gotov on 2025-08-31.
//

import Core
import Data
import SwiftUI

struct SetEditView: View {
    let store: WorkoutStore
    let navigation: SetNavigation

    @State private var repetitions: Int
    @State private var weight: Weight
    
    init(store: WorkoutStore, navigation: SetNavigation) {
        self.store = store
        self.navigation = navigation
        
        let set = store.set(for: navigation)
        _repetitions = State(initialValue: set?.repetitions ?? 0)
        _weight = State(initialValue: set?.weight ?? .init(distribution: .total(0), units: .pounds))
    }
    
    var body: some View {
        Form {
            Stepper("\(repetitions) Repetitions", value: $repetitions, in: 1...100)
            
            WeightEditSection(weight: $weight)
        }
        .onChange(of: weight) {
            store.updateSet(
                with: navigation.setId,
                for: navigation.workoutId,
                in: navigation.exerciseId
            ) { set in
                set.weight = weight
            }
        }
        .onChange(of: repetitions) {
            store.updateSet(
                with: navigation.setId,
                for: navigation.workoutId,
                in: navigation.exerciseId
            ) { set in
                set.repetitions = repetitions
            }
        }
        .navigationTitle("Set")
    }
}

#Preview {
    let store = WorkoutStore.preview()
    let workout = store.workouts.first!
    let exercise = store.exercises(for: workout.id)!.first!
    let set = store.sets(for: workout.id, in: exercise.id)!.first!
    
    SetEditView(
        store: store,
        navigation: SetNavigation(
            workoutId: workout.id,
            exerciseId: exercise.id,
            setId: set.id
        )
    )
}
