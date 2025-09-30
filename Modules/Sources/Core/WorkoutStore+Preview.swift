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
        let output = Self(
            persistor: .preview(
                workouts: workouts,
                extraExercises: extraExercises
            )
        )
        setup?(output)
        return output
    }
}
