//
//  Workout.swift
//  FitnessJournal
//
//  Created by Inal Gotov on 2025-08-31.
//

import Foundation

public struct Workout: Hashable, Sendable, Identifiable {
    public let id: Identifier<Self, UUID>
    public var date: Date
    public var segments: [Segment]
    
    public init(
        id: Identifier<Self, UUID> = .new,
        date: Date = .now,
        segments: [Segment] = []
    ) {
        self.id = id
        self.date = date
        self.segments = segments
    }
}
