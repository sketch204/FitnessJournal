//
//  WorkoutRow.swift
//  Modules
//
//  Created by Inal Gotov on 2025-08-31.
//

import Data
import SwiftUI

struct WorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                Text(workout.date, format: .dateTime.day().month().weekday())
                    .font(.title)
                
                
                Spacer()
                
                Text(workout.date, format: .relative(presentation: .named))
                    .foregroundStyle(.secondary)
            }
            
            Text(workout.segments.map(\.exercise.name).joined(separator: ", "))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    List {
        WorkoutRow(workout: .sample)
        WorkoutRow(workout: .sample)
        WorkoutRow(workout: .sample)
    }
    .listStyle(.plain)
}
