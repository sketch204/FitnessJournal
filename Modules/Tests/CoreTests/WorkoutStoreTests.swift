import Foundation
import Testing
@testable import Core
import Data

@Suite("WorkoutStore")
struct WorkoutStoreTests {
    let persistor: SpyWorkoutStorePersistor
    let store: WorkoutStore
    
    init() {
        persistor = SpyWorkoutStorePersistor()
        store = WorkoutStore(persistor: persistor)
    }
    
    // MARK: Init
    
    @Test func `It should load workouts on init`() async throws {
        try #require(store.workouts == [])
        
        try await persistor.waitUntilStoreLoad()

        #expect(store.workouts.isEmpty == false)
    }
    
    @Test func `It should load exercises on init`() async throws {
        try #require(store.exercises == [])
        
        try await persistor.waitUntilStoreLoad()

        #expect(store.exercises.isEmpty == false)
    }
}

// MARK: Workout CRUD
 
extension WorkoutStoreTests {
    @Suite("Workout CRUD")
    struct WorkoutCRUD {
        let persistor: SpyWorkoutStorePersistor
        let store: WorkoutStore
        let sampleWorkout: Workout
        let originalWorkouts: [Workout]

        init() async throws {
            persistor = SpyWorkoutStorePersistor()
            store = WorkoutStore(persistor: persistor)

            try await persistor.waitUntilStoreLoad()

            sampleWorkout = store.workouts.first!
            originalWorkouts = store.workouts
        }
        
        // MARK: Create
        
        @Test func `it should create workouts`() {
            let newWorkout = Workout()
            let createdWorkout = store.createWorkout(newWorkout)
            #expect(createdWorkout == newWorkout)
            #expect(store.workouts == originalWorkouts + [newWorkout])
        }
        
        @Test func `It should save when creating workouts`() async throws {
            let newWorkout = Workout()
            store.createWorkout(newWorkout)

            try await persistor.waitUntilEvent(.saveWorkouts)
            #expect(persistor.events.contains(.saveWorkouts))
        }

        // MARK: Read

        @Test func `It should return workouts`() {
            #expect(store.workout(with: sampleWorkout.id) == sampleWorkout)
        }

        @Test func `It should not return non-existent workouts`() {
            #expect(store.workout(with: .new) == nil)
        }

        // MARK: Update
        
        @Test func `It should not update missing workouts`() {
            let newWorkout = Workout()
            let createdWorkout = store.updateWorkout(newWorkout)
            #expect(createdWorkout == nil)
            #expect(store.workouts == originalWorkouts)
        }
        
        @Test func `It should update existing workouts`() {
            var sample: Workout!

            let updatedWorkout = store.updateWorkout(with: sampleWorkout.id) { workout in
                workout.date = Date()
                workout.segments.removeLast()

                sample = workout
            }

            #expect(updatedWorkout == sample)
            let expectedWorkouts = originalWorkouts.map {
                $0.id == sample.id ? sample : $0
            }
            #expect(store.workouts == expectedWorkouts)
        }

        @Test func `It should save when updating workouts`() async throws {
            var sample = sampleWorkout
            sample.segments.removeLast()

            store.updateWorkout(sample)

            try await persistor.waitUntilEvent(.saveWorkouts)
            #expect(persistor.events.contains(.saveWorkouts))
        }
        
        // MARK: Delete
        
        @Test func `It should delete workouts`() {
            store.deleteWorkout(sampleWorkout)

            #expect(store.workouts == originalWorkouts.filter({ $0.id != sampleWorkout.id }))
        }
        
        @Test func `It should not delete non-existent workouts`() {
            let newWorkout = Workout()
            store.deleteWorkout(newWorkout)
            #expect(store.workouts == originalWorkouts)
        }
        
        @Test func `It should save when deleting workouts`() async throws {
            store.deleteWorkout(sampleWorkout)

            try await persistor.waitUntilEvent(.saveWorkouts)
            #expect(persistor.events.contains(.saveWorkouts))
        }
    }
}

