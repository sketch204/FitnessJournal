//
//  FileWorkoutStorePersistor.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-30.
//

import Data
import Foundation
import Utils

public actor FileWorkoutStorePersistor {
    public static let defaultFileUrl = URL.documentsDirectory.appendingPathComponent("data.json")
    @MainActor
    public static let sampleFileUrl = Bundle.module.url(forResource: "SampleData", withExtension: "json")!
    public static let currentSchemaVersion = Bundle.main.buildNumber

    private let decoder = {
        let output = JSONDecoder()
        output.userInfo[DataWrapper.latestSchemaVersionCodingUserInfoKey] = currentSchemaVersion
        return output
    }()
    private let encoder = {
        let output = JSONEncoder()
        #if DEBUG
        output.outputFormatting = [.sortedKeys, .prettyPrinted]
        #endif
        return output
    }()

    public private(set) var fileUrl: URL {
        didSet {
            Log.core.trace("Set FileWorkoutStorePersistor fileUrl: \(self.fileUrl, privacy: .public)")
        }
    }

    private var data: DataWrapper?
    
    public init(fileUrl: URL = defaultFileUrl) {
        self.fileUrl = fileUrl
        Log.core.trace("Initialized FileWorkoutStorePersistor with fileUrl: \(fileUrl, privacy: .public)")
        
        Task {
            await loadData()
        }
    }
    
    private func loadData() async {
        guard FileManager.default.fileExists(atPath: fileUrl.path(percentEncoded: false)) else {
            self.data = DataWrapper(version: Self.currentSchemaVersion)
            return
        }
        do {
            let fileData = try Data(contentsOf: fileUrl)
            self.data = try decoder.decode(DataWrapper.self, from: fileData)
            if self.data?.version == nil {
                self.data?.version = Self.currentSchemaVersion
            }
        } catch {
            Log.core.critical("Failed to load file data at \(self.fileUrl) due to error! \(error)")
        }
    }
    
    private func saveData(_ data: DataWrapper) async {
        do {
            let fileData = try encoder.encode(data)
            try fileData.write(to: fileUrl, options: .atomic)
        } catch {
            Log.core.critical("Failed to save file data at \(self.fileUrl) due to error! \(error)")
        }
    }
    
    public func loadWorkouts() -> [Workout] {
        data?.workouts ?? []
    }
    
    public func saveWorkouts(_ workouts: [Workout]) async {
        guard data != nil else {
            Log.core.critical("Could not save workouts because no data was loaded!")
            return
        }
        self.data?.workouts = workouts
        await saveData(data!)
    }
    
    public func loadExercises() -> [Exercise] {
        data?.exercises ?? []
    }
    
    public func saveExercises(_ exercises: [Exercise]) async {
        guard data != nil else {
            Log.core.critical("Could not save exercises because no data was loaded!")
            return
        }
        data?.exercises = exercises
        await saveData(data!)
    }

    public func setFileUrl(_ url: URL) async {
        fileUrl = url
        await loadData()
    }
}
