import Foundation
import Testing
@testable import Core
import Data

private func requireStoreLoad(_ persistor: MemoryWorkoutStorePersistor) async throws {
    while await !persistor.events.contains(.loadWorkouts) {
        await Task.yield()
    }
    while await !persistor.events.contains(.loadExercises) {
        await Task.yield()
    }
    try await #require(persistor.events.contains(.loadWorkouts))
    try await #require(persistor.events.contains(.loadExercises))
}

@MainActor
@Suite("WorkoutStore")
struct WorkoutStoreTests {
    let sampleWorkout: Workout
    let sampleSegment: Segment
    let persistor: MemoryWorkoutStorePersistor
    let store: WorkoutStore
    
    init() {
        let workout = Workout.sample
        sampleWorkout = workout
        sampleSegment = workout.segments.first!
        persistor = .memory(workouts: [workout])
        store = WorkoutStore(persistor: persistor)
    }
    
    // MARK: Init
    
    @Test func itShouldInitWithWorkouts() async throws{
        try await requireStoreLoad(persistor)
        #expect(store.workouts == [sampleWorkout])
    }
    
    #warning("TODO: Add persistence tests")
}

// MARK: Workout CRUD
 
extension WorkoutStoreTests {
    @MainActor
    @Suite("Workout CRUD")
    struct WorkoutCRUD {
        let sampleWorkout: Workout
        let persistor: MemoryWorkoutStorePersistor
        let store: WorkoutStore
        
        init() {
            let workout = Workout.sample
            sampleWorkout = workout
            persistor = .memory(workouts: [workout])
            store = WorkoutStore(persistor: persistor)
        }
        
        // MARK: Create
        
        @Test func itShouldCreateWorkouts() async throws{
            try await requireStoreLoad(persistor)
            let newWorkout = Workout(id: .new, date: Date(), segments: [
                .sampleLegExtensions
            ])
            let createdWorkout = store.createWorkout(newWorkout)
            #expect(createdWorkout == newWorkout)
            #expect(store.workouts == [sampleWorkout, newWorkout])
        }
        
        // MARK: Update
        
        @Test func itShouldNotUpdateMissingWorkouts() async throws{
            try await requireStoreLoad(persistor)
            let newWorkout = Workout(id: .new, date: Date(), segments: [
                .sampleLegExtensions
            ])
            let createdWorkout = store.updateWorkout(newWorkout)
            #expect(createdWorkout == nil)
            #expect(store.workouts == [sampleWorkout])
        }
        
        @Test func itShouldUpdateExistingWorkouts() async throws{
            try await requireStoreLoad(persistor)
            var sample = sampleWorkout
            sample.date = Date()
            sample.segments.removeLast()
            let updatedWorkout = store.updateWorkout(sample)
            #expect(updatedWorkout == sample)
            #expect(store.workouts == [sample])
        }
        
        // MARK: Delete
        
        @Test func itShouldDeleteWorkouts() async throws{
            try await requireStoreLoad(persistor)
            store.deleteWorkout(sampleWorkout)
            #expect(store.workouts == [])
        }
        
        @Test func itShouldNotDeleteNonExistentWorkouts() async throws{
            try await requireStoreLoad(persistor)
            let newWorkout = Workout(id: .new, date: Date(), segments: [
                .sampleLegExtensions
            ])
            store.deleteWorkout(newWorkout)
            #expect(store.workouts == [sampleWorkout])
        }
    }
}

// MARK: Segments CRUD

extension WorkoutStoreTests {
    @MainActor
    @Suite("Segments CRUD")
    struct SegmentsCRUD {
        let sampleWorkout: Workout
        let persistor: MemoryWorkoutStorePersistor
        let store: WorkoutStore
        
        init() {
            let workout = Workout.sample
            sampleWorkout = workout
            persistor = .memory(workouts: [workout])
            store = WorkoutStore(persistor: persistor)
        }
        
        // MARK: Create
        
