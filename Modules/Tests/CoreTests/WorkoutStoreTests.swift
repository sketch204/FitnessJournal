import Foundation
import Testing
@testable import Core
import Data

@Suite("WorkoutStore")
struct WorkoutStoreTests {
    let sampleWorkout: Workout
    let sampleSegment: Segment
    let store: WorkoutStore
    
    init() {
        let workout = Workout.sample
        sampleWorkout = workout
        sampleSegment = workout.segments.first!
        store = WorkoutStore(workouts: [
            workout
        ])
    }
    
    // MARK: Init
    
    @Test func itShouldInitWithWorkouts() {
        #expect(store.workouts == [sampleWorkout])
    }
}

// MARK: Workout CRUD
 
extension WorkoutStoreTests {
    @Suite("Workout CRUD")
    struct WorkoutCRUD {
        let sampleWorkout: Workout
        let store: WorkoutStore
        
        init() {
            let workout = Workout.sample
            sampleWorkout = workout
            store = WorkoutStore(workouts: [
                workout
            ])
        }
        
        // MARK: Create
        
        @Test func itShouldCreateWorkouts() {
            let newWorkout = Workout(id: .new, date: Date(), segments: [
                .sampleLegExtensions
            ])
            let createdWorkout = store.createWorkout(newWorkout)
            #expect(createdWorkout == newWorkout)
            #expect(store.workouts == [sampleWorkout, newWorkout])
        }
        
        // MARK: Update
        
        @Test func itShouldNotUpdateMissingWorkouts() {
            let newWorkout = Workout(id: .new, date: Date(), segments: [
                .sampleLegExtensions
            ])
            let createdWorkout = store.updateWorkout(newWorkout)
            #expect(createdWorkout == nil)
            #expect(store.workouts == [sampleWorkout])
        }
        
        @Test func itShouldUpdateExistingWorkouts() {
            var sample = sampleWorkout
            sample.date = Date()
            sample.segments.removeLast()
            let updatedWorkout = store.updateWorkout(sample)
            #expect(updatedWorkout == sample)
            #expect(store.workouts == [sample])
        }
        
        // MARK: Delete
        
        @Test func itShouldDeleteWorkouts() {
            store.deleteWorkout(sampleWorkout)
            #expect(store.workouts == [])
        }
        
        @Test func itShouldNotDeleteNonExistentWorkouts() {
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
    @Suite("Segments CRUD")
    struct SegmentsCRUD {
        let sampleWorkout: Workout
        let store: WorkoutStore
        
        init() {
            let workout = Workout.sample
            sampleWorkout = workout
            store = WorkoutStore(workouts: [
                workout
            ])
        }
        
        // MARK: Create
        
        @Test func itShouldCreateSegments() {
            let newSegment = Segment.sampleLegExtensions
            let createdSegment = store.createSegment(newSegment, for: sampleWorkout.id)
            #expect(createdSegment == newSegment)
            #expect(store.workouts.first?.segments == sampleWorkout.segments + [newSegment])
        }
        
        // MARK: Read
        
        @Test func itShouldReturnSegments() {
            let segments = store.segments(for: sampleWorkout.id)
            #expect(segments?.isEmpty == false)
        }
        
        @Test func itShouldNotReturnSegmentsForNonExistentWorkout() {
            let segments = store.segments(for: Workout.sample.id)
            #expect(segments == nil)
        }
        
        // MARK: Update
        
        @Test func itShouldNotUpdateMissingSegments() {
            let newSegment = Segment.sampleLegExtensions
            let createdSegment = store.updateSegment(newSegment, for: sampleWorkout.id)
            #expect(createdSegment == nil)
            #expect(store.workouts == [sampleWorkout])
        }
        
        @Test func itShouldUpdateExistingSegments() {
            var segment = sampleWorkout.segments.last!
            segment.exercise = Exercise(name: "New")
            segment.sets.removeLast()
            let updatedSegment = store.updateSegment(segment, for: sampleWorkout.id)
            #expect(updatedSegment == segment)
            #expect(store.workouts.first?.segments == sampleWorkout.segments.dropLast() + [segment])
        }
        
        // MARK: Delete
        
        @Test func itShouldDeleteSegments() {
            let segment = sampleWorkout.segments.last!
            store.deleteSegment(segment, for: sampleWorkout.id)
            #expect(store.workouts.first?.segments == sampleWorkout.segments.dropLast())
        }
        
        @Test func itShouldNotDeleteNonExistentSegments() {
            let segment = Segment.sampleLegExtensions
            store.deleteSegment(segment, for: sampleWorkout.id)
            #expect(store.workouts == [sampleWorkout])
        }
    }
}

// MARK: Sets CRUD

extension WorkoutStoreTests {
    @Suite("Sets CRUD")
    struct SetsCRUD {
        let sampleWorkout: Workout
        let sampleSegment: Segment
        let store: WorkoutStore
        
