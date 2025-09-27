//
//  SegmentEditView.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-25.
//

//import Core
//import Data
//import SwiftUI
//
//struct SegmentEditView: View {
//    @Environment(\.dismiss) private var dismiss
//    
//    let store: WorkoutStore
//    let workoutId: Workout.ID
//    let exerciseId: Exercise.ID?
//    let onSave: ((Exercise) -> Void)?
//    
//    @State private var originalExercise: Exercise?
//    
//    @State private var name: String
//    
//    private var isEditing: Bool {
//        originalExercise != nil
//    }
//    
//    init(
//        store: WorkoutStore,
//        workoutId: Workout.ID,
//        exerciseId: Exercise.ID? = nil,
//        onSave: ((Exercise) -> Void)? = nil,
//    ) {
//        self.store = store
//        self.workoutId = workoutId
//        self.exerciseId = exerciseId
//        self.onSave = onSave
//
//        if let exerciseId, let exercise = store.exercise(with: exerciseId, for: workoutId) {
//            _originalExercise = State(initialValue: exercise)
//            _name = State(initialValue: exercise.name)
//        } else {
//            _originalExercise = State(initialValue: nil)
//            _name = State(initialValue: "")
//        }
//    }
//    
//    init(
//        store: WorkoutStore,
//        navigation: ExerciseNavigation,
//        onSave: ((Exercise) -> Void)? = nil,
//    ) {
//        self.init(
//            store: store,
//            workoutId: navigation.workoutId,
//            exerciseId: navigation.exerciseId,
//            onSave: onSave
//        )
//    }
//    
//    var body: some View {
//        Form {
//            TextField("Name", text: $name, prompt: Text("Bench Press"))
//        }
//        .navigationTitle(isEditing ? "Edit Exercise" : "Create Exercise")
//        .toolbar {
//            Button("Done") {
//                dismiss()
//            }
//        }
//        .onChange(of: name) {
//            guard isEditing else { return }
//            
//            saveExercise()
//        }
//        .onDisappear {
//            let exercise = saveExercise()
//            
//            let didDelete = cleanUpEmpty(exercise: exercise)
//            
//            if !didDelete {
//                exercise.map { onSave?($0) }
//            }
//        }
//    }
//    
//    @discardableResult
//    private func saveExercise() -> Exercise? {
//        let exercise = store.updateExercise(
//            with: exerciseId,
//            for: workoutId
//        ) { exercise in
//            exercise.name = name
//        }
//        
//        return exercise
//    }
//    
//    /// Cleans up the exercise. For newly created ones, if name is empty it will delete it. For edited ones, if name is empty it will reset it.
//    /// - Parameter exercise: The exercise to cleanup
//    /// - Returns: True if exercise is delete
//    private func cleanUpEmpty(exercise: Exercise?) -> Bool {
//        guard let exercise,
//              name.isEmpty || exercise.name.isEmpty
//        else { return false }
//        
//        if isEditing, let originalExercise {
//            store.updateExercise(originalExercise, for: workoutId, createIfMissing: false)
//            return false
//        } else {
//            store.deleteExercise(exercise, for: workoutId)
//            return true
//        }
//    }
//}
//
//#Preview("Edit Exercise") {
//    let store = WorkoutStore.preview()
//    let workout = store.workouts.first!
//    let exercise = store.exercises(for: workout.id)!.first!
//    
//    NavigationStack {
//        SegmentEditView(
//            store: store,
//            workoutId: workout.id,
//            exerciseId: exercise.id
//        )
//    }
//}
//
//#Preview("Create Exercise") {
//    let store = WorkoutStore.preview()
//    let workout = store.workouts.first!
//    
//    NavigationStack {
//        SegmentEditView(
//            store: store,
//            workoutId: workout.id
//        )
//    }
//}
