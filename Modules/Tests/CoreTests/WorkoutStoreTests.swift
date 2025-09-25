import Foundation
import Testing
@testable import Core
import Data

@Suite("WorkoutStore")
struct WorkoutStoreTests {
    let sampleWorkout: Workout
    let sampleExercise: Exercise
    let store: WorkoutStore
    
    init() {
        let workout = Workout.sample
        sampleWorkout = workout
        sampleExercise = workout.exercises.first!
        store = WorkoutStore(workouts: [
            workout
        ])
    }
    
    // MARK: Init
    
    @Test func itShouldInitWithWorkouts() {
        #expect(store.workouts == [sampleWorkout])
    }
    
    @Test func itShouldReturnExercises() {
        let exercises = store.exercises(for: sampleWorkout.id)
        #expect(exercises?.isEmpty == false)
    }
    
    @Test func itShouldNotReturnExercisesForNonExistentWorkout() {
        let exercises = store.exercises(for: Workout.sample.id)
        #expect(exercises == nil)
    }
    
    @Test func itShouldReturnSets() {
        let sets = store.sets(for: sampleWorkout.id, in: sampleExercise.id)
        #expect(sets?.isEmpty == false)
    }
    
    @Test func itShouldNotReturnSetsForNonExistentWorkout() {
        let sets = store.sets(for: Workout.sample.id, in: sampleExercise.id)
        #expect(sets == nil)
    }
    
    @Test func itShouldNotReturnSetsForNonExistentExercise() {
        let sets = store.sets(for: sampleWorkout.id, in: Exercise.sample.id)
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
            let newWorkout = Workout(id: .new, date: Date(), exercises: [
                .sampleLegExtensions
            ])
            let createdWorkout = store.createWorkout(newWorkout)
            #expect(createdWorkout == newWorkout)
            #expect(store.workouts == [sampleWorkout, newWorkout])
        }
        
        // MARK: Update
        
        @Test func itShouldCreateMissingWorkouts() {
            let newWorkout = Workout(id: .new, date: Date(), exercises: [
                .sampleLegExtensions
            ])
            let createdWorkout = store.updateWorkout(newWorkout, createIfMissing: true)
            #expect(createdWorkout == newWorkout)
            #expect(store.workouts == [sampleWorkout, newWorkout])
        }
        
        @Test func itShouldNotCreateOrUpdateMissingWorkoutsWhenNotNeeded() {
            let newWorkout = Workout(id: .new, date: Date(), exercises: [
                .sampleLegExtensions
            ])
            let createdWorkout = store.updateWorkout(newWorkout, createIfMissing: false)
            #expect(createdWorkout == nil)
            #expect(store.workouts == [sampleWorkout])
        }
        
        @Test func itShouldUpdateExistingWorkouts() {
            var sample = sampleWorkout
            sample.date = Date()
            sample.exercises.removeLast()
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
            let newWorkout = Workout(id: .new, date: Date(), exercises: [
                .sampleLegExtensions
            ])
            store.deleteWorkout(newWorkout)
            #expect(store.workouts == [sampleWorkout])
        }
    }
}

// MARK: Exercise CRUD

extension WorkoutStoreTests {
    @Suite("Exercise CRUD")
    struct ExerciseCRUD {
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
        
        @Test func itShouldCreateExercises() {
            let newExercise = Exercise.sampleLegExtensions
            let createdExercise = store.createExercise(newExercise, for: sampleWorkout.id)
            #expect(createdExercise == newExercise)
            #expect(store.workouts.first?.exercises == sampleWorkout.exercises + [newExercise])
        }
        
        // MARK: Update
        
        @Test func itShouldCreateMissingWorkouts() {
            let newExercise = Exercise.sampleLegExtensions
            let createdExercise = store.updateExercise(newExercise, for: sampleWorkout.id, createIfMissing: true)
            #expect(createdExercise == newExercise)
            #expect(store.workouts.first?.exercises == sampleWorkout.exercises + [newExercise])
        }
        
