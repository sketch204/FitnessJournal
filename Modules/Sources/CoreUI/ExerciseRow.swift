//
//  ExerciseRow.swift
//  Modules
//
//  Created by Inal Gotov on 2025-08-31.
//

import Data
import SwiftUI

struct ExerciseRow: View {
    let exercise: Exercise
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading) {
                Text(exercise.name)
                    .multilineTextAlignment(.leading)
                    .font(.title)
                
                Text("\(exercise.sets.count) Sets")
                    .multilineTextAlignment(.leading)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
                
            Spacer()
            
            if let weight = exercise.displayWeight {
                WeightView(weight: weight)
            }
        }
    }
}

#Preview("Default") {
    List {
        ExerciseRow(exercise: .sampleBenchPress)
        ExerciseRow(exercise: .sampleDeadlifts)
        ExerciseRow(exercise: .sampleChestFlys)
    }
    .listStyle(.plain)
}