// MARK: Segments CRUD

extension WorkoutStoreTests {
    @Suite("Segments CRUD")
    struct SegmentsCRUD {
        let persistor: SpyWorkoutStorePersistor
        let store: WorkoutStore
        let sampleWorkout: Workout
        let originalWorkouts: [Workout]

        init() async throws {
            persistor = SpyWorkoutStorePersistor()
            store = WorkoutStore(persistor: persistor)

            try await persistor.waitUntilStoreLoad()

            sampleWorkout = store.workouts.first!
            originalWorkouts = store.workouts
        }

        // MARK: Create
        
        @Test func `It should create segments`() {
            let newSegment = Segment(exercise: .new)

            let createdSegment = store.createSegment(newSegment, for: sampleWorkout.id)

            #expect(createdSegment == newSegment)
            #expect(store.workout(with: sampleWorkout.id)?.segments == sampleWorkout.segments + [newSegment])
        }
        
        @Test func `It should save when creating segments`() async throws {
            let newSegment = Segment(exercise: .new)

            store.createSegment(newSegment, for: sampleWorkout.id)

            try await persistor.waitUntilEvent(.saveWorkouts)
            #expect(persistor.events.contains(.saveWorkouts))
        }
        
        // MARK: Read
        
        @Test func `It should return segments`() {
            let segments = store.segments(for: sampleWorkout.id)
            #expect(segments?.isEmpty == false)
        }
        
        @Test func `It should not return segments for non-existent workouts`() {
            let segments = store.segments(for: .new)
            #expect(segments == nil)
        }
        
        // MARK: Update
        
        @Test func `It should not update non-existent segments`() {
            let newSegment = Segment(exercise: .new)

            let createdSegment = store.updateSegment(newSegment, for: sampleWorkout.id)

            #expect(createdSegment == nil)
            #expect(store.workouts == originalWorkouts)
        }
        
        @Test func `It should update existing segments`() {
            var sample: Segment!

            let updatedSegment = store.updateSegment(
                segmentId: sampleWorkout.segments.last!.id,
                workoutId: sampleWorkout.id,
                update: { segment in
                    segment.exercise = .new
                    segment.sets.removeLast()

                    sample = segment
                }
            )

            #expect(updatedSegment == sample)
            let expectedSegments = sampleWorkout.segments.map { $0.id == sample.id ? sample : $0 }
            #expect(store.segments(for: sampleWorkout.id) == expectedSegments)
        }
        
        @Test func `It should save when updating segments`() async throws {
            var segment = sampleWorkout.segments.last!
            segment.exercise = .new
            segment.sets.removeLast()

            store.updateSegment(segment, for: sampleWorkout.id)

            try await persistor.waitUntilEvent(.saveWorkouts)
            #expect(persistor.events.contains(.saveWorkouts))
        }

        // MARK: Move

        @Test func `It should move segments in a workout`() {
            store.moveSegments(
                at: IndexSet(integer: sampleWorkout.segments.startIndex),
                to: sampleWorkout.segments.endIndex,
                for: sampleWorkout.id
            )

            let expectedSegments = sampleWorkout.segments.dropFirst() + [sampleWorkout.segments.first!]
            #expect(store.segments(for: sampleWorkout.id) == Array(expectedSegments))
        }

        @Test func `It should call save after moving segments`() async throws {
            store.moveSegments(
                at: IndexSet(integer: sampleWorkout.segments.startIndex),
                to: sampleWorkout.segments.endIndex - 1,
                for: sampleWorkout.id
            )

            try await persistor.waitUntilEvent(.saveWorkouts)
            #expect(persistor.events.contains(.saveWorkouts))
        }

        // MARK: Delete
        
        @Test func `It should delete segments`() {
            let segment = sampleWorkout.segments.last!

            store.deleteSegment(segment, for: sampleWorkout.id)

            #expect(store.workout(with: sampleWorkout.id)?.segments == sampleWorkout.segments.dropLast())
        }
        
