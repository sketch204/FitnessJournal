//
//  Workout.swift
//  FitnessJournal
//
//  Created by Inal Gotov on 2025-08-31.
//

import Foundation

public struct Workout: Hashable, Codable, Sendable, Identifiable {
    public let id: Identifier<Self, UUID>
    public var date: Date
    public var exercises: [Exercise]
    
    public init(id: Identifier<Self, UUID> = .new, date: Date, exercises: [Exercise]) {
        self.id = id
        self.date = date
        self.exercises = exercises
    }
}

#if DEBUG
public extension Workout {
    static var sample: Workout {
        Workout(
            id: .new,
            date: Date(timeIntervalSince1970: 1756691175),
            exercises: [
                .sampleBenchPress,
                .sampleChestFlys,
                .sampleBicepCurl,
            ]
        )
    }
}
#endif
