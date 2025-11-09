//
//  Workout+Codable.swift
//  Modules
//
//  Created by Inal Gotov on 2025-11-08.
//

import Data
import Foundation

extension Workout: Codable {
    enum CodingKeys: CodingKey {
        case id
        case date
        case segments
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.segments, forKey: .segments)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try container.decode(Identifier<Workout, UUID>.self, forKey: .id),
            date: try container.decode(Date.self, forKey: .date),
            segments: try container.decode([Segment].self, forKey: .segments)
        )
    }
}