        @Test func `It should not delete non-existent segments`() {
            let segment = Segment(exercise: .new)

            store.deleteSegment(segment, for: sampleWorkout.id)

            #expect(store.workouts == originalWorkouts)
        }
        
        @Test func `It should save when deleting segments`() async throws {
            let segment = sampleWorkout.segments.last!

            store.deleteSegment(segment, for: sampleWorkout.id)

            try await persistor.waitUntilEvent(.saveWorkouts)
            #expect(persistor.events.contains(.saveWorkouts))
        }
    }
}

// MARK: Sets CRUD

extension WorkoutStoreTests {
    @Suite("Sets CRUD")
    struct SetsCRUD {
        let persistor: SpyWorkoutStorePersistor
        let store: WorkoutStore
        let sampleWorkout: Workout
        let sampleSegment: Segment
        let originalWorkouts: [Workout]

        init() async throws {
            persistor = SpyWorkoutStorePersistor()
            store = WorkoutStore(persistor: persistor)

            try await persistor.waitUntilStoreLoad()

            originalWorkouts = store.workouts
            sampleWorkout = store.workouts.first!
            sampleSegment = sampleWorkout.segments.first!
        }

        // MARK: Create
        
        @Test func `It should create sets`() {
            let newSet = Segment.Set.sampleBarbell

            let createdSet = store.createSet(newSet, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)

            #expect(createdSet == newSet)
            #expect(store.sets(segmentId: sampleSegment.id, workoutId: sampleWorkout.id) == sampleSegment.sets + [newSet])
        }
        
        @Test func `It should save when creating sets`() async throws {
            let newSet = Segment.Set.sampleBarbell

            store.createSet(newSet, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)

            try await persistor.waitUntilEvent(.saveWorkouts)
            #expect(persistor.events.contains(.saveWorkouts))
        }
        
        // MARK: Read
        
        @Test func `It should return sets`() {
            let sets = store.sets(segmentId: sampleSegment.id, workoutId: sampleWorkout.id)
            #expect(sets?.isEmpty == false)
        }

        @Test func `It should return a set`() {
            let setId = sampleSegment.sets.first!.id
            let set = store.set(setId: setId, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)
            #expect(set == sampleSegment.sets.first)
        }

        @Test func `It should not returns sets for non-existent workout`() {
            let sets = store.sets(segmentId: sampleSegment.id, workoutId: .new)
            #expect(sets == nil)
        }
        
        @Test func `It should not returns sets for non-existent segment`() {
            let sets = store.sets(segmentId: .new, workoutId: sampleWorkout.id)
            #expect(sets == nil)
        }
        
        // MARK: Update
        
        @Test func `It should not update non-existent sets`() {
            let newSet = Segment.Set.sampleBarbell

            let createdSet = store.updateSet(newSet, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)

            #expect(createdSet == nil)
            #expect(store.workouts == originalWorkouts)
        }
        
        @Test func `It should update existing sets`() {
            var sample: Segment.Set!

            let updatedSet = store.updateSet(
                with: sampleSegment.sets.last!.id,
                segmentId: sampleSegment.id,
                workoutId: sampleWorkout.id
            ) { set in
                set.repetitions = 5
                set.weight = Weight(distribution: .total(0), units: .kilograms)

                sample = set
            }

            #expect(updatedSet == sample)
            let expectedSets = sampleSegment.sets.map { $0.id == sample.id ? sample : $0 }
            #expect(store.sets(segmentId: sampleSegment.id, workoutId: sampleWorkout.id) == expectedSets)
        }
        
        @Test func `It should save when updating sets`() async throws {
            var set = sampleSegment.sets.last!
            set.repetitions = 5
            set.weight = Weight(distribution: .total(0), units: .kilograms)

            store.updateSet(set, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)

            try await persistor.waitUntilEvent(.saveWorkouts)
            #expect(persistor.events.contains(.saveWorkouts))
        }
        
        // MARK: Delete
        