        @Test func itShouldCreateSegments() async throws{
            try await requireStoreLoad(persistor)
            let newSegment = Segment.sampleLegExtensions
            let createdSegment = store.createSegment(newSegment, for: sampleWorkout.id)
            #expect(createdSegment == newSegment)
            #expect(store.workouts.first?.segments == sampleWorkout.segments + [newSegment])
        }
        
        // MARK: Read
        
        @Test func itShouldReturnSegments() async throws{
            try await requireStoreLoad(persistor)
            let segments = store.segments(for: sampleWorkout.id)
            #expect(segments?.isEmpty == false)
        }
        
        @Test func itShouldNotReturnSegmentsForNonExistentWorkout() async throws{
            try await requireStoreLoad(persistor)
            let segments = store.segments(for: Workout.sample.id)
            #expect(segments == nil)
        }
        
        // MARK: Update
        
        @Test func itShouldNotUpdateMissingSegments() async throws{
            try await requireStoreLoad(persistor)
            let newSegment = Segment.sampleLegExtensions
            let createdSegment = store.updateSegment(newSegment, for: sampleWorkout.id)
            #expect(createdSegment == nil)
            #expect(store.workouts == [sampleWorkout])
        }
        
        @Test func itShouldUpdateExistingSegments() async throws{
            try await requireStoreLoad(persistor)
            var segment = sampleWorkout.segments.last!
            segment.exercise = Exercise(name: "New")
            segment.sets.removeLast()
            let updatedSegment = store.updateSegment(segment, for: sampleWorkout.id)
            #expect(updatedSegment == segment)
            #expect(store.workouts.first?.segments == sampleWorkout.segments.dropLast() + [segment])
        }
        
        // MARK: Delete
        
        @Test func itShouldDeleteSegments() async throws{
            try await requireStoreLoad(persistor)
            let segment = sampleWorkout.segments.last!
            store.deleteSegment(segment, for: sampleWorkout.id)
            #expect(store.workouts.first?.segments == sampleWorkout.segments.dropLast())
        }
        
        @Test func itShouldNotDeleteNonExistentSegments() async throws{
            try await requireStoreLoad(persistor)
            let segment = Segment.sampleLegExtensions
            store.deleteSegment(segment, for: sampleWorkout.id)
            #expect(store.workouts == [sampleWorkout])
        }
    }
}

// MARK: Sets CRUD

extension WorkoutStoreTests {
    @MainActor
    @Suite("Sets CRUD")
    struct SetsCRUD {
        let sampleWorkout: Workout
        let sampleSegment: Segment
        let persistor: MemoryWorkoutStorePersistor
        let store: WorkoutStore
        
        init() {
            let workout = Workout.sample
            sampleWorkout = workout
            sampleSegment = workout.segments.first!
            persistor = .memory(workouts: [workout])
            store = WorkoutStore(persistor: persistor)
        }
        
        // MARK: Create
        
        @Test func itShouldCreateSets() async throws{
            try await requireStoreLoad(persistor)
            let newSet = Segment.Set.sampleBarbell
            let createdSet = store.createSet(newSet, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)
            #expect(createdSet == newSet)
            #expect(store.workouts.first?.segments.first!.sets == sampleSegment.sets + [newSet])
        }
        
        // MARK: Read
        
        @Test func itShouldReturnSets() async throws{
            try await requireStoreLoad(persistor)
            let sets = store.sets(segmentId: sampleSegment.id, workoutId: sampleWorkout.id)
            #expect(sets?.isEmpty == false)
        }
        
        @Test func itShouldNotReturnSetsForNonExistentWorkout() async throws{
            try await requireStoreLoad(persistor)
            let sets = store.sets(segmentId: sampleSegment.id, workoutId: .new)
            #expect(sets == nil)
        }
        
        @Test func itShouldNotReturnSetsForNonExistentExercise() async throws{
            try await requireStoreLoad(persistor)
            let sets = store.sets(segmentId: .new, workoutId: sampleWorkout.id)
            #expect(sets == nil)
        }
        
        // MARK: Update
        
        @Test func itShouldNotUpdateMissingSets() async throws{
            try await requireStoreLoad(persistor)
            let newSet = Segment.Set.sampleBarbell
            let createdSet = store.updateSet(newSet, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)
            #expect(createdSet == nil)
            #expect(store.workouts == [sampleWorkout])
        }
        