        init() {
            let workout = Workout.sample
            sampleWorkout = workout
            sampleSegment = workout.segments.first!
            store = WorkoutStore(workouts: [
                workout
            ])
        }
        
        // MARK: Create
        
        @Test func itShouldCreateSets() {
            let newSet = Segment.Set.sampleBarbell
            let createdSet = store.createSet(newSet, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)
            #expect(createdSet == newSet)
            #expect(store.workouts.first?.segments.first!.sets == sampleSegment.sets + [newSet])
        }
        
        // MARK: Read
        
        @Test func itShouldReturnSets() {
            let sets = store.sets(segmentId: sampleSegment.id, workoutId: sampleWorkout.id)
            #expect(sets?.isEmpty == false)
        }
        
        @Test func itShouldNotReturnSetsForNonExistentWorkout() {
            let sets = store.sets(segmentId: sampleSegment.id, workoutId: .new)
            #expect(sets == nil)
        }
        
        @Test func itShouldNotReturnSetsForNonExistentExercise() {
            let sets = store.sets(segmentId: .new, workoutId: sampleWorkout.id)
            #expect(sets == nil)
        }
        
        // MARK: Update
        
        @Test func itShouldNotUpdateMissingSets() {
            let newSet = Segment.Set.sampleBarbell
            let createdSet = store.updateSet(newSet, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)
            #expect(createdSet == nil)
            #expect(store.workouts == [sampleWorkout])
        }
        
        @Test func itShouldUpdateExistingSets() {
            var set = sampleSegment.sets.last!
            set.repetitions = 5
            set.weight = Weight(distribution: .total(0), units: .kilograms)
            let updatedSet = store.updateSet(set, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)
            #expect(updatedSet == set)
            #expect(store.workouts.first?.segments.first?.sets == sampleSegment.sets.dropLast() + [set])
        }
        
        // MARK: Delete
        
        @Test func itShouldDeleteSets() {
            let set = sampleSegment.sets.last!
            store.deleteSet(set, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)
            #expect(store.workouts.first?.segments.first?.sets == sampleSegment.sets.dropLast())
        }
        
        @Test func itShouldNotDeleteNonExistentSets() {
            let set = Segment.Set.sampleTotal
            store.deleteSet(set, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)
            #expect(store.workouts == [sampleWorkout])
        }
    }
}

// MARK: Exercises CRUD
 
extension WorkoutStoreTests {
    @Suite("Exercises CRUD")
    class ExercisesCRUD {
        let sampleExercise: Exercise
        var store: WorkoutStore
        
        init() {
            let exercise = Exercise.sample
            sampleExercise = exercise
            store = WorkoutStore(exercises: [
                exercise,
            ])
        }
        
        // MARK: Create
        
        @Test func itShouldCreateExercises() {
            let newExercise = Exercise(name: "New")
            let createdExercise = store.createExercise(newExercise)
            #expect(createdExercise == newExercise)
            #expect(store.exercises == [sampleExercise, newExercise])
        }
        
        // MARK: Update
        
        @Test func itShouldNotUpdateMissingExercises() {
            let newExercise = Exercise(name: "New")
            let createdExercise = store.updateExercise(newExercise)
            #expect(createdExercise == nil)
            #expect(store.exercises == [sampleExercise])
        }
        
        @Test func itShouldUpdateExistingExercises() {
            var sample = sampleExercise
            sample.name = "New"
            let updatedExercise = store.updateExercise(sample)
            #expect(updatedExercise == sample)
            #expect(store.exercises == [sample])
        }
        
        @Test func itShouldUpdateSegmentsUsingUpdatedExercise() {
            let workout = Workout.sample
            var exercise = workout.segments.first!.exercise
            store = WorkoutStore(exercises: [exercise], workouts: [workout])
            
            exercise.name = "New"
            store.updateExercise(exercise)
            
            #expect(store.workouts.first!.segments.first!.exercise == exercise)
        }
        
        // MARK: Delete
        
        @Test func itShouldDeleteExercises() throws {
            try store.deleteExercise(sampleExercise)
            #expect(store.exercises == [])
        }
        
        @Test func itShouldNotDeleteNonExistentExercises() throws {
            let newExercise = Exercise(name: "New")
            try store.deleteExercise(newExercise)
            #expect(store.exercises == [sampleExercise])
        }
        
        @Test func itShouldNotDeleteExercisesUsedBySegments() {
            let workout = Workout.sample
            let exercise = workout.segments.first!.exercise
            store = WorkoutStore(exercises: [exercise], workouts: [workout])
            
            #expect(throws: WorkoutStoreError.exerciseUsedInSegments) {
                try self.store.deleteExercise(exercise)
            }
        }
    }
}
