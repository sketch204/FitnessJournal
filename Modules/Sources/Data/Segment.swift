//
//  Segment.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-27.
//

import Foundation

public struct Segment: Hashable, Sendable, Identifiable {
    public struct Set: Hashable, Sendable, Identifiable {
        public let id: Identifier<Self, UUID>
        public var weight: Weight
        public var repetitions: Int
        public var rateOfPerceivedExertion: Int?

        public init(
            id: Identifier<Self, UUID> = .new,
            weight: Weight,
            repetitions: Int,
            rateOfPerceivedExertion: Int? = nil
        ) {
            self.id = id
            self.weight = weight
            self.repetitions = repetitions
            self.rateOfPerceivedExertion = rateOfPerceivedExertion
        }
    }
    
    public let id: Identifier<Self, UUID>
    public var exercise: Exercise.ID
    public var sets: [Set]
    
    public init(id: Identifier<Self, UUID> = .new, exercise: Exercise.ID, sets: [Set] = []) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
    }
}

extension Segment {
    public var displayWeight: Weight? {
        commonWeight ?? sets.max(by: { $0.weight.totalWeight < $1.weight.totalWeight })?.weight
    }
    
    public var commonWeight: Weight? {
        let groupedWeights = Dictionary(
            grouping: sets.map(\.weight),
            by: \.hashValue
        )
        .values
        
        let allWeightsUnique = Swift.Set(groupedWeights).count == groupedWeights.count
        
        guard !allWeightsUnique else { return nil }
        
        return groupedWeights.max(by: { $0.count < $1.count })?.first
    }
    
    public var displayRepetitions: Int? {
        commonRepetitions ?? sets.max(by: { $0.repetitions < $1.repetitions })?.repetitions
    }
    
    public var commonRepetitions: Int? {
        let groupedRepetitions = Dictionary(grouping: sets.map(\.repetitions), by: \.self).values
        let allRepsUnique = Swift.Set(groupedRepetitions).count == groupedRepetitions.count
        guard !allRepsUnique else { return nil }
        return groupedRepetitions.max(by: { $0.count < $1.count })?.first
    }
    
    public var compositionString: String? {
        guard let displayRepetitions else { return nil }
        return "\(sets.count)x\(displayRepetitions)"
    }
}
