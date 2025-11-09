//
//  Weight+Codable.swift
//  Modules
//
//  Created by Inal Gotov on 2025-11-08.
//

import Data

extension Weight.Units: Codable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        guard let units = Self(rawValue: rawValue) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unsupported unit type \(rawValue)"))
        }

        self = units
    }
}

extension Weight.Distribution: Codable {
    enum CodingKeys: CodingKey {
        case total
        case dumbbell
        case barbell
    }

    enum TotalCodingKeys: CodingKey {
        case _0
    }

    enum DumbbellCodingKeys: CodingKey {
        case _0
    }

    enum BarbellCodingKeys: CodingKey {
        case plates
        case bar
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .total(let a0):
            var nestedContainer = container.nestedContainer(keyedBy: TotalCodingKeys.self, forKey: .total)
            try nestedContainer.encode(a0, forKey: ._0)
        case .dumbbell(let a0):
            var nestedContainer = container.nestedContainer(keyedBy: DumbbellCodingKeys.self, forKey: .dumbbell)
            try nestedContainer.encode(a0, forKey: ._0)
        case .barbell(let plates, let bar):
            var nestedContainer = container.nestedContainer(keyedBy: BarbellCodingKeys.self, forKey: .barbell)
            try nestedContainer.encode(plates, forKey: .plates)
            try nestedContainer.encode(bar, forKey: .bar)
        }
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var allKeys = ArraySlice(container.allKeys)
        guard let onlyKey = allKeys.popFirst(), allKeys.isEmpty else {
            throw DecodingError.typeMismatch(Weight.Distribution.self, DecodingError.Context.init(codingPath: container.codingPath, debugDescription: "Invalid number of keys found, expected one.", underlyingError: nil))
        }
        switch onlyKey {
        case .total:
            let nestedContainer = try container.nestedContainer(keyedBy: TotalCodingKeys.self, forKey: .total)
            let weight = try nestedContainer.decode(Double.self, forKey: ._0)
            self = .total(weight)
        case .dumbbell:
            let nestedContainer = try container.nestedContainer(keyedBy: DumbbellCodingKeys.self, forKey: .dumbbell)
            let weight = try nestedContainer.decode(Double.self, forKey: ._0)
            self = .dumbbell(weight)
        case .barbell:
            let nestedContainer = try container.nestedContainer(keyedBy: BarbellCodingKeys.self, forKey: .barbell)
            let plateWeight = try nestedContainer.decode(Double.self, forKey: .plates)
            let barWeight = try nestedContainer.decode(Double.self, forKey: .bar)
            self = .barbell(plates: plateWeight, bar: barWeight)
        }
    }
}

extension Weight: Codable {
    enum CodingKeys: CodingKey {
        case distribution
        case units
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.distribution, forKey: .distribution)
        try container.encode(self.units, forKey: .units)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            distribution: try container.decode(Distribution.self, forKey: .distribution),
            units: try container.decode(Units.self, forKey: .units)
        )
    }
}
