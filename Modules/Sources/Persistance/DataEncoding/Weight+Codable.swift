//
//  Weight+Codable.swift
//  Modules
//
//  Created by Inal Gotov on 2025-11-08.
//

import Data
import Foundation

// MARK: Units

extension Weight.Units: Encodable, DecodableWithConfiguration {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public init(from decoder: any Decoder, configuration: VersionedDecodingConfiguration) throws {
        guard configuration.decodedVersion > 1 else {
            self = try Self.decodeOldUnits(from: decoder)
            return
        }

        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        guard let units = Self(rawValue: rawValue) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unsupported unit type \(rawValue)"))
        }

        self = units
    }

    private static func decodeOldUnits(from decoder: any Decoder) throws -> Self {
        enum CodingKeys: String, CodingKey {
            case pounds, kilograms
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.pounds) {
            return .pounds
        } else if container.contains(.kilograms) {
            return .kilograms
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "No supported units found!"))
        }
    }
}

// MARK: Distribution

extension Weight.Distribution: Encodable, DecodableWithConfiguration {
    enum CodingKeys: CodingKey {
        case total
        case dumbbell
        case barbell
    }

    enum BarbellCodingKeys: CodingKey {
        case plates
        case bar
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .total(let weight):
            try container.encode(weight, forKey: .total)
        case .dumbbell(let weight):
            try container.encode(weight, forKey: .dumbbell)
        case .barbell(let plates, let bar):
            var nestedContainer = container.nestedContainer(keyedBy: BarbellCodingKeys.self, forKey: .barbell)
            try nestedContainer.encode(plates, forKey: .plates)
            try nestedContainer.encode(bar, forKey: .bar)
        }
    }

    public init(from decoder: any Decoder, configuration: VersionedDecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard configuration.decodedVersion > 1 else {
            self = try Self.decodeOldData(from: container)
            return
        }

        var allKeys = ArraySlice(container.allKeys)
        guard let onlyKey = allKeys.popFirst(), allKeys.isEmpty else {
            throw DecodingError.typeMismatch(Weight.Distribution.self, DecodingError.Context.init(codingPath: container.codingPath, debugDescription: "Invalid number of keys found, expected one.", underlyingError: nil))
        }

        switch onlyKey {
        case .total:
            let weight = try container.decode(Double.self, forKey: .total)
            self = .total(weight)
        case .dumbbell:
            let weight = try container.decode(Double.self, forKey: .dumbbell)
            self = .dumbbell(weight)
        case .barbell:
            let nestedContainer = try container.nestedContainer(keyedBy: BarbellCodingKeys.self, forKey: .barbell)
            let plateWeight = try nestedContainer.decode(Double.self, forKey: .plates)
            let barWeight = try nestedContainer.decode(Double.self, forKey: .bar)
            self = .barbell(plates: plateWeight, bar: barWeight)
        }
    }

    private static func decodeOldData(from container: KeyedDecodingContainer<CodingKeys>) throws -> Self {
        enum TotalCodingKeys: CodingKey {
            case _0
        }

        enum DumbbellCodingKeys: CodingKey {
            case _0
        }

        var allKeys = ArraySlice(container.allKeys)
        guard let onlyKey = allKeys.popFirst(), allKeys.isEmpty else {
            throw DecodingError.typeMismatch(Weight.Distribution.self, DecodingError.Context.init(codingPath: container.codingPath, debugDescription: "Invalid number of keys found, expected one.", underlyingError: nil))
        }
        switch onlyKey {
        case .total:
            let nestedContainer = try container.nestedContainer(keyedBy: TotalCodingKeys.self, forKey: .total)
            let weight = try nestedContainer.decode(Double.self, forKey: ._0)
            return .total(weight)
        case .dumbbell:
            let nestedContainer = try container.nestedContainer(keyedBy: DumbbellCodingKeys.self, forKey: .dumbbell)
            let weight = try nestedContainer.decode(Double.self, forKey: ._0)
            return .dumbbell(weight)
        case .barbell:
            let nestedContainer = try container.nestedContainer(keyedBy: BarbellCodingKeys.self, forKey: .barbell)
            let plateWeight = try nestedContainer.decode(Double.self, forKey: .plates)
            let barWeight = try nestedContainer.decode(Double.self, forKey: .bar)
            return .barbell(plates: plateWeight, bar: barWeight)
        }
    }
}

// MARK: Weight

extension Weight: Encodable, DecodableWithConfiguration {
    enum CodingKeys: CodingKey {
        case distribution
        case units
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.distribution, forKey: .distribution)
        try container.encode(self.units, forKey: .units)
    }

    public init(from decoder: any Decoder, configuration: VersionedDecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            distribution: try container.decode(Distribution.self, forKey: .distribution, configuration: configuration),
            units: try container.decode(Units.self, forKey: .units, configuration: configuration)
        )
    }
}
