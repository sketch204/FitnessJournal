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

#Preview {
    @Previewable @State var store = WorkoutStore.preview()

    List {
        WorkoutRow(store: store, workout: .sample)
        WorkoutRow(store: store, workout: .sample)
        WorkoutRow(store: store, workout: .sample)
    }
    .listStyle(.plain)
}
