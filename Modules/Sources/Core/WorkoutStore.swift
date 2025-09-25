//
//  WorkoutStore.swift
//  FitnessJournal
//
//  Created by Inal Gotov on 2025-08-31.
//

import Data
import Foundation

@Observable
public final class WorkoutStore {
    public private(set) var workouts: [Workout] = []
    
    public init(workouts: [Workout] = []) {
        self.workouts = workouts
    }
    
    public func workout(with workoutId: Workout.ID) -> Workout? {
        workouts.first(where: { $0.id == workoutId })
    }
    
    public func exercises(for workoutId: Workout.ID) -> [Exercise]? {
        workout(with: workoutId)?.exercises
    }
    
    public func exercise(with exerciseId: Exercise.ID, for workoutId: Workout.ID) -> Exercise? {
        self.exercises(for: workoutId)?.first(where: { $0.id == exerciseId })
    }
    
    public func sets(for workoutId: Workout.ID, in exerciseId: Exercise.ID) -> [Exercise.Set]? {
        exercises(for: workoutId)?.first(where: { $0.id == exerciseId })?.sets
    }
    
    public func set(with setId: Exercise.Set.ID, for workoutId: Workout.ID, in exerciseId: Exercise.ID) -> Exercise.Set? {
        sets(for: workoutId, in: exerciseId)?.first(where: { $0.id == setId })
    }
}

// MARK: Workouts

public extension WorkoutStore {
    @discardableResult
    func updateWorkout(_ workout: Workout, createIfMissing: Bool = true) -> Workout? {
        guard let index = workouts.firstIndex(where: { $0.id == workout.id }) else {
            if createIfMissing {
                return createWorkout(workout)
            }
            return nil
        }
        
        workouts[index] = workout
        return workout
    }
    
    @discardableResult
    func updateWorkout(
        with id: Workout.ID?,
        createIfMissing: Bool = true,
        update: (inout Workout) -> Void
    ) -> Workout? {
        guard let id,
              var workout = workout(with: id)
        else {
            if createIfMissing {
                var workout = Workout(date: Date(), exercises: [])
                update(&workout)
                return createWorkout(workout)
            }
            return nil
        }
        update(&workout)
        return updateWorkout(workout, createIfMissing: false)
    }
    
    @discardableResult
    func createWorkout(_ workout: Workout) -> Workout {
        workouts.append(workout)
        return workout
    }
    
    func deleteWorkout(_ workout: Workout) {
        deleteWorkout(workout.id)
    }
    
    func deleteWorkout(_ workoutId: Workout.ID) {
        workouts.removeAll(where: { $0.id == workoutId })
    }
}

// MARK: Exercises

public extension WorkoutStore {
    @discardableResult
    func updateExercise(_ exercise: Exercise, for workoutId: Workout.ID, createIfMissing: Bool = true) -> Exercise? {
        guard let workoutIndex = workouts.firstIndex(where: { $0.id == workoutId }) else {
            return nil
        }
        guard let exerciseIndex = workouts[workoutIndex].exercises.firstIndex(where: { $0.id == exercise.id }) else {
            if createIfMissing {
                return createExercise(exercise, for: workoutId)
            }
            return nil
        }
        
        workouts[workoutIndex].exercises[exerciseIndex] = exercise
        return exercise
    }
    
    @discardableResult
    func updateExercise(
        with exerciseId: Exercise.ID?,
        for workoutId: Workout.ID,
        createIfMissing: Bool = true,
        update: (inout Exercise) -> Void
    ) -> Exercise? {
        guard let exerciseId,
              var exercise = exercise(with: exerciseId, for: workoutId)
        else {
            if createIfMissing {
                var exercise = Exercise(name: "", sets: [])
                update(&exercise)
                return createExercise(exercise, for: workoutId)
            }
            return nil
        }
        update(&exercise)
        return updateExercise(exercise, for: workoutId, createIfMissing: false)
    }
    
    @discardableResult
    func createExercise(_ exercise: Exercise, for workoutId: Workout.ID) -> Exercise? {
        guard let index = workouts.firstIndex(where: { $0.id == workoutId }) else {
            return nil
        }
        workouts[index].exercises.append(exercise)
        return exercise
    }
    
    func deleteExercise(_ exercise: Exercise, for workoutId: Workout.ID) {
        deleteExercise(exercise.id, for: workoutId)
    }
    
    func deleteExercise(_ exerciseId: Exercise.ID, for workoutId: Workout.ID) {
        guard let index = workouts.firstIndex(where: { $0.id == workoutId }) else { return }
        workouts[index].exercises.removeAll(where: { $0.id == exerciseId })
    }
}

// MARK: Sets

public extension WorkoutStore {
    @discardableResult
    func updateSet(
        _ set: Exercise.Set,
        `in` exerciseId: Exercise.ID,
        for workoutId: Workout.ID,
        createIfMissing: Bool = true
    ) -> Exercise.Set? {
        guard let workoutIndex = workouts.firstIndex(where: { $0.id == workoutId }),
              let exerciseIndex = workouts[workoutIndex].exercises.firstIndex(where: { $0.id == exerciseId })
        else { return nil }
        guard let setIndex = workouts[workoutIndex].exercises[exerciseIndex].sets.firstIndex(where: { $0.id == set.id }) else {
            if createIfMissing {
                return createSet(set, in: exerciseId, for: workoutId)
            }
            return nil
        }
        
        workouts[workoutIndex].exercises[exerciseIndex].sets[setIndex] = set
        return set
    }
    
    @discardableResult
    func updateSet(
        with setId: Exercise.Set.ID,
        for workoutId: Workout.ID,
        in exerciseId: Exercise.ID,
        update: (inout Exercise.Set) -> Void,
    ) -> Exercise.Set? {
        guard var set = set(with: setId, for: workoutId, in: exerciseId) else { return nil }
        update(&set)
        return updateSet(set, in: exerciseId, for: workoutId, createIfMissing: false)
    }
    
    @discardableResult
    func createSet(_ set: Exercise.Set, `in` exerciseId: Exercise.ID, for workoutId: Workout.ID) -> Exercise.Set? {
        guard let workoutIndex = workouts.firstIndex(where: { $0.id == workoutId }),
              let exerciseIndex = workouts[workoutIndex].exercises.firstIndex(where: { $0.id == exerciseId })
        else { return nil }
        workouts[workoutIndex].exercises[exerciseIndex].sets.append(set)
        return set
    }
    
    func deleteSet(_ set: Exercise.Set, `in` exerciseId: Exercise.ID, for workoutId: Workout.ID) {
        deleteSet(set.id, in: exerciseId, for: workoutId)
    }
    
    func deleteSet(_ setId: Exercise.Set.ID, `in` exerciseId: Exercise.ID, for workoutId: Workout.ID) {
        guard let workoutIndex = workouts.firstIndex(where: { $0.id == workoutId }),
              let exerciseIndex = workouts[workoutIndex].exercises.firstIndex(where: { $0.id == exerciseId })
        else { return }
        workouts[workoutIndex].exercises[exerciseIndex].sets.removeAll(where: { $0.id == setId })
    }
}
