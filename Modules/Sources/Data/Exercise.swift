//
//  Exercise.swift
//  FitnessJournal
//
//  Created by Inal Gotov on 2025-08-31.
//

import Foundation

public struct Exercise: Hashable, Codable, Sendable, Identifiable {
    public struct Set: Hashable, Codable, Sendable, Identifiable {
        public let id: Identifier<Self, UUID>
        public var weight: Weight
        public var repetitions: Int
        
        public init(id: Identifier<Self, UUID> = .new, weight: Weight, repetitions: Int) {
            self.id = id
            self.weight = weight
            self.repetitions = repetitions
        }
    }
    
    public let id: Identifier<Self, UUID>
    public var name: String
    public var sets: [Set]
    
    public init(id: Identifier<Self, UUID> = .new, name: String, sets: [Set]) {
        self.id = id
        self.name = name
        self.sets = sets
    }
}

extension Exercise {
    public var displayWeight: Weight? {
        commonWeight ?? sets.max(by: { $0.weight.totalWeight > $1.weight.totalWeight })?.weight
    }
    
    public var commonWeight: Weight? {
        Dictionary(
            grouping: sets.map(\.weight),
            by: \.hashValue
        )
        .values
        .max(by: { $0.count > $1.count })?.first
    }
}

#if DEBUG
public extension Exercise {
    static var sample: Exercise { .sampleBenchPress }
    
    static var sampleBicepCurl: Exercise {
        .init(
            id: .new,
            name: "Bicep Curl",
            sets: (1...3).map { _ in
                Set(
                    id: .new,
                    weight: Weight(distribution: .dumbbell(50), units: .pounds),
                    repetitions: 10
                )
            }
        )
    }
    
    static var sampleBenchPress: Exercise {
        .init(
            id: .new,
            name: "Bench Press",
            sets: (1...3).map { _ in
                Set(
                    id: .new,
                    weight: Weight(distribution: .barbell(plates: 45, bar: 45), units: .pounds),
                    repetitions: 8
                )
            }
        )
    }
    
    static var sampleDeadlifts: Exercise {
        .init(
            id: .new,
            name: "Deadlifts",
            sets: (1...5).map { _ in
                Set(
                    id: .new,
                    weight: Weight(distribution: .barbell(plates: 70, bar: 45), units: .pounds),
                    repetitions: 5
                )
            }
        )
    }
    
    static var sampleLegExtensions: Exercise {
        .init(
            id: .new,
            name: "Leg Extensions",
            sets: (1...3).map { _ in
                Set(
                    id: .new,
                    weight: Weight(distribution: .total(80), units: .pounds),
                    repetitions: 10
                )
            }
        )
    }
    
    static var sampleChestFlys: Exercise {
        .init(
            id: .new,
            name: "Chest Flys",
            sets: (1...3).map { _ in
                Set(
                    id: .new,
                    weight: Weight(distribution: .total(60), units: .pounds),
                    repetitions: 10
                )
            }
        )
    }
}

public extension Exercise.Set {
    static var sampleTotal: Self { .init(id: .new, weight: Weight(distribution: .total(50), units: .pounds), repetitions: 10) }
    static var sampleDumbbell: Self { .init(id: .new, weight: Weight(distribution: .dumbbell(25), units: .pounds), repetitions: 10) }
    static var sampleBarbell: Self { .init(id: .new, weight: Weight(distribution: .barbell(plates: 5, bar: 40), units: .pounds), repetitions: 10) }
}
#endif
