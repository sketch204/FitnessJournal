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
    
    let store: WorkoutStore
    let navigation: SegmentNavigation
    
    var workout: Workout? {
        store.workout(for: navigation)
    }
    var segment: Segment? {
        store.segment(for: navigation)
    }
    
    @State private var editedSet: Segment.Set?
    
    init(store: WorkoutStore, navigation: SegmentNavigation) {
        self.store = store
        self.navigation = navigation
    }
    
    var body: some View {
        if let workout, let segment {
            List {
//                Button {
//                    isEditingSet = true
//                } label: {
                    headerView(workout: workout, segment: segment)
//                }
                
                ForEach(segment.sets) { set in
                    Button {
                        editedSet = set
                    } label: {
                        SetRow(store: store, set: set)
                    }
                }
                .onDelete { indexSet in
                    indexSet
                        .map { segment.sets[$0] }
                        .forEach { set in
                            store.deleteSet(set, segmentId: segment.id, workoutId: workout.id)
                        }
                }
                
                Button("Add Set") {
                    let newSet = newSet()
                    store.createSet(newSet, segmentId: segment.id, workoutId: workout.id)
                    editedSet = newSet
                }
                .buttonStyle(.borderless)
            }
            .listStyle(.plain)
            .animation(.default, value: segment.sets.count)
            .navigationTitle("Exercise")
            .sheet(item: $editedSet) { set in
                NavigationStack {
                    SetEditView(
                        store: store,
                        navigation: SetNavigation(
                            workoutId: navigation.workoutId,
                            segmentId: navigation.segmentId,
                            setId: set.id
                        )
                    )
                }
                .presentationDetents([.medium, .large])
            }
//            .sheet(isPresented: $isEditingSet) {
//                NavigationStack {
//                    ExerciseEditView(store: store, navigation: navigation)
//                }
//                .presentationDetents([.medium, .large])
//            }
        } else {
            ContentUnavailableView("Workout or exercise not found!", systemImage: "questionmark.circle.dashed")
        }
    }
    
    private func headerView(workout: Workout, segment: Segment) -> some View {
        VStack(alignment: .leading) {
            Text(segment.exercise.name)
                .multilineTextAlignment(.leading)
                .font(.title)
            
            Text(workout.date, format: .dateTime)
                .multilineTextAlignment(.leading)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
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
    let store = WorkoutStore.preview()
    let workout = store.workouts.first!
    let segment = store.segments(for: workout.id)!.first!
    
    NavigationStack {
        SegmentView(
            store: store,
            navigation: .init(
                workoutId: workout.id,
                segmentId: segment.id
            )
        )
    }
}

#Preview("Empty Exercise") {
    let segment = Segment(exercise: Exercise(name: "Squats"), sets: [])
    
    let store = WorkoutStore.preview {
        $0.createSegment(segment, for: $0.workouts.first!.id)
    }
    let workout = store.workouts.first!
    
    NavigationStack {
        SegmentView(
            store: store,
            navigation: .init(
                workoutId: workout.id,
                segmentId: segment.id
            )
        )
    }
}