        @Test func itShouldNotCreateOrUpdateMissingWorkoutsWhenNotNeeded() {
            let newExercise = Exercise.sampleLegExtensions
            let createdExercise = store.updateExercise(newExercise, for: sampleWorkout.id, createIfMissing: false)
            #expect(createdExercise == nil)
            #expect(store.workouts == [sampleWorkout])
        }
        
        @Test func itShouldUpdateExistingWorkouts() {
            var exercise = sampleWorkout.exercises.last!
            exercise.name = "Something else"
            exercise.sets.removeLast()
            let updatedExercise = store.updateExercise(exercise, for: sampleWorkout.id)
            #expect(updatedExercise == exercise)
            #expect(store.workouts.first?.exercises == sampleWorkout.exercises.dropLast() + [exercise])
        }
        
        // MARK: Delete
        
        @Test func itShouldDeleteWorkouts() {
            let exercise = sampleWorkout.exercises.last!
            store.deleteExercise(exercise, for: sampleWorkout.id)
            #expect(store.workouts.first?.exercises == sampleWorkout.exercises.dropLast())
        }
        
        @Test func itShouldNotDeleteNonExistentWorkouts() {
            let exercise = Exercise.sampleLegExtensions
            store.deleteExercise(exercise, for: sampleWorkout.id)
            #expect(store.workouts == [sampleWorkout])
        }
    }
}

// MARK: Sets CRUD

extension WorkoutStoreTests {
    @Suite("Sets CRUD")
    struct SetsCRUD {
        let sampleWorkout: Workout
        let sampleExercise: Exercise
        let store: WorkoutStore
        
        init() {
            let workout = Workout.sample
            sampleWorkout = workout
            sampleExercise = workout.exercises.first!
            store = WorkoutStore(workouts: [
                workout
            ])
        }
        
        // MARK: Create
        
        @Test func itShouldCreateSets() {
            let newSet = Exercise.Set.sampleBarbell
            let createdSet = store.createSet(newSet, in: sampleExercise.id, for: sampleWorkout.id)
            #expect(createdSet == newSet)
            #expect(store.workouts.first?.exercises.first!.sets == sampleExercise.sets + [newSet])
        }
        
        // MARK: Update
        
        @Test func itShouldCreateMissingSets() {
            let newSet = Exercise.Set.sampleBarbell
            let createdSet = store.updateSet(newSet, in: sampleExercise.id, for: sampleWorkout.id, createIfMissing: true)
            #expect(createdSet == newSet)
            #expect(store.workouts.first?.exercises.first!.sets == sampleExercise.sets + [newSet])
        }
        
        @Test func itShouldNotCreateOrUpdateMissingWorkoutsWhenNotNeeded() {
            let newSet = Exercise.Set.sampleBarbell
            let createdSet = store.updateSet(newSet, in: sampleExercise.id, for: sampleWorkout.id, createIfMissing: false)
            #expect(createdSet == nil)
            #expect(store.workouts == [sampleWorkout])
        }
        
        @Test func itShouldUpdateExistingWorkouts() {
            var set = sampleExercise.sets.last!
            set.repetitions = 5
            set.weight = Weight(distribution: .total(0), units: .kilograms)
            let updatedSet = store.updateSet(set, in: sampleExercise.id, for: sampleWorkout.id)
            #expect(updatedSet == set)
            #expect(store.workouts.first?.exercises.first?.sets == sampleExercise.sets.dropLast() + [set])
        }
        
        // MARK: Delete
        
        @Test func itShouldDeleteWorkouts() {
            let set = sampleExercise.sets.last!
            store.deleteSet(set, in: sampleExercise.id, for: sampleWorkout.id)
            #expect(store.workouts.first?.exercises.first?.sets == sampleExercise.sets.dropLast())
        }
        
        @Test func itShouldNotDeleteNonExistentWorkouts() {
            let set = Exercise.Set.sampleTotal
            store.deleteSet(set, in: sampleExercise.id, for: sampleWorkout.id)
            #expect(store.workouts == [sampleWorkout])
        }
    }
}