        @Test func itShouldUpdateExistingSets() async throws{
            try await requireStoreLoad(persistor)
            var set = sampleSegment.sets.last!
            set.repetitions = 5
            set.weight = Weight(distribution: .total(0), units: .kilograms)
            let updatedSet = store.updateSet(set, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)
            #expect(updatedSet == set)
            #expect(store.workouts.first?.segments.first?.sets == sampleSegment.sets.dropLast() + [set])
        }
        
        // MARK: Delete
        
        @Test func itShouldDeleteSets() async throws{
            try await requireStoreLoad(persistor)
            let set = sampleSegment.sets.last!
            store.deleteSet(set, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)
            #expect(store.workouts.first?.segments.first?.sets == sampleSegment.sets.dropLast())
        }
        
        @Test func itShouldNotDeleteNonExistentSets() async throws{
            try await requireStoreLoad(persistor)
            let set = Segment.Set.sampleTotal
            store.deleteSet(set, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)
            #expect(store.workouts == [sampleWorkout])
        }
    }
}

// MARK: Exercises CRUD
 
extension WorkoutStoreTests {
    @MainActor
    @Suite("Exercises CRUD")
    class ExercisesCRUD {
        let sampleExercise: Exercise
        var persistor: MemoryWorkoutStorePersistor
        var store: WorkoutStore
        
        init() {
            let exercise = Exercise.sample
            sampleExercise = exercise
            persistor = .memory(exercises: [exercise])
            store = WorkoutStore(persistor: persistor)
        }
        
        // MARK: Create
        
        @Test func itShouldCreateExercises() async throws{
            try await requireStoreLoad(persistor)
            let newExercise = Exercise(name: "New")
            let createdExercise = store.createExercise(newExercise)
            #expect(createdExercise == newExercise)
            #expect(store.exercises == [sampleExercise, newExercise])
        }
        
        // MARK: Update
        
        @Test func itShouldNotUpdateMissingExercises() async throws{
            try await requireStoreLoad(persistor)
            let newExercise = Exercise(name: "New")
            let createdExercise = store.updateExercise(newExercise)
            #expect(createdExercise == nil)
            #expect(store.exercises == [sampleExercise])
        }
        
        @Test func itShouldUpdateExistingExercises() async throws{
            try await requireStoreLoad(persistor)
            var sample = sampleExercise
            sample.name = "New"
            let updatedExercise = store.updateExercise(sample)
            #expect(updatedExercise == sample)
            #expect(store.exercises == [sample])
        }
        
        @Test func itShouldUpdateSegmentsUsingUpdatedExercise() async throws{
            let workout = Workout.sample
            var exercise = workout.segments.first!.exercise
            persistor = .memory(workouts: [workout], exercises: [exercise])
            store = WorkoutStore(persistor: persistor)
            try await requireStoreLoad(persistor)
            
            exercise.name = "New"
            store.updateExercise(exercise)
            
            #expect(store.workouts.first!.segments.first!.exercise == exercise)
        }
        
        // MARK: Delete
        
        @Test func itShouldDeleteExercises() async throws{
            try await requireStoreLoad(persistor)
            try store.deleteExercise(sampleExercise)
            #expect(store.exercises == [])
        }
        
        @Test func itShouldNotDeleteNonExistentExercises() async throws{
            try await requireStoreLoad(persistor)
            let newExercise = Exercise(name: "New")
            try store.deleteExercise(newExercise)
            #expect(store.exercises == [sampleExercise])
        }
        
        @Test func itShouldNotDeleteExercisesUsedBySegments() async throws{
            try await requireStoreLoad(persistor)
            let workout = Workout.sample
            let exercise = workout.segments.first!.exercise
            persistor = .memory(workouts: [workout], exercises: [exercise])
            store = WorkoutStore(persistor: persistor)
            try await requireStoreLoad(persistor)
            
            #expect(throws: WorkoutStoreError.self) {
                try self.store.deleteExercise(exercise)
            }
        }
    }
}
