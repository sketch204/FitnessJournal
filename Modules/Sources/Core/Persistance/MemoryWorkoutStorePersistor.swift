//
//  MemoryWorkoutStorePersistor.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-25.
//

import Data

public actor MemoryWorkoutStorePersistor: WorkoutStorePersistor {
    public enum Event: Hashable, Sendable {
        case loadWorkouts
        case saveWorkouts([Workout])
        case loadExercises
        case saveExercises([Exercise])
    }
    
    public private(set) var events: [Event] = []
    
    public private(set) var workouts: [Workout]
    public private(set) var exercises: [Exercise]
    
    init(workouts: [Workout] = [], exercises: [Exercise] = []) {
        self.workouts = workouts
        self.exercises = exercises
    }
    
    public func loadWorkouts() async throws -> [Data.Workout] {
        events.append(.loadWorkouts)
        return self.workouts
    }
    
    public func saveWorkouts(_ workouts: [Data.Workout]) async throws {
        events.append(.saveWorkouts(workouts))
        self.workouts = workouts
    }
    
    public func loadExercises() async throws -> [Data.Exercise] {
        events.append(.loadExercises)
        return self.exercises
    }
    
    public func saveExercises(_ exercises: [Data.Exercise]) async throws {
        events.append(.saveExercises(exercises))
        self.exercises = exercises
    }
}

extension WorkoutStorePersistor where Self == MemoryWorkoutStorePersistor {
    static var memory: Self {
        .memory()
    }
    
    static func memory(workouts: [Workout] = [], exercises: [Exercise] = []) -> Self {
        MemoryWorkoutStorePersistor(workouts: workouts, exercises: exercises)
    }
    
#if DEBUG
    
    static func preview(
        workouts: [Workout] = [.sample],
        extraExercises: [Exercise] = [],
    ) -> Self {
        let exercises = Set(workouts.flatMap({ $0.segments.map(\.exercise) }))
        
        return .memory(
            workouts: workouts,
            exercises: Array(exercises) + extraExercises
        )
    }
    
#endif
    
}
