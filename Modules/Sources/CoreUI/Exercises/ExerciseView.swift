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
    
    var exerciseHasNoData: Bool {
        store.segments(with: exerciseId).isEmpty
    }
    
    var sections: [Section] {
        store.sets(with: exerciseId)
            .map { (key: Date, value: [Segment.Set]) in
                Section(date: key, sets: value)
            }
            .sorted { $0.date > $1.date }
            .filter { !$0.sets.isEmpty }
    }
    
    var chartData: [(date: String, value: Double)] {
        store.sets(with: exerciseId)
            .compactMap { (date: Date, sets: [Segment.Set]) -> (date: Date, value: Double)? in
                guard let max = sets.map(\.weight.totalWeight).max() else {
                     return nil
                }
                return (date, max)
            }
            .sorted { $0.date > $1.date }
            .map { pair in
                (pair.date.formatted(date: .abbreviated, time: .omitted), pair.value)
            }
    }
    
    var body: some View {
        if let exercise {
            Group {
                if exerciseHasNoData {
                    ContentUnavailableView(
                        "No data for exercise!",
                        systemImage: "questionmark.square.dashed",
                        description: Text("Add some sets with this exercise to view the stats here")
                    )
                } else {
                    content(exercise)
                }
            }
            .navigationTitle(exercise.name)
        } else {
            ContentUnavailableView("Exercise not found!", systemImage: "questionmark.circle.dashed")
        }
    }
    
    @ViewBuilder
    func content(_ exercise: Exercise) -> some View {
        VStack {
            Chart(chartData, id: \.date) { data in
                BarMark(
                    x: .value("Date", data.date),
                    y: .value("Weight", data.value),
                    width: .fixed(60)
                )
                .cornerRadius(10)
            }
            .chartScrollableAxes(.horizontal)
            
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
    }
}

#Preview("Default") {
    let workout = Workout.sample
    let exercise = workout.segments.first!.exercise
    let store = WorkoutStore.preview(workouts: [workout])
    
    NavigationStack {
        ExerciseView(store: store, exerciseId: exercise.id)
    }
}

#Preview("Unknown") {
    let store = WorkoutStore.preview()
    
    NavigationStack {
        ExerciseView(store: store, exerciseId: .new)
    }
}

#Preview("Empty") {
    let exercise = Exercise(name: "Empty Exercise")
    let store = WorkoutStore.preview(extraExercises: [exercise])
    
    NavigationStack {
        ExerciseView(store: store, exerciseId: exercise.id)
    }
}
