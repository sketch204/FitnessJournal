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

private func expectToEventuallySaveWorkouts(_ persistor: MemoryWorkoutStorePersistor) async {
    func didSave() async -> Bool {
        await persistor.events.contains {
            if case .saveWorkouts = $0 {
                return true
            }
            return false
        }
    }
    
    while await !didSave() {
        await Task.yield()
    }
    #expect(await didSave())
}

private func expectToEventuallySaveExercises(_ persistor: MemoryWorkoutStorePersistor) async {
    func didSave() async -> Bool {
        await persistor.events.contains {
            if case .saveExercises = $0 {
                return true
            }
            return false
        }
    }
    
    while await !didSave() {
        await Task.yield()
    }
    #expect(await didSave())
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
    
    @Test func itShouldLoadWorkoutsOnInit() async throws {
        try #require(store.workouts == [])
        
        try await requireStoreLoad(persistor)
        
        #expect(await store.workouts == persistor.workouts)
    }
    
    @Test func itShouldLoadExercisesOnInit() async throws {
        try #require(store.exercises == [])
        
        try await requireStoreLoad(persistor)
        
        #expect(await store.exercises == persistor.exercises)
    }
}

// MARK: Workout CRUD
 
extension WorkoutStoreTests {
    @MainActor
    @Suite("Workout CRUD")
    struct WorkoutCRUD {
        let sampleWorkout: Workout
        let persistor: MemoryWorkoutStorePersistor
        let store: WorkoutStore
        
        init() async throws {
            let workout = Workout.sample
            sampleWorkout = workout
            persistor = .memory(workouts: [workout])
            store = WorkoutStore(persistor: persistor)
            
            try await requireStoreLoad(persistor)
        }
        
        // MARK: Create
        
        @Test func itShouldCreateWorkouts() async throws{
            let newWorkout = Workout(id: .new, date: Date(), segments: [
                .sampleLegExtensions
            ])
            let createdWorkout = store.createWorkout(newWorkout)
            #expect(createdWorkout == newWorkout)
            #expect(store.workouts == [sampleWorkout, newWorkout])
        }
        
        @Test func itShouldSaveWhenCreatingWorkouts() async throws {
            let newWorkout = Workout(id: .new, date: Date(), segments: [
                .sampleLegExtensions
            ])
            store.createWorkout(newWorkout)
            await expectToEventuallySaveWorkouts(persistor)
        }
        
        // MARK: Update
        
        @Test func itShouldNotUpdateMissingWorkouts() async throws{
            let newWorkout = Workout(id: .new, date: Date(), segments: [
                .sampleLegExtensions
            ])
            let createdWorkout = store.updateWorkout(newWorkout)
            #expect(createdWorkout == nil)
            #expect(store.workouts == [sampleWorkout])
        }
        
        @Test func itShouldUpdateExistingWorkouts() async throws{
            var sample = sampleWorkout
            sample.date = Date()
            sample.segments.removeLast()
            let updatedWorkout = store.updateWorkout(sample)
            #expect(updatedWorkout == sample)
            #expect(store.workouts == [sample])
        }
        
        @Test func itShouldSaveWhenUpdatingWorkouts() async throws {
            var sample = sampleWorkout
            sample.segments.removeLast()
            store.updateWorkout(sample)
            await expectToEventuallySaveWorkouts(persistor)
        }
        
        // MARK: Delete
        
        @Test func itShouldDeleteWorkouts() async throws{
            store.deleteWorkout(sampleWorkout)
            #expect(store.workouts == [])
        }
        
        @Test func itShouldNotDeleteNonExistentWorkouts() async throws{
            let newWorkout = Workout(id: .new, date: Date(), segments: [
                .sampleLegExtensions
            ])
            store.deleteWorkout(newWorkout)
            #expect(store.workouts == [sampleWorkout])
        }
        
