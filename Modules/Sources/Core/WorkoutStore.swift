//
//  WorkoutStore.swift
//  FitnessJournal
//
//  Created by Inal Gotov on 2025-08-31.
//

import Data
import Foundation

public protocol WorkoutStorePersistor: Sendable {
    func loadWorkouts() async throws -> [Workout]
    func saveWorkouts(_ workouts: [Workout]) async throws
    
    func loadExercises() async throws -> [Exercise]
    func saveExercises(_ exercises: [Exercise]) async throws
}

// MARK: WorkoutStore

@Observable
public final class WorkoutStore {
    private var persistor: WorkoutStorePersistor
    
    public private(set) var exercises: [Exercise] = []
    public private(set) var workouts: [Workout] = []
    
    public init(
        persistor: WorkoutStorePersistor,
    ) {
        self.persistor = persistor
        
        loadWorkouts()
        loadExercises()
    }
    
    private func loadWorkouts() {
        Task {
            do {
                workouts = try await persistor.loadWorkouts()
            } catch {
                Log.core.critical("Failed to load workouts due to error! \(error)")
            }
        }
    }
    
    private func saveWorkouts(workouts: [Workout]) {
        Task {
            do {
                try await persistor.saveWorkouts(workouts)
            } catch {
                Log.core.critical("Failed to save workouts due to error! \(error)")
            }
        }
    }
    
    private func loadExercises() {
        Task {
            do {
                exercises = try await persistor.loadExercises()
            } catch {
                Log.core.critical("Failed to load exercises due to error! \(error)")
            }
        }
    }
    
    private func saveExercises(exercises: [Exercise]) {
        Task {
            do {
                try await persistor.saveExercises(exercises)
            } catch {
                Log.core.critical("Failed to save exercises due to error! \(error)")
            }
        }
    }
    
    public func workout(with workoutId: Workout.ID) -> Workout? {
        workouts.first(where: { $0.id == workoutId })
    }
    
    public func segments(for workoutId: Workout.ID) -> [Segment]? {
        workout(with: workoutId)?.segments
    }
    
    public func segment(segmentId: Segment.ID, workoutId: Workout.ID) -> Segment? {
        self.segments(for: workoutId)?.first(where: { $0.id == segmentId })
    }
    
    public func sets(segmentId: Segment.ID, workoutId: Workout.ID) -> [Segment.Set]? {
        segment(segmentId: segmentId, workoutId: workoutId)?.sets
    }
    
    public func set(setId: Segment.Set.ID, segmentId: Segment.ID, workoutId: Workout.ID) -> Segment.Set? {
        sets(segmentId: segmentId, workoutId: workoutId)?.first(where: { $0.id == setId })
    }
    
    func workoutIndex(for workoutId: Workout.ID) -> Int? {
        workouts.firstIndex(where: { $0.id == workoutId })
    }
    
    func workoutSegmentIndex(
        segmentId: Segment.ID,
        workoutId: Workout.ID
    ) -> (workoutIndex: Int, segmentIndex: Int)? {
        guard let workoutIndex = workoutIndex(for: workoutId),
              let segmentIndex = workouts[workoutIndex].segments.firstIndex(where: { $0.id == segmentId })
        else { return nil }
        return (workoutIndex, segmentIndex)
    }
    
    func workoutSegmentSetIndex(
        setId: Segment.Set.ID,
        segmentId: Segment.ID,
        workoutId: Workout.ID
    ) -> (workoutIndex: Int, segmentIndex: Int, setIndex: Int)? {
        guard let (workoutIndex, segmentIndex) = workoutSegmentIndex(segmentId: segmentId, workoutId: workoutId),
              let setIndex = workouts[workoutIndex].segments[segmentIndex].sets.firstIndex(where: { $0.id == setId })
        else { return nil }
        return (workoutIndex, segmentIndex, setIndex)
    }
}

// MARK: Workouts

extension WorkoutStore {
    @discardableResult
    public func createWorkout(_ workout: Workout = Workout()) -> Workout {
        workouts.append(workout)
        saveWorkouts(workouts: workouts)
        return workout
    }
    
    @discardableResult
    public func updateWorkout(_ workout: Workout) -> Workout? {
        guard let index = workouts.firstIndex(where: { $0.id == workout.id }) else {
            return nil
        }
        
        workouts[index] = workout
        saveWorkouts(workouts: workouts)
        return workout
    }
    
