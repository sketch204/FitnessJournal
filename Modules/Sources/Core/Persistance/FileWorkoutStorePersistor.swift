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
        var version: String?
        var workouts: [Workout] = []
        var exercises: [Exercise] = []
    }
    
    public static var defaultFileUrl: URL {
        URL.documentsDirectory.appendingPathComponent("data.json")
    }

    public static var sampleFileUrl: URL {
        Bundle.main.url(forResource: "SampleData", withExtension: "json")!
    }

    private let decoder = JSONDecoder()
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
            self.data = await DataWrapper(version: Bundle.main.buildNumberString)
            return
        }
        do {
            let fileData = try Data(contentsOf: fileUrl)
            self.data = try decoder.decode(DataWrapper.self, from: fileData)
            if self.data?.version == nil {
                self.data?.version = await Bundle.main.buildNumberString
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

extension WorkoutStorePersistor where Self == FileWorkoutStorePersistor {
    public static var file: Self {
        .file()
    }
    
    public static func file(_ fileUrl: URL = FileWorkoutStorePersistor.defaultFileUrl) -> Self {
        Self(fileUrl: fileUrl)
    }
}
