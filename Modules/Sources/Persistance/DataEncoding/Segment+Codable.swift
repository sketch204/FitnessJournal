//
//  Segment+Codable.swift
//  Modules
//
//  Created by Inal Gotov on 2025-11-08.
//

import Data
import Foundation

extension Segment.Set: Codable {
    enum CodingKeys: CodingKey {
        case id
        case weight
        case repetitions
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: Segment.Set.CodingKeys.self)
        try container.encode(self.id, forKey: Segment.Set.CodingKeys.id)
        try container.encode(self.weight, forKey: Segment.Set.CodingKeys.weight)
        try container.encode(self.repetitions, forKey: Segment.Set.CodingKeys.repetitions)
    }

    public init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<Segment.Set.CodingKeys> = try decoder.container(keyedBy: Segment.Set.CodingKeys.self)
        self.init(
            id: try container.decode(Identifier<Segment.Set, UUID>.self, forKey: Segment.Set.CodingKeys.id),
            weight: try container.decode(Weight.self, forKey: Segment.Set.CodingKeys.weight),
            repetitions: try container.decode(Int.self, forKey: Segment.Set.CodingKeys.repetitions),
        )
    }
}

extension Segment: Codable {
    enum CodingKeys: CodingKey {
        case id
        case exercise
        case sets
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.exercise, forKey: .exercise)
        try container.encode(self.sets, forKey: .sets)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try container.decode(Identifier<Segment, UUID>.self, forKey: .id),
            exercise: try container.decode(Exercise.self, forKey: .exercise),
            sets: try container.decode([Segment.Set].self, forKey: .sets),
        )
    }
}
