//
//  ExerciseView.swift
//  Modules
//
//  Created by Inal Gotov on 2025-08-31.
//

import Core
import Data
import SwiftUI

struct ExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    
    let store: WorkoutStore
    let navigation: ExerciseNavigation
    
    var workout: Workout? {
        store.workouts.first(where: { $0.id == navigation.workoutId })
    }
    var exercise: Exercise? {
        workout?.exercises.first(where: { $0.id == navigation.exerciseId })
    }
    
    @State private var editedSet: Exercise.Set?
    @State private var isEditingSet: Bool = false
    
    init(store: WorkoutStore, navigation: ExerciseNavigation) {
        self.store = store
        self.navigation = navigation
        
        isEditingSet = exercise?.name.isEmpty ?? true
    }
    
    var body: some View {
        if let workout, let exercise {
            List {
                Button {
                    isEditingSet = true
                } label: {
                    headerView(workout: workout, exercise: exercise)
                }
                
                ForEach(exercise.sets) { set in
                    Button {
                        editedSet = set
                    } label: {
                        SetRow(store: store, set: set)
                    }
                }
                .onDelete { indexSet in
                    indexSet
                        .map { exercise.sets[$0] }
                        .forEach { set in
                            store.deleteSet(set, in: exercise.id, for: workout.id)
                        }
                }
                
                Button("Add Set") {
                    let newSet = newSet()
                    store.createSet(newSet, in: exercise.id, for: workout.id)
                    editedSet = newSet
                }
                .buttonStyle(.borderless)
            }
            .listStyle(.plain)
            .animation(.default, value: exercise.sets.count)
            .navigationTitle("Exercise")
            .sheet(item: $editedSet) { set in
                NavigationStack {
                    SetEditView(
                        store: store,
                        navigation: SetNavigation(
                            workoutId: navigation.workoutId,
                            exerciseId: navigation.exerciseId,
                            setId: set.id
                        )
                    )
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $isEditingSet) {
                NavigationStack {
                    ExerciseEditView(store: store, navigation: navigation)
                }
                .presentationDetents([.medium, .large])
            }
        } else {
            ContentUnavailableView("Workout or exercise not found!", systemImage: "questionmark.circle.dashed")
        }
    }
    
    private func headerView(workout: Workout, exercise: Exercise) -> some View {
        VStack(alignment: .leading) {
            Text(exercise.name)
                .multilineTextAlignment(.leading)
                .font(.title)
            
            Text(workout.date, format: .dateTime)
                .multilineTextAlignment(.leading)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private func newSet() -> Exercise.Set {
        let lastSet = exercise?.sets.last
        
        return Exercise.Set(
            weight: lastSet?.weight ?? Weight(distribution: .total(50), units: .pounds),
            repetitions: lastSet?.repetitions ?? 8
        )
    }
}

#Preview("Default") {
    let store = WorkoutStore.preview()
    let workout = store.workouts.first!
    let exercise = store.exercises(for: workout.id)!.first!
    
    NavigationStack {
        ExerciseView(
            store: store,
            navigation: .init(
                workoutId: workout.id,
                exerciseId: exercise.id
            )
        )
    }
}

#Preview("Empty Exercise") {
    let exercise = Exercise(name: "Squats", sets: [])
    
    let store = WorkoutStore.preview {
        $0.createExercise(exercise, for: $0.workouts.first!.id)
    }
    let workout = store.workouts.first!
    
    NavigationStack {
        ExerciseView(
            store: store,
            navigation: .init(
                workoutId: workout.id,
                exerciseId: exercise.id
            )
        )
    }
}
