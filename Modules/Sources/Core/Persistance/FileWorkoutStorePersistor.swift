//
//  FileWorkoutStorePersistor.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-30.
//

import Data
import Foundation

public actor FileWorkoutStorePersistor: WorkoutStorePersistor {
    private struct DataWrapper: Codable {
        var workouts: [Workout] = []
        var exercises: [Exercise] = []
    }
    
    public static var defaultFileUrl: URL {
        URL.documentsDirectory.appendingPathComponent("data.json")
    }
    
    public let fileUrl: URL
    
    private var data: DataWrapper?
    
    public init(fileUrl: URL = defaultFileUrl) {
        self.fileUrl = fileUrl
        Log.core.trace("Initialized FileWorkoutStorePersistor with fileUrl: \(fileUrl, privacy: .public)")
        
        Task {
            await loadData()
        }
    }
    
    private func loadData() {
        guard FileManager.default.fileExists(atPath: fileUrl.path(percentEncoded: false)) else {
            self.data = DataWrapper()
            return
        }
        do {
            let fileData = try Data(contentsOf: fileUrl)
            self.data = try JSONDecoder().decode(DataWrapper.self, from: fileData)
        } catch {
            Log.core.critical("Failed to load file data at \(self.fileUrl) due to error! \(error)")
        }
    }
    
    private func saveData(_ data: DataWrapper) throws {
        do {
            let fileData = try JSONEncoder().encode(data)
            try fileData.write(to: fileUrl, options: .atomic)
        } catch {
            Log.core.critical("Failed to save file data at \(self.fileUrl) due to error! \(error)")
        }
    }
    
    public func loadWorkouts() async throws -> [Workout] {
        data?.workouts ?? []
    }
    
    public func saveWorkouts(_ workouts: [Workout]) async throws {
        guard let data else {
            Log.core.critical("Could not save workouts because no data was loaded!")
            return
        }
        try saveData(DataWrapper(workouts: workouts, exercises: data.exercises))
    }
    
    public func loadExercises() async throws -> [Exercise] {
        data?.exercises ?? []
    }
    
    public func saveExercises(_ exercises: [Exercise]) async throws {
        guard let data else {
            Log.core.critical("Could not save exercises because no data was loaded!")
            return
        }
        try saveData(DataWrapper(workouts: data.workouts, exercises: exercises))
    }
}

extension WorkoutStorePersistor where Self == FileWorkoutStorePersistor {
    public static var file: Self {
        .file()
    }
    
    public static func file(_ fileUrl: URL = FileWorkoutStorePersistor.defaultFileUrl) -> Self {
        Self(fileUrl: fileUrl)
    }
}
