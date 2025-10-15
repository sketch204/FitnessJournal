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
    @Environment(\.appActions) var appActions
    
    let store: WorkoutStore
    let exerciseId: Exercise.ID
    
    var exercise: Exercise? {
        store.exercise(with: exerciseId)
    }
    
    var latestSegment: Segment? {
        store.latestSegment(with: exerciseId)
    }
    
    var displayWeight: Weight? {
        latestSegment?.displayWeight ?? store.maxWeight(for: exerciseId)
    }
    
    var body: some View {
        if let exercise {
            HStack {
                VStack(alignment: .leading) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(exercise.name)
                            .font(.title2)
                        
                        if let latestSegment,
                           let compositionString = latestSegment.compositionString
                        {
                            Text("(\(compositionString))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if let displayWeight {
                        WeightView(weight: displayWeight)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Button {
                    openExercisesView(for: exerciseId)
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.borderless)
            }
        } else {
            Text("Exercise not found")
                .font(.title2)
                .italic()
        }
    }
    
    private func openExercisesView(for exerciseId: Exercise.ID) {
        appActions.navigate(to: exerciseId)
    }
}

#Preview {
    @Previewable @State var store = WorkoutStore.preview()
    
    let exercises = store.exercises.sorted(by: { $0.name < $1.name })
    
    List(exercises) { exercise in
        ExerciseRow(store: store, exerciseId: exercise.id)
    }
    .listStyle(.plain)
}
