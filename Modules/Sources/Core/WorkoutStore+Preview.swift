//
//  WorkoutStore+Preview.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-15.
//

import Data

public extension WorkoutStore {
    static func preview(
        workouts: [Workout] = [.sample],
        extraExercises: [Exercise] = [],
        executing setup: ((WorkoutStore) -> Void)? = nil
    ) -> Self {
        let exercises = Set(workouts.flatMap({ $0.segments.map(\.exercise) }))
        
        let output = Self(exercises: Array(exercises) + extraExercises, workouts: workouts)
        setup?(output)
        return output
    }
}