        @Test func itShouldSaveWhenDeletingWorkouts() async throws {
            store.deleteWorkout(sampleWorkout)
            await expectToEventuallySaveWorkouts(persistor)
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
        
        init() async throws {
            let workout = Workout.sample
            sampleWorkout = workout
            persistor = .memory(workouts: [workout])
            store = WorkoutStore(persistor: persistor)
            
            try await requireStoreLoad(persistor)
        }
        
        // MARK: Create
        
        @Test func itShouldCreateSegments() async throws{
            let newSegment = Segment.sampleLegExtensions
            let createdSegment = store.createSegment(newSegment, for: sampleWorkout.id)
            #expect(createdSegment == newSegment)
            #expect(store.workouts.first?.segments == sampleWorkout.segments + [newSegment])
        }
        
        @Test func itShouldSaveWhenCreatingSegments() async throws{
            let newSegment = Segment.sampleLegExtensions
            store.createSegment(newSegment, for: sampleWorkout.id)
            await expectToEventuallySaveWorkouts(persistor)
        }
        
        // MARK: Read
        
        @Test func itShouldReturnSegments() async throws{
            let segments = store.segments(for: sampleWorkout.id)
            #expect(segments?.isEmpty == false)
        }
        
        @Test func itShouldNotReturnSegmentsForNonExistentWorkout() async throws{
            let segments = store.segments(for: Workout.sample.id)
            #expect(segments == nil)
        }
        
        // MARK: Update
        
        @Test func itShouldNotUpdateMissingSegments() async throws{
            let newSegment = Segment.sampleLegExtensions
            let createdSegment = store.updateSegment(newSegment, for: sampleWorkout.id)
            #expect(createdSegment == nil)
            #expect(store.workouts == [sampleWorkout])
        }
        
        @Test func itShouldUpdateExistingSegments() async throws{
            var segment = sampleWorkout.segments.last!
            segment.exercise = Exercise(name: "New")
            segment.sets.removeLast()
            let updatedSegment = store.updateSegment(segment, for: sampleWorkout.id)
            #expect(updatedSegment == segment)
            #expect(store.workouts.first?.segments == sampleWorkout.segments.dropLast() + [segment])
        }
        
        @Test func itShouldSaveWhenUpdatingSegments() async throws{
            var segment = sampleWorkout.segments.last!
            segment.exercise = Exercise(name: "New")
            segment.sets.removeLast()
            store.updateSegment(segment, for: sampleWorkout.id)
            await expectToEventuallySaveWorkouts(persistor)
        }
        
        // MARK: Delete
        
        @Test func itShouldDeleteSegments() async throws{
            let segment = sampleWorkout.segments.last!
            store.deleteSegment(segment, for: sampleWorkout.id)
            #expect(store.workouts.first?.segments == sampleWorkout.segments.dropLast())
        }
        
        @Test func itShouldNotDeleteNonExistentSegments() async throws{
            let segment = Segment.sampleLegExtensions
            store.deleteSegment(segment, for: sampleWorkout.id)
            #expect(store.workouts == [sampleWorkout])
        }
        
        @Test func itShouldSaveWhenDeletingSegments() async throws{
            let segment = sampleWorkout.segments.last!
            store.deleteSegment(segment, for: sampleWorkout.id)
            await expectToEventuallySaveWorkouts(persistor)
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
        
        init() async throws {
            let workout = Workout.sample
            sampleWorkout = workout
            sampleSegment = workout.segments.first!
            persistor = .memory(workouts: [workout])
            store = WorkoutStore(persistor: persistor)
            
            try await requireStoreLoad(persistor)
        }
        
        // MARK: Create
        
        @Test func itShouldCreateSets() async throws{
            let newSet = Segment.Set.sampleBarbell
            let createdSet = store.createSet(newSet, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)
            #expect(createdSet == newSet)
            #expect(store.workouts.first?.segments.first!.sets == sampleSegment.sets + [newSet])
        }
        
        @Test func itShouldSaveWhenCreatingSets() async throws{
            let newSet = Segment.Set.sampleBarbell
            store.createSet(newSet, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)
            await expectToEventuallySaveWorkouts(persistor)
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
            let newSet = Segment.Set.sampleBarbell
            let createdSet = store.updateSet(newSet, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)
            #expect(createdSet == nil)
            #expect(store.workouts == [sampleWorkout])
        }
        
        @Test func itShouldUpdateExistingSets() async throws{
            var set = sampleSegment.sets.last!
            set.repetitions = 5
            set.weight = Weight(distribution: .total(0), units: .kilograms)
            let updatedSet = store.updateSet(set, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)
            #expect(updatedSet == set)
            #expect(store.workouts.first?.segments.first?.sets == sampleSegment.sets.dropLast() + [set])
        }
        
        @Test func itShouldSaveWhenUpdatingSets() async throws{
            var set = sampleSegment.sets.last!
            set.repetitions = 5
            set.weight = Weight(distribution: .total(0), units: .kilograms)
            store.updateSet(set, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)
            await expectToEventuallySaveWorkouts(persistor)
        }
        
        // MARK: Delete
        
        @Test func itShouldDeleteSets() async throws{
            let set = sampleSegment.sets.last!
            store.deleteSet(set, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)
            #expect(store.workouts.first?.segments.first?.sets == sampleSegment.sets.dropLast())
        }
        
        @Test func itShouldNotDeleteNonExistentSets() async throws{
            let set = Segment.Set.sampleTotal
            store.deleteSet(set, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)
            #expect(store.workouts == [sampleWorkout])
        }
        
        @Test func itShouldSaveWhenDeletingSets() async throws{
            let set = sampleSegment.sets.last!
            store.deleteSet(set, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)
            await expectToEventuallySaveWorkouts(persistor)
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
        
        init() async throws{
            let exercise = Exercise.sample
            sampleExercise = exercise
            persistor = .memory(exercises: [exercise])
            store = WorkoutStore(persistor: persistor)
            
            try await requireStoreLoad(persistor)
        }
        
        // MARK: Create
        
        @Test func itShouldCreateExercises() async throws{
            let newExercise = Exercise(name: "New")
            let createdExercise = store.createExercise(newExercise)
            #expect(createdExercise == newExercise)
            #expect(store.exercises == [sampleExercise, newExercise])
        }
        
        @Test func itShouldSaveWhenCreatingExercises() async throws{
            let newExercise = Exercise(name: "New")
            store.createExercise(newExercise)
            await expectToEventuallySaveExercises(persistor)
        }
        
        // MARK: Update
        
        @Test func itShouldNotUpdateMissingExercises() async throws{
            let newExercise = Exercise(name: "New")
            let createdExercise = store.updateExercise(newExercise)
            #expect(createdExercise == nil)
            #expect(store.exercises == [sampleExercise])
        }
        
        @Test func itShouldUpdateExistingExercises() async throws{
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
        
        @Test func itShouldSaveWhenUpdatingExercises() async throws{
            var sample = sampleExercise
            sample.name = "New"
            store.updateExercise(sample)
            await expectToEventuallySaveExercises(persistor)
            await expectToEventuallySaveWorkouts(persistor)
        }
        
        // MARK: Delete
        
        @Test func itShouldDeleteExercises() async throws{
            try store.deleteExercise(sampleExercise)
            #expect(store.exercises == [])
        }
        
        @Test func itShouldNotDeleteNonExistentExercises() async throws{
            let newExercise = Exercise(name: "New")
            try store.deleteExercise(newExercise)
            #expect(store.exercises == [sampleExercise])
        }
        
        @Test func itShouldNotDeleteExercisesUsedBySegments() async throws{
            let workout = Workout.sample
            let exercise = workout.segments.first!.exercise
            persistor = .memory(workouts: [workout], exercises: [exercise])
            store = WorkoutStore(persistor: persistor)
            try await requireStoreLoad(persistor)
            
            #expect(throws: WorkoutStoreError.self) {
                try self.store.deleteExercise(exercise)
            }
        }
        
        @Test func itShouldSaveWhenDeletingExercises() async throws{
            try store.deleteExercise(sampleExercise)
            await expectToEventuallySaveExercises(persistor)
        }
    }
}