    @discardableResult
    public func updateWorkout(
        with id: Workout.ID,
        update: (inout Workout) -> Void
    ) -> Workout? {
        guard var workout = workout(with: id) else {
            return nil
        }
        update(&workout)
        return updateWorkout(workout)
    }
    
    public func deleteWorkout(_ workout: Workout) {
        deleteWorkout(workout.id)
    }
    
    public func deleteWorkout(_ workoutId: Workout.ID) {
        workouts.removeAll(where: { $0.id == workoutId })
        saveWorkouts(workouts: workouts)
    }
}

// MARK: Segments

extension WorkoutStore {
    @discardableResult
    public func createSegment(_ segment: Segment, for workoutId: Workout.ID) -> Segment? {
        guard let index = workouts.firstIndex(where: { $0.id == workoutId }) else {
            return nil
        }
        workouts[index].segments.append(segment)
        saveWorkouts(workouts: workouts)
        return segment
    }
    
    @discardableResult
    public func updateSegment(_ segment: Segment, for workoutId: Workout.ID) -> Segment? {
        guard let (workoutIndex, segmentIndex) = workoutSegmentIndex(
            segmentId: segment.id,
            workoutId: workoutId
        ) else {
            return nil
        }
        
        workouts[workoutIndex].segments[segmentIndex] = segment
        saveWorkouts(workouts: workouts)
        return segment
    }
    
    public func moveSegments(at sourceIndices: IndexSet, to targetIndex: Int, for workoutId: Workout.ID) {
        updateWorkout(with: workoutId) { workout in
            workout.segments.moveSubranges(
                RangeSet(sourceIndices, within: workout.segments),
                to: targetIndex
            )
        }
    }
    
    @discardableResult
    public func updateSegment(
        segmentId: Segment.ID,
        workoutId: Workout.ID,
        update: (inout Segment) -> Void
    ) -> Segment? {
        guard var segment = segment(
            segmentId: segmentId,
            workoutId: workoutId
        ) else {
            return nil
        }
        update(&segment)
        return updateSegment(segment, for: workoutId)
    }
    
    public func deleteSegment(_ segment: Segment, for workoutId: Workout.ID) {
        deleteSegment(segment.id, for: workoutId)
    }
    
    public func deleteSegment(_ segmentId: Segment.ID, for workoutId: Workout.ID) {
        guard let index = workouts.firstIndex(where: { $0.id == workoutId }) else { return }
        workouts[index].segments.removeAll(where: { $0.id == segmentId })
        saveWorkouts(workouts: workouts)
    }
}

// MARK: Sets

extension WorkoutStore {
    @discardableResult
    public func createSet(_ set: Segment.Set, segmentId: Segment.ID, workoutId: Workout.ID) -> Segment.Set? {
        guard let (workoutIndex, segmentIndex) = workoutSegmentIndex(
            segmentId: segmentId,
            workoutId: workoutId
        ) else {
            return nil
        }
        
        workouts[workoutIndex].segments[segmentIndex].sets.append(set)
        saveWorkouts(workouts: workouts)
        return set
    }
    
    @discardableResult
    public func updateSet(
        _ set: Segment.Set,
        segmentId: Segment.ID,
        workoutId: Workout.ID,
    ) -> Segment.Set? {
        guard let (workoutIndex, segmentIndex, setIndex) = workoutSegmentSetIndex(
            setId: set.id,
            segmentId: segmentId,
            workoutId: workoutId
        ) else {
            return nil
        }

        workouts[workoutIndex].segments[segmentIndex].sets[setIndex] = set
        saveWorkouts(workouts: workouts)
        return set
    }
    
    @discardableResult
    public func updateSet(
        with setId: Segment.Set.ID,
        segmentId: Segment.ID,
        workoutId: Workout.ID,
        update: (inout Segment.Set) -> Void,
    ) -> Segment.Set? {
        guard var set = set(
            setId: setId,
            segmentId: segmentId,
            workoutId: workoutId
        ) else {
            return nil
        }
        update(&set)
        return updateSet(set, segmentId: segmentId, workoutId: workoutId)
    }
    
    public func deleteSet(_ set: Segment.Set, segmentId: Segment.ID, workoutId: Workout.ID) {
        deleteSet(set.id, segmentId: segmentId, workoutId: workoutId)
    }
    
