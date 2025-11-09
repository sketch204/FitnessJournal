//
//  SpyWorkoutStorePersistor.swift
//  Modules
//
//  Created by Inal Gotov on 2025-11-09.
//

import Core
import Data
import Foundation
import Persistance

let testDataFileUrl = Bundle.module.url(forResource: "TestData", withExtension: "json")!

enum SpyWorkoutStorePersistorError: Error {
    case waitTimeout
}

@MainActor
final class SpyWorkoutStorePersistor: WorkoutStorePersistor {
    enum Event {
        case loadWorkouts
        case saveWorkouts
        case loadExercises
        case saveExercises
    }

    private(set) var events: [Event] = []
    let wrapped: FileWorkoutStorePersistor
    let preventWrites: Bool

    init(wrapped: FileWorkoutStorePersistor = .file(testDataFileUrl), preventWrites: Bool = true) {
        self.wrapped = wrapped
        self.preventWrites = preventWrites
    }

    func loadWorkouts() async throws -> [Workout] {
        defer { events.append(.loadWorkouts) }
        return await wrapped.loadWorkouts()
    }

    func saveWorkouts(_ workouts: [Workout]) async throws {
        defer { events.append(.saveWorkouts) }
        guard !preventWrites else { return }
        await wrapped.saveWorkouts(workouts)
    }

    func loadExercises() async throws -> [Exercise] {
        defer { events.append(.loadExercises) }
        return await wrapped.loadExercises()
    }

    func saveExercises(_ exercises: [Exercise]) async throws {
        defer { events.append(.saveExercises) }
        guard !preventWrites else { return }
        await wrapped.saveExercises(exercises)
    }

    func waitUntilStoreLoad() async throws {
        try await waitUntilEvent(.loadWorkouts)
        try await waitUntilEvent(.loadExercises)
    }

    func waitUntilEvent(_ event: Event, timeout: TimeInterval = 1.0) async throws {
        let start = Date()

        while !self.events.contains(event) {
            await Task.yield()

            if Date().timeIntervalSince(start) > timeout {
                throw SpyWorkoutStorePersistorError.waitTimeout
            }
        }
    }
}
