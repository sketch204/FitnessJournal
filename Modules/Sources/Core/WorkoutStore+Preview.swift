//
//  WorkoutStore+Preview.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-15.
//

import Data

public extension WorkoutStore {
    static func preview(workouts: [Workout] = [.sample], executing setup: ((WorkoutStore) -> Void)? = nil) -> Self {
        let output = Self(workouts: workouts)
        setup?(output)
        return output
    }
}
