//
//  WorkoutRow.swift
//  Modules
//
//  Created by Inal Gotov on 2025-08-31.
//

import Core
import Data
import SwiftUI

struct WorkoutRow: View {
    let store: WorkoutStore
    let workout: Workout

    var exerciseSummary: String {
        workout.segments.compactMap {
            store.exercise(with: $0.exercise)
        }
        .map(\.name)
        .joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                Text(workout.date, format: .dateTime.day().month().weekday())
                    .font(.title)
                
                
                Spacer()
                
                Text(workout.date, format: .relative(presentation: .named))
                    .foregroundStyle(.secondary)
            }

            if !exerciseSummary.isEmpty {
                Text(exerciseSummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#if DEBUG

#Preview {
    PreviewingStore { store in
        let workout = store.workouts.first!

        List {
            WorkoutRow(store: store, workout: workout)
            WorkoutRow(store: store, workout: workout)
            WorkoutRow(store: store, workout: workout)
        }
        .listStyle(.plain)
    }
}

#endif
