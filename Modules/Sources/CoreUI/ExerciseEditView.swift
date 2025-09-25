//
//  ExerciseEditView.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-25.
//

import Core
import Data
import SwiftUI

struct ExerciseEditView: View {
    let store: WorkoutStore
    let workoutId: Workout.ID
    let exerciseId: Exercise.ID?
    let onSave: ((Exercise) -> Void)?
    
    @State private var name: String
    @State private var comment: String
    
    init(
        store: WorkoutStore,
        workoutId: Workout.ID,
        exerciseId: Exercise.ID? = nil,
        onSave: ((Exercise) -> Void)? = nil,
    ) {
        self.store = store
        self.workoutId = workoutId
        self.exerciseId = exerciseId
        self.onSave = onSave

        if let exerciseId, let exercise = store.exercise(with: exerciseId, for: workoutId) {
            _name = State(initialValue: exercise.name)
            _comment = State(initialValue: exercise.comment)
        } else {
            _name = State(initialValue: "")
            _comment = State(initialValue: "")
        }
    }
    
    init(
        store: WorkoutStore,
        navigation: ExerciseNavigation,
        onSave: ((Exercise) -> Void)? = nil,
    ) {
        self.init(
            store: store,
            workoutId: navigation.workoutId,
            exerciseId: navigation.exerciseId,
            onSave: onSave
        )
    }
    
    var body: some View {
        Form {
            TextField("Name", text: $name, prompt: Text("Bench Press"))
            
            Section("Comment") {
                TextEditor(text: $comment)
                    .overlay(alignment: .topLeading) {
                        if comment.isEmpty {
                            Text("Workout description")
                                .foregroundStyle(.placeholder)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                    }
            }
        }
        .onDisappear {
            guard !name.isEmpty else { return }
            
            let exercise = store.updateExercise(
                with: exerciseId,
                for: workoutId
            ) { exercise in
                exercise.name = name
            }
            
            exercise.map { onSave?($0) }
        }
    }
}

#Preview {
    let store = WorkoutStore.preview()
    let workout = store.workouts.first!
    let exercise = store.exercises(for: workout.id)!.first!
    
    ExerciseEditView(
        store: store,
        navigation: ExerciseNavigation(
            workoutId: workout.id,
            exerciseId: exercise.id
        )
    )
}
