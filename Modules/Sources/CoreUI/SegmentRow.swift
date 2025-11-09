//
//  SegmentRow.swift
//  Modules
//
//  Created by Inal Gotov on 2025-08-31.
//

import Core
import Data
import SwiftUI

struct SegmentRow: View {
    let store: WorkoutStore
    let segment: Segment

    var exercise: Exercise {
        store.exercise(with: segment.exercise)
        ?? Exercise(name: "Exercise not found")
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading) {
                Text(exercise.name)
                    .multilineTextAlignment(.leading)
                    .font(.title)

                Text("\(segment.sets.count) Sets")
                    .multilineTextAlignment(.leading)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
                
            Spacer()
            
            if let weight = segment.displayWeight {
                WeightView(weight: weight)
            }
        }
    }
}

#Preview("Default") {
    PreviewingStore { store in
        let workout = store.workouts.first!

        List(workout.segments) { segment in
            SegmentRow(store: store, segment: segment)
        }
        .listStyle(.plain)
    }
}