    public func deleteSet(_ setId: Segment.Set.ID, segmentId: Segment.ID, workoutId: Workout.ID) {
        guard let (workoutIndex, segmentIndex) = workoutSegmentIndex(
            segmentId: segmentId,
            workoutId: workoutId
        ) else {
            return
        }
        workouts[workoutIndex].segments[segmentIndex].sets.removeAll(where: { $0.id == setId })
        saveWorkouts(workouts: workouts)
    }
}

// MARK: - Exercises

extension WorkoutStore {
    public func maxWeight(for exerciseId: Exercise.ID) -> Weight? {
        workouts
            .compactMap { workout -> Weight? in
                let filteredSegments = workout.segments.filter({ $0.exercise.id == exerciseId })
                guard !filteredSegments.isEmpty else { return nil }
                return filteredSegments
                    .flatMap(\.sets)
                    .map(\.weight)
                    .max {
                        $0.totalWeight < $1.totalWeight
                    }
            }
            .max {
                $0.totalWeight < $1.totalWeight
            }
    }
    
    public func sets(with exerciseId: Exercise.ID) -> [Date: [Segment.Set]] {
        workouts
            .compactMap { workout -> (date: Date, sets: [Segment.Set])? in
                let filteredSegments = workout.segments.filter({ $0.exercise.id == exerciseId })
                guard !filteredSegments.isEmpty else { return nil }
                return (workout.date, filteredSegments.flatMap(\.sets))
            }
            .reduce(into: [Date: [Segment.Set]]()) { partialResult, pair in
                partialResult[pair.date] = pair.sets
            }
            .filter { !$0.value.isEmpty }
    }
    
    public func latestSet(with exerciseId: Exercise.ID) -> Segment.Set? {
        let sets = sets(with: exerciseId)
        guard let maxDate = sets.keys.max() else { return nil }
        return sets[maxDate]?.last
    }
    
    public func segments(with exerciseId: Exercise.ID) -> [Segment] {
        workouts.flatMap { workout in
            workout.segments.filter { $0.exercise.id == exerciseId }
        }
    }
    
    public func exercise(with exerciseId: Exercise.ID) -> Exercise? {
        exercises.first(where: { $0.id == exerciseId })
    }
    
    @discardableResult
    public func createExercise(_ exercise: Exercise) -> Exercise? {
        exercises.append(exercise)
        saveExercises(exercises: exercises)
        return exercise
    }
    
    @discardableResult
    public func updateExercise(_ exercise: Exercise) -> Exercise? {
        guard let exerciseIndex = exercises.firstIndex(where: { $0.id == exercise.id }) else {
            return nil
        }
        
        exercises[exerciseIndex] = exercise
        updateSegments(using: exercise)
        
        saveExercises(exercises: exercises)
        saveWorkouts(workouts: workouts)
        
        return exercise
    }
    
    @discardableResult
    public func updateExercise(
        with exerciseId: Exercise.ID,
        update: (inout Exercise) -> Void
    ) -> Exercise? {
        guard var exercise = exercise(with: exerciseId) else {
            return nil
        }
        update(&exercise)
        return updateExercise(exercise)
    }
    
    public func canDeleteExercise(_ exercise: Exercise) -> Bool {
        canDeleteExercise(exercise.id)
    }
    
    public func canDeleteExercise(_ exerciseId: Exercise.ID) -> Bool {
        segments(with: exerciseId).isEmpty
    }
    
    public func deleteExercise(_ exercise: Exercise) throws(WorkoutStoreError) {
        try deleteExercise(exercise.id)
    }
    
    public func deleteExercise(_ exerciseId: Exercise.ID) throws(WorkoutStoreError) {
        guard canDeleteExercise(exerciseId) else {
            if let exercise = exercise(with: exerciseId) {
                throw WorkoutStoreError.exerciseUsedInSegments(exercise)
            }
            return
        }
        exercises.removeAll(where: { $0.id == exerciseId })
        saveExercises(exercises: exercises)
    }
    
    // MARK: Helpers
    
    private func updateSegments(using exercise: Exercise) {
        workouts = workouts.map { workout in
            var workout = workout
            workout.segments = workout.segments.map { segment in
                var segment = segment
                if segment.exercise.id == exercise.id {
                    segment.exercise = exercise
                }
                return segment
            }
            return workout
        }
    }
}
