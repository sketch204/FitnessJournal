//
//  ExerciseRow.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-27.
//

import Core
import Data
import SwiftUI

struct ExerciseRow: View {
    let store: WorkoutStore
    let exerciseId: Exercise.ID
    
    var exercise: Exercise? {
        store.exercise(with: exerciseId)
    }
    
    var maxWeight: Weight? {
        store.maxWeight(for: exerciseId)
    }
    
    var body: some View {
        if let exercise {
            HStack {
                Text(exercise.name)
                    .font(.title2)
                
                if let maxWeight {
                    Spacer()
                    WeightView(weight: maxWeight)
                }
            }
        } else {
            Text("Exercise not found")
                .font(.title2)
                .italic()
        }
    }
}
