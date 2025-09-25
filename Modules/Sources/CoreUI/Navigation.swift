//
//  Navigation.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-25.
//

import Core
import Data

// MARK: Set Navigation

struct SetNavigation: Hashable {
    let workoutId: Workout.ID
    let exerciseId: Exercise.ID
    let setId: Exercise.Set.ID
}

// MARK: WorkoutStore Set Extension

extension WorkoutStore {
    func set(for navigation: SetNavigation) -> Exercise.Set? {
        set(
            with: navigation.setId,
            for: navigation.workoutId,
            in: navigation.exerciseId
        )
    }
    
    func exercise(for navigation: SetNavigation) -> Exercise? {
        exercise(with: navigation.exerciseId, for: navigation.workoutId)
    }
    
    func workout(for navigation: SetNavigation) -> Workout? {
        workout(with: navigation.workoutId)
    }
}

// MARK: Exercise Navigation

struct ExerciseNavigation: Hashable {
    let workoutId: Workout.ID
    let exerciseId: Exercise.ID
}

// MARK: WorkoutStore Exercise Extension

extension WorkoutStore {
    func exercise(for navigation: ExerciseNavigation) -> Exercise? {
        exercise(with: navigation.exerciseId, for: navigation.workoutId)
    }
    
    func workout(for navigation: ExerciseNavigation) -> Workout? {
        workout(with: navigation.workoutId)
    }
}

// MARK: SwiftUI Navigation

struct Navigate {
    
}
