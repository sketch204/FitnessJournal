//
//  FileWorkoutStorePersistor+Migrations.swift
//  Modules
//
//  Created by Inal Gotov on 2025-11-08.
//

import Data
import Foundation

nonisolated struct DataWrapper {
    static let latestSchemaVersionCodingUserInfoKey = CodingUserInfoKey(rawValue: "currentSchemaVersion")!
    static let currentSchemaVersionCodingUserInfoKey = CodingUserInfoKey(rawValue: "currentSchemaVersion")!

    var version: Int?
    var workouts: [Workout] = []
    var exercises: [Exercise] = []
}

public struct VersionedDecodingConfiguration {
    let decodedVersion: Int
    let latestVersion: Int
}

nonisolated extension DataWrapper: Codable {
    private enum CodingKeys: String, CodingKey {
        case version
        case workouts
        case exercises
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.version, forKey: .version)
        try container.encode(self.workouts, forKey: .workouts)
        try container.encode(self.exercises, forKey: .exercises)
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let latestVersion = decoder.userInfo[Self.latestSchemaVersionCodingUserInfoKey] as? Int ?? 0

        let configuration = VersionedDecodingConfiguration(
            decodedVersion: try container.decodeIfPresent(Int.self, forKey: .version) ?? 1,
            latestVersion: latestVersion
        )

        self.version = latestVersion
        self.workouts = try container.decode([Workout].self, forKey: .workouts, configuration: configuration)
        self.exercises = try container.decode([Exercise].self, forKey: .exercises, configuration: configuration)
    }
}
