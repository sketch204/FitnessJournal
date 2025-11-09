//
//  Exercise+Codable.swift
//  Modules
//
//  Created by Inal Gotov on 2025-11-08.
//

import Data
import Foundation

extension Exercise: Encodable, DecodableWithConfiguration {
    enum CodingKeys: CodingKey {
        case id
        case name
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
    }

    public init(from decoder: any Decoder, configuration: VersionedDecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try container.decode(Identifier<Exercise, UUID>.self, forKey: .id),
            name: try container.decode(String.self, forKey: .name)
        )
    }
}
