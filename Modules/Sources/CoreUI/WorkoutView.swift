//
//  WorkoutView.swift
//  Modules
//
//  Created by Inal Gotov on 2025-08-31.
//

import Core
import Data
import SwiftUI

public struct WorkoutView: View {
    @Environment(\.appActions) private var appActions
    
    public let store: WorkoutStore
    public let workoutId: Workout.ID
    
    @State private var isEditingDate: Bool = false
    @State private var isAddingExercise: Bool = false
    
    var workout: Workout? {
        store.workouts.first(where: { $0.id == workoutId })
    }
    
    public init(store: WorkoutStore, workoutId: Workout.ID) {
        self.store = store
        self.workoutId = workoutId
    }
    
    public var body: some View {
        if let workout {
            List {
                dateLabel(workout)
                
                ForEach(workout.exercises) { exercise in
                    NavigationLink(
                        value: ExerciseNavigation(
                            workoutId: workoutId,
                            exerciseId: exercise.id
                        )
                    ) {
                        ExerciseRow(exercise: exercise)
                    }
                }
                .onDelete { indexSet in
                    indexSet.map{ workout.exercises[$0] }
                        .forEach { exercise in
                            store.deleteExercise(exercise, for: workoutId)
                        }
                }
                
                Button("Add Exercise") {
                    isAddingExercise = true
                }
                .buttonStyle(.borderless)
            }
            .listStyle(.plain)
            .animation(.default, value: workout.exercises.count)
            .navigationTitle("Workout")
            .sheet(isPresented: $isEditingDate) {
                NavigationStack {
                    WorkoutDateEditView(store: store, workoutId: workoutId)
                }
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $isAddingExercise) {
                NavigationStack {
                    ExerciseEditView(store: store, workoutId: workoutId) { exercise in
                        print("Navigating to \(exercise.name)")
                        appActions.perform(
                            NavigateToExerciseAction(
                                navigation: ExerciseNavigation(
                                    workoutId: workoutId,
                                    exerciseId: exercise.id
                                )
                            )
                        )
                    }
                    .presentationDetents([.medium])
                }
            }
        } else {
            ContentUnavailableView("Workout not found!", systemImage: "questionmark.circle.dashed")
        }
    }
    
    private func dateLabel(_ workout: Workout) -> some View {
        Button {
            isEditingDate = true
        } label: {
            Text(workout.date, format: .relative(presentation: .named))
        }
        .buttonStyle(.plain)
    }
}

#Preview("Default") {
    let store = WorkoutStore.preview()
    let workout = store.workouts.first!
    
    NavigationStack {
        WorkoutView(
            store: store,
            workoutId: workout.id
        )
        .navigationDestination(for: ExerciseNavigation.self) { navigation in
            ExerciseView(store: store, navigation: navigation)
        }
    }
}
