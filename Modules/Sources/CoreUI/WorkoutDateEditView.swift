//
//  WorkoutDateEditView.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-15.
//

import Core
import Data
import SwiftUI

struct WorkoutDateEditView: View {
    @Environment(\.dismiss) private var dismiss
    let store: WorkoutStore
    let workoutId: Workout.ID
    
    @State private var date: Date
    
    init(store: WorkoutStore, workoutId: Workout.ID) {
        self.store = store
        self.workoutId = workoutId
        
        let workout = store.workout(with: workoutId)
        
        _date = State(initialValue: workout?.date ?? Date())
    }
    
    var body: some View {
        Form {
            DatePicker("Workout Date", selection: $date, displayedComponents: .date)
                .datePickerStyle(.graphical)
        }
        .navigationTitle("Workout Date")
        .toolbar {
            Button("Done") {
                dismiss()
            }
        }
        .onChange(of: date) {
            guard var workout = store.workout(with: workoutId) else { return }
            workout.date = date
            store.updateWorkout(workout, createIfMissing: false)
        }
    }
}

#Preview {
    let store = WorkoutStore.preview()
    let workout = store.workouts.first!
    
    WorkoutDateEditView(store: store, workoutId: workout.id)
}
