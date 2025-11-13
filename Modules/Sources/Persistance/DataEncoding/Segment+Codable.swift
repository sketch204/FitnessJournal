//
//  Segment+Codable.swift
//  Modules
//
//  Created by Inal Gotov on 2025-11-08.
//

import Data
import Foundation

extension Segment.Set: Encodable, DecodableWithConfiguration {
    enum CodingKeys: CodingKey {
        case id, weight, repetitions, rateOfPerceivedExertion
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.weight, forKey: .weight)
        try container.encode(self.repetitions, forKey: .repetitions)
        try container.encodeIfPresent(self.rateOfPerceivedExertion, forKey: .rateOfPerceivedExertion)
    }

    public init(from decoder: any Decoder, configuration: VersionedDecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(ID.self, forKey: .id)
        let weight = try container.decode(Weight.self, forKey: .weight, configuration: configuration)
        let repetitions = try container.decode(Int.self, forKey: .repetitions)
        let rateOfPerceivedExertion = try container.decodeIfPresent(Int.self, forKey: .rateOfPerceivedExertion)

        self.init(id: id, weight: weight, repetitions: repetitions, rateOfPerceivedExertion: rateOfPerceivedExertion)
    }
}

extension Segment: Encodable, DecodableWithConfiguration {
    enum CodingKeys: CodingKey {
        case id, exercise, sets
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.exercise, forKey: .exercise)
        try container.encode(self.sets, forKey: .sets)
    }

    public init(from decoder: any Decoder, configuration: VersionedDecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(ID.self, forKey: .id)
        let exercise = try Self.decodeExercise(from: container, configuration: configuration)
        let sets = try container.decode([Segment.Set].self, forKey: .sets, configuration: configuration)

        self.init(id: id, exercise: exercise, sets: sets)
    }

    private static func decodeExercise(
        from container: KeyedDecodingContainer<CodingKeys>,
        configuration: VersionedDecodingConfiguration
    ) throws -> Exercise.ID {
        if configuration.decodedVersion == 1 {
            let exercise = try container.decode(Exercise.self, forKey: .exercise, configuration: configuration)
            return exercise.id
        }
        return try container.decode(Exercise.ID.self, forKey: .exercise)
    }
}