        @Test func `It should delete sets`() {
            let set = sampleSegment.sets.last!

            store.deleteSet(set, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)

            #expect(store.sets(segmentId: sampleSegment.id, workoutId: sampleWorkout.id) == sampleSegment.sets.dropLast())
        }
        
        @Test func `It should not delete non-existent sets`() {
            let set = Segment.Set.sampleTotal

            store.deleteSet(set, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)

            #expect(store.workouts == originalWorkouts)
        }
        
        @Test func `It should save when deleting sets`() async throws {
            let set = sampleSegment.sets.last!

            store.deleteSet(set, segmentId: sampleSegment.id, workoutId: sampleWorkout.id)

            try await persistor.waitUntilEvent(.saveWorkouts)
            #expect(persistor.events.contains(.saveWorkouts))
        }
    }
}

// MARK: Exercises CRUD
 
extension WorkoutStoreTests {
    @Suite("Exercises CRUD")
    class ExercisesCRUD {
        let persistor: SpyWorkoutStorePersistor
        let store: WorkoutStore
        let sampleExercise: Exercise
        let originalExercises: [Exercise]

        init() async throws {
            persistor = SpyWorkoutStorePersistor()
            store = WorkoutStore(persistor: persistor)

            try await persistor.waitUntilStoreLoad()

            originalExercises = store.exercises
            sampleExercise = store.exercises.first!
        }

        // MARK: Create
        
        @Test func `It should create exercises`() {
            let newExercise = Exercise(name: "New")

            let createdExercise = store.createExercise(newExercise)

            #expect(createdExercise == newExercise)
            #expect(store.exercises == originalExercises + [newExercise])
        }
        
        @Test func `It should save when creating exercises`() async throws {
            let newExercise = Exercise(name: "New")

            store.createExercise(newExercise)

            try await persistor.waitUntilEvent(.saveExercises)
            #expect(persistor.events.contains(.saveExercises))
        }
        
        // MARK: Update
        
        @Test func `It should not update non-existent exercises`() {
            let newExercise = Exercise(name: "New")

            let createdExercise = store.updateExercise(newExercise)

            #expect(createdExercise == nil)
            #expect(store.exercises == originalExercises)
        }
        
        @Test func `It should update existing exercises`() {
            var sample: Exercise!

            let updatedExercise = store.updateExercise(with: sampleExercise.id) { exercise in
                exercise.name = "New"
                sample = exercise
            }

            #expect(updatedExercise == sample)
            let expectedExercises = originalExercises.map { $0.id == sampleExercise.id ? sample : $0}
            #expect(store.exercises == expectedExercises)
        }
        
        @Test func `It should save when updating exercises`() async throws {
            var sample = sampleExercise
            sample.name = "New"

            store.updateExercise(sample)

            try await persistor.waitUntilEvent(.saveExercises)
            #expect(persistor.events.contains(.saveExercises))
        }
        
        // MARK: Delete
        
        @Test func `It should delete exercises`() throws {
            let exercise = Exercise(name: "New")
            store.createExercise(exercise)

            try store.deleteExercise(exercise)

            #expect(store.exercises == originalExercises.filter({ $0.id != exercise.id }))
        }
        
        @Test func `It should not delete non-existent exercises`() throws {
            let newExercise = Exercise(name: "New")

            try store.deleteExercise(newExercise)

            #expect(store.exercises == originalExercises)
        }
        
        @Test()
        func `It should not delete exercises used by segments`() throws {
            let exerciseId = try #require(store.workouts.first?.segments.first?.exercise)
            let exercise = try #require(store.exercise(with: exerciseId))

            #expect(throws: WorkoutStoreError.self) {
                try self.store.deleteExercise(exercise)
            }
        }
        
        @Test func `It should save when deleting exercises`() async throws {
            let exercise = Exercise(name: "New")
            store.createExercise(exercise)

            try store.deleteExercise(exercise)

            try await persistor.waitUntilEvent(.saveExercises)
            #expect(persistor.events.contains(.saveExercises))
        }
    }
}
