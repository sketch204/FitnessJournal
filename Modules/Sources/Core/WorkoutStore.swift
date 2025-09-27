//
//  WorkoutStore.swift
//  FitnessJournal
//
//  Created by Inal Gotov on 2025-08-31.
//

import Data
import Foundation

// MARK: WorkoutStore

@Observable
public final class WorkoutStore {
    public private(set) var exercises: [Exercise] = []
    public private(set) var workouts: [Workout] = []
    
    public init(
        exercises: [Exercise] = [],
        workouts: [Workout] = []
    ) {
        self.exercises = exercises
        self.workouts = workouts
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
        return workout
    }
    
    @discardableResult
    public func updateWorkout(_ workout: Workout) -> Workout? {
        guard let index = workouts.firstIndex(where: { $0.id == workout.id }) else {
            return nil
        }
        
        workouts[index] = workout
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
        return segment
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
    }
}

// MARK: - Exercises

extension WorkoutStore {
    public func segments(with exerciseId: Exercise.ID) -> [Segment] {
        workouts.flatMap { workout in
            workout.segments.filter { $0.exercise.id == exerciseId }
        }
    }
    
    public func exercise(for exerciseId: Exercise.ID) -> Exercise? {
        exercises.first(where: { $0.id == exerciseId })
    }
    
    @discardableResult
    public func createExercise(_ exercise: Exercise) -> Exercise? {
        exercises.append(exercise)
        return exercise
    }
    
    @discardableResult
    public func updateExercise(_ exercise: Exercise) -> Exercise? {
        guard let exerciseIndex = exercises.firstIndex(where: { $0.id == exercise.id }) else {
            return nil
        }
        
        exercises[exerciseIndex] = exercise
        updateSegments(using: exercise)
        
        return exercise
    }
    
    @discardableResult
    public func updateExercise(
        with exerciseId: Exercise.ID,
        update: (inout Exercise) -> Void
    ) -> Exercise? {
        guard var exercise = exercise(for: exerciseId) else {
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
            if let exercise = exercise(for: exerciseId) {
                throw WorkoutStoreError.exerciseUsedInSegments(exercise)
            }
            return
        }
        exercises.removeAll(where: { $0.id == exerciseId })
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
