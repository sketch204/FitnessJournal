//
//  FileWorkoutStorePersistorTests.swift
//  Modules
//
//  Created by Inal Gotov on 2025-11-09.
//

import Data
@testable import Persistance
import Testing

@Suite("FileWorkoutStorePersistor")
class FileWorkoutStorePersistorTests {
    var fileIO: MockFileIO
    var persistor: FileWorkoutStorePersistor
    let data: DataWrapper = {
        let benchPress = Exercise(name: "Bench Press")
        let squats = Exercise(name: "Squats")

        return DataWrapper(
            version: 2,
            workouts: [
                Workout(segments: [
                    Segment(exercise: benchPress.id, sets: [
                        Segment.Set(weight: .init(distribution: .total(50), units: .pounds), repetitions: 10),
                        Segment.Set(weight: .init(distribution: .total(50), units: .pounds), repetitions: 10),
                        Segment.Set(weight: .init(distribution: .total(50), units: .pounds), repetitions: 10),
                    ]),
                    Segment(exercise: squats.id, sets: [
                        Segment.Set(weight: .init(distribution: .total(100), units: .pounds), repetitions: 8),
                        Segment.Set(weight: .init(distribution: .total(100), units: .pounds), repetitions: 8),
                        Segment.Set(weight: .init(distribution: .total(100), units: .pounds), repetitions: 8),
                    ]),
                ])
            ],
            exercises: [
                benchPress,
                squats,
            ]
        )
    }()

    init() async throws {
        fileIO = try MockFileIO(data)
        persistor = FileWorkoutStorePersistor(fileIO: fileIO)

        try await fileIO.waitUntilEvent(.read)
        try await #require(fileIO.events.contains(.read))
    }

    @Test func `It should load workouts correctly`() async throws {
        await #expect(persistor.loadWorkouts() == data.workouts)
    }

    @Test func `It should save workouts correctly`() async throws {
        await persistor.saveWorkouts([])
        await #expect(fileIO.events.contains(.write))
    }

    @Test func `It should load exercises correctly`() async throws {
        await #expect(persistor.loadExercises() == data.exercises)
    }

    @Test func `It should save exercises correctly`() async throws {
        await persistor.saveExercises([])
        await #expect(fileIO.events.contains(.write))
    }

    @Test func `It should set up new data when data file does not exist`() async throws {
        fileIO = try MockFileIO(data, fileExistsOverride: false)
        persistor = FileWorkoutStorePersistor(fileIO: fileIO)

        try await fileIO.waitUntilEvent(.fileExists)
        try await #require(fileIO.events.contains(.fileExists))

        await #expect(persistor.loadWorkouts() == [])
        await #expect(persistor.loadExercises() == [])
    }
}
