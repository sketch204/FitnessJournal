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
    
    @Test func itShouldReturnExercises() {
        let segments = store.segments(for: sampleWorkout.id)
        #expect(segments?.isEmpty == false)
    }
    
    @Test func itShouldNotReturnExercisesForNonExistentWorkout() {
        let segments = store.segments(for: Workout.sample.id)
        #expect(segments == nil)
    }
    
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

// MARK: Exercise CRUD

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
