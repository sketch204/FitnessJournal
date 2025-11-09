//
//  SegmentView.swift
//  Modules
//
//  Created by Inal Gotov on 2025-08-31.
//

import Core
import Data
import SwiftUI

struct SegmentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appActions) private var appActions
    
    let store: WorkoutStore
    let navigation: SegmentNavigation
    
    var workout: Workout? {
        store.workout(for: navigation)
    }
    var segment: Segment? {
        store.segment(for: navigation)
    }
    var exercise: Exercise? {
        segment.flatMap {
            store.exercise(with: $0.exercise)
        }
    }

    init(store: WorkoutStore, navigation: SegmentNavigation) {
        self.store = store
        self.navigation = navigation
    }
    
    var body: some View {
        if let workout, let segment, let exercise {
            List {
                Button {
                    appActions.perform(NavigateToExerciseAction(exerciseId: segment.exercise))
                } label: {
                    headerView(workout: workout, segment: segment, exercise: exercise)
                }
                .contextMenu {
                    Button {
                        appActions.perform(SelectExerciseAction { exercise in
                            updateSegment(with: exercise)
                        })
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                }
                
                ForEach(segment.sets) { set in
                    Button {
                        editSet(setId: set.id)
                    } label: {
                        SetRow(set: set)
                    }
                }
                .onDelete { indexSet in
                    indexSet
                        .map { segment.sets[$0] }
                        .forEach { set in
                            store.deleteSet(set, segmentId: segment.id, workoutId: workout.id)
                        }
                }
                
                Button {
                    addNewSet()
                } label: {
                    Text("Add Set")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
            }
            .listStyle(.plain)
            .animation(.default, value: segment.sets.count)
            .navigationTitle("Segment")
        } else {
            ContentUnavailableView("Workout or exercise not found!", systemImage: "questionmark.circle.dashed")
        }
    }
    
    private func headerView(workout: Workout, segment: Segment, exercise: Exercise) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(exercise.name)
                    .multilineTextAlignment(.leading)
                    .font(.title)
                
                Text(workout.date, format: .dateTime)
                    .multilineTextAlignment(.leading)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
    }
    
    private func updateSegment(with exercise: Exercise) {
        store.updateSegment(
            segmentId: navigation.segmentId,
            workoutId: navigation.workoutId
        ) { segment in
            segment.exercise = exercise.id
        }
    }
    
    private func addNewSet() {
        appActions.addSet(navigation: navigation)
    }
    
    private func editSet(setId: Segment.Set.ID) {
        appActions.perform(
            EditSetAction(
                workoutId: navigation.workoutId,
                segmentId: navigation.segmentId,
                setId: setId
            )
        )
    }
    
    private func newSet() -> Segment.Set {
        let lastSet = segment?.sets.last
        
        return Segment.Set(
            weight: lastSet?.weight ?? Weight(distribution: .total(50), units: .pounds),
            repetitions: lastSet?.repetitions ?? 8
        )
    }
}

#Preview("Default") {
    let workout = Workout.sample
    let segment = workout.segments.first!
    let store = WorkoutStore.preview(workouts: [workout])
    
    NavigationStack {
        SegmentView(
            store: store,
            navigation: .init(
                workoutId: workout.id,
                segmentId: segment.id
            )
        )
        .registerEditSetHandler(store: store)
    }
    .environment(\.appActions, AppActions())
}

#Preview("Empty Exercise") {
    let workout = Workout.sample
    let segment = Segment(exercise: .new, sets: [])
    let store = WorkoutStore.preview(workouts: [workout]) {
        $0.createSegment(segment, for: $0.workouts.first!.id)
    }
    
    NavigationStack {
        SegmentView(
            store: store,
            navigation: .init(
                workoutId: workout.id,
                segmentId: segment.id
            )
        )
        .registerEditSetHandler(store: store)
    }
    .environment(\.appActions, AppActions())
}
