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
    let set: Segment.Set
    
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
    let segment = store.segments(for: workout.id)!.first!
    let sets = store.sets(segmentId: segment.id, workoutId: workout.id)!
    
    List(sets) { set in
        SetRow(
            store: store,
            set: set
        )
    }
}
