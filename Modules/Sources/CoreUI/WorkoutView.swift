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
    
    var workout: Workout? {
        store.workout(with: workoutId)
    }
    
    public init(store: WorkoutStore, workoutId: Workout.ID) {
        self.store = store
        self.workoutId = workoutId
    }
    
    public var body: some View {
        if let workout {
            List {
                dateLabel(workout)
                    .listRowSeparator(.hidden, edges: .top)
                
                ForEach(workout.segments) { segment in
                    NavigationLink(
                        value: SegmentNavigation(
                            workoutId: workoutId,
                            segmentId: segment.id
                        )
                    ) {
                        SegmentRow(store: store, segment: segment)
                    }
                }
                .onMove(perform: { sourceIndices, targetIndex in
                    store.moveSegments(at: sourceIndices, to: targetIndex, for: workoutId)
                })
                .onDelete { indexSet in
                    indexSet.map{ workout.segments[$0] }
                        .forEach { segment in
                            store.deleteSegment(segment, for: workoutId)
                        }
                }
                
                Button {
                    appActions.perform(SelectExerciseAction { exercise in
                        createSegment(with: exercise)
                    })
                } label: {
                    Text("Add Segment")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
            }
            .listStyle(.plain)
            .animation(.default, value: workout.segments.count)
            .navigationTitle("Workout")
        } else {
            ContentUnavailableView("Workout not found!", systemImage: "questionmark.circle.dashed")
        }
    }
    
    private func createSegment(with exercise: Exercise) {
        let segment = Segment(exercise: exercise.id)
        store.createSegment(segment, for: workoutId)
        
        appActions.perform(NavigateToSegmentAction(workoutId: workoutId, segmentId: segment.id))
    }
    
    private func dateLabel(_ workout: Workout) -> some View {
        Button {
            appActions.perform(EditWorkoutAction(workoutId: workout.id))
        } label: {
            Text(workout.date, format: .relative(presentation: .named))
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview("Default") {
    PreviewingStore { store in
        let workout = store.workouts.first!

        NavigationStack {
            WorkoutView(
                store: store,
                workoutId: workout.id
            )
            .navigationDestination(for: SegmentNavigation.self) { navigation in
                SegmentView(store: store, navigation: navigation)
            }
            .registerEditWorkoutHandler(store: store)
            .registerSelectExerciseHandler(store: store)
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
        .registerEditWorkoutHandler(store: store)
        .registerSelectExerciseHandler(store: store)
    }
    .environment(\.appActions, AppActions())
}
