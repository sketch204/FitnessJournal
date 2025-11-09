//
//  MigrationV1toV2Tests.swift
//  Modules
//
//  Created by Inal Gotov on 2025-11-08.
//

import Data
import Foundation
@testable import Persistance
import Testing

@Suite("Migration V1 to V2 tests")
struct MigrationV1toV2Tests {
    @Test
    func `Segment should initialize from v1 data`() async throws {
        let exerciseId = "F8AD5778-2E01-43D6-ACE6-C16F244CAD39"
        let segmentId = "88160D38-A17E-489E-B7BD-5221C4FD65BB"
        let dataString = """
        {
          "exercise" : {
            "id" : "\(exerciseId)",
            "name" : "Bench Press"
          },
          "id" : "\(segmentId)",
          "sets" : []
        }
        """

        let data = try #require(dataString.data(using: .utf8))

        let segment = try JSONDecoder().decode(
            Segment.self,
            from: data,
            configuration: VersionedDecodingConfiguration(
                decodedVersion: 1,
                latestVersion: 2
            )
        )

        let expectedSegment = Segment(id: .uuid(segmentId)!, exercise: .uuid(exerciseId)!)

        #expect(segment == expectedSegment)
    }

    @Test
    func `Segment should initialize from v2 data`() async throws {
        let exerciseId = "F8AD5778-2E01-43D6-ACE6-C16F244CAD39"
        let segmentId = "88160D38-A17E-489E-B7BD-5221C4FD65BB"
        let dataString = """
        {
          "exercise" : "\(exerciseId)",
          "id" : "\(segmentId)",
          "sets" : []
        }
        """

        let data = try #require(dataString.data(using: .utf8))

        let segment = try JSONDecoder().decode(
            Segment.self,
            from: data,
            configuration: VersionedDecodingConfiguration(
                decodedVersion: 2,
                latestVersion: 2
            )
        )

        let expectedSegment = Segment(id: .uuid(segmentId)!, exercise: .uuid(exerciseId)!)

        #expect(segment == expectedSegment)
    }

    @Test
    func `Weight.Units should initialize from v1 data`() async throws {
        let dataString = """
        {
            "pounds" : {

            }
        }
        """

        let data = try #require(dataString.data(using: .utf8))

        let units = try JSONDecoder().decode(
            Weight.Units.self,
            from: data,
            configuration: VersionedDecodingConfiguration(
                decodedVersion: 1,
                latestVersion: 2
            )
        )

        #expect(units == .pounds)
    }

    @Test
    func `Weight.Unit should initialize from v2 data`() async throws {
        let dataString = """
        "kilograms"
        """

        let data = try #require(dataString.data(using: .utf8))

        let units = try JSONDecoder().decode(
            Weight.Units.self,
            from: data,
            configuration: VersionedDecodingConfiguration(
                decodedVersion: 2,
                latestVersion: 2
            )
        )

        #expect(units == .kilograms)
    }

    @Test
    func `Weight.Distribution should initialize from v1 data`() async throws {
        let dataString = """
        [
            {
                "total" : {
                    "_0" : 50
                }
            },
            {
                "dumbbell" : {
                    "_0" : 50
                }
            },
            {
                "barbell" : {
                    "plates" : 50,
                    "bar" : 50
                }
            }
        ]
        """

        let data = try #require(dataString.data(using: .utf8))

        let distributions = try JSONDecoder().decode(
            [Weight.Distribution].self,
            from: data,
            configuration: VersionedDecodingConfiguration(
                decodedVersion: 1,
                latestVersion: 2
            )
        )
        let expectedDistributions = [
            Weight.Distribution.total(50),
            .dumbbell(50),
            .barbell(plates: 50, bar: 50)
        ]

        #expect(distributions == expectedDistributions)
    }

    @Test
    func `Weight.Distribution should initialize from v2 data`() async throws {
        let dataString = """
        [
            {
                "total" : 50
            },
            {
                "dumbbell" : 50
            },
            {
                "barbell" : {
                    "plates" : 50,
                    "bar" : 50
                }
            }
        ]
        """

        let data = try #require(dataString.data(using: .utf8))

        let distributions = try JSONDecoder().decode(
            [Weight.Distribution].self,
            from: data,
            configuration: VersionedDecodingConfiguration(
                decodedVersion: 2,
                latestVersion: 2
            )
        )
        let expectedDistributions = [
            Weight.Distribution.total(50),
            .dumbbell(50),
            .barbell(plates: 50, bar: 50)
        ]

        #expect(distributions == expectedDistributions)
    }
}
