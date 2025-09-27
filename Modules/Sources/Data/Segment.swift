//
//  Segment.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-27.
//

import Foundation

public struct Segment: Hashable, Codable, Sendable, Identifiable {
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
    public var exercise: Exercise
    public var sets: [Set]
    
    public init(id: Identifier<Self, UUID> = .new, exercise: Exercise, sets: [Set]) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
    }
}

extension Segment {
    public var displayWeight: Weight? {
        commonWeight ?? sets.max(by: { $0.weight.totalWeight > $1.weight.totalWeight })?.weight
    }
    
    public var commonWeight: Weight? {
        Dictionary(
            grouping: sets.map(\.weight),
            by: \.hashValue
        )
        .values
        .max(by: { $0.count < $1.count })?.first
    }
}

// MARK: Samples

#if DEBUG
public extension Segment {
    static var sample: Segment { .sampleBenchPress }
    
    static var sampleBicepCurl: Segment {
        .init(
            exercise: .sampleBicepCurl,
            sets: (1...3).map { _ in
                Set(
                    id: .new,
                    weight: Weight(distribution: .dumbbell(50), units: .pounds),
                    repetitions: 10
                )
            }
        )
    }
    
    static var sampleBenchPress: Segment {
        .init(
            exercise: .sampleBenchPress,
            sets: (1...3).map { _ in
                Set(
                    id: .new,
                    weight: Weight(distribution: .barbell(plates: 45, bar: 45), units: .pounds),
                    repetitions: 8
                )
            }
        )
    }
    
    static var sampleDeadlifts: Segment {
        .init(
            exercise: .sampleDeadlifts,
            sets: (1...5).map { _ in
                Set(
                    id: .new,
                    weight: Weight(distribution: .barbell(plates: 70, bar: 45), units: .pounds),
                    repetitions: 5
                )
            }
        )
    }
    
    static var sampleLegExtensions: Segment {
        .init(
            exercise: .sampleLegExtensions,
            sets: (1...3).map { _ in
                Set(
                    id: .new,
                    weight: Weight(distribution: .total(80), units: .pounds),
                    repetitions: 10
                )
            }
        )
    }
    
    static var sampleChestFlys: Segment {
        .init(
            exercise: .sampleChestFlys,
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

public extension Segment.Set {
    static var sampleTotal: Self { .init(id: .new, weight: Weight(distribution: .total(50), units: .pounds), repetitions: 10) }
    static var sampleDumbbell: Self { .init(id: .new, weight: Weight(distribution: .dumbbell(25), units: .pounds), repetitions: 10) }
    static var sampleBarbell: Self { .init(id: .new, weight: Weight(distribution: .barbell(plates: 5, bar: 40), units: .pounds), repetitions: 10) }
}
#endif

