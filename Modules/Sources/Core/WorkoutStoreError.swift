//
//  WorkoutStoreError.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-27.
//

import Data

public enum WorkoutStoreError: Error, Equatable, Hashable, Sendable {
    case exerciseUsedInSegments(Exercise)
}

extension WorkoutStoreError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .exerciseUsedInSegments(let exercise):
            "Exercise \(exercise.name) is used in segments"
        }
    }
}
