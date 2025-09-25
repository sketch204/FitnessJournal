//
//  SetRow.swift
//  Modules
//
//  Created by Inal Gotov on 2025-08-31.
//

import Core
import Data
import SwiftUI

struct SetRow: View {
    let store: WorkoutStore
    let set: Exercise.Set
    
    var body: some View {
        HStack {
            Text("\(set.repetitions) Reps")
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            WeightView(weight: set.weight)
        }
    }
}

#Preview {
    let store = WorkoutStore.preview()
    let workout = store.workouts.first!
    let exercise = store.exercises(for: workout.id)!.first!
    let sets = store.sets(for: workout.id, in: exercise.id)!
    
    List(sets) { set in
        SetRow(
            store: store,
            set: set
        )
    }
}
