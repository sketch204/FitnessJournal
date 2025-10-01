//
//  ExerciseView.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-30.
//

import Charts
import Core
import Data
import SwiftUI

struct ExerciseView: View {
    struct Section: Hashable, Identifiable {
        let date: Date
        let sets: [Segment.Set]
        
        var id: Date { date }
    }
    
    let store: WorkoutStore
    let exerciseId: Exercise.ID
    
    var exercise: Exercise? {
        store.exercise(with: exerciseId)
    }
    
    var sections: [Section] {
        store.sets(with: exerciseId)
            .map { (key: Date, value: [Segment.Set]) in
                Section(date: key, sets: value)
            }
            .sorted { $0.date > $1.date }
    }
    
    var chartData: [(x: Date, y: Double)] {
        store.sets(with: exerciseId)
            .compactMap { (key: Date, value: [Segment.Set]) in
                guard let max = value.map(\.weight.totalWeight).max() else {
                     return nil
                }
                return (key, max)
            }
    }
    
    var body: some View {
        if let exercise {
            VStack {
                Chart {
                    ForEach(chartData, id: \.x) { data in
                        LineMark(
                            x: .value("Date", data.x),
                            y: .value("Weight", data.y)
                        )
                    }
                }
                
                List {
                    ForEach(sections) { section in
                        SwiftUI.Section(section.date.formatted(date: .long, time: .shortened)) {
                            ForEach(section.sets) { set in
                                SetRow(set: set)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle(exercise.name)
        } else {
            ContentUnavailableView("Exercise not found!", systemImage: "questionmark.circle.dashed")
        }
    }
}

#Preview {
    let workout = Workout.sample
    let exercise = workout.segments.first!.exercise
    let store = WorkoutStore.preview(workouts: [workout])
    
    NavigationStack {
        ExerciseView(store: store, exerciseId: exercise.id)
    }
}
