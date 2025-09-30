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
                
                ForEach(workout.segments) { segment in
                    NavigationLink(
                        value: SegmentNavigation(
                            workoutId: workoutId,
                            segmentId: segment.id
                        )
                    ) {
                        SegmentRow(segment)
                    }
                }
                .onDelete { indexSet in
                    indexSet.map{ workout.segments[$0] }
                        .forEach { segment in
                            store.deleteSegment(segment, for: workoutId)
                        }
                }
                
                Button("Add Segment") {
                    isAddingExercise = true
                }
                .buttonStyle(.borderless)
            }
            .listStyle(.plain)
            .animation(.default, value: workout.segments.count)
            .navigationTitle("Workout")
            .sheet(isPresented: $isEditingDate) {
                NavigationStack {
                    WorkoutDateEditView(store: store, workoutId: workoutId)
                }
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $isAddingExercise) {
                NavigationStack {
                    ExerciseLookupView(store: store) { exercise in
                        createSegment(with: exercise)
                    }
                }
            }
        } else {
            ContentUnavailableView("Workout not found!", systemImage: "questionmark.circle.dashed")
        }
    }
    
    private func createSegment(with exercise: Exercise) {
        let segment = Segment(exercise: exercise)
        store.createSegment(segment, for: workoutId)
        
        appActions.perform(NavigateToSegmentAction(workoutId: workoutId, segmentId: segment.id))
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
    let workout = Workout.sample
    let store = WorkoutStore.preview(workouts: [workout])
    
    NavigationStack {
        WorkoutView(
            store: store,
            workoutId: workout.id
        )
        .navigationDestination(for: SegmentNavigation.self) { navigation in
            SegmentView(store: store, navigation: navigation)
        }
        .environment(\.appActions, AppActions())
    }
}

#Preview("Empty Workout") {
    let workout = Workout()
    let store = WorkoutStore.preview(workouts: [workout])
    
    NavigationStack {
        WorkoutView(
            store: store,
            workoutId: workout.id
        )
        .navigationDestination(for: SegmentNavigation.self) { navigation in
            SegmentView(store: store, navigation: navigation)
        }
        .environment(\.appActions, AppActions())
    }
}
