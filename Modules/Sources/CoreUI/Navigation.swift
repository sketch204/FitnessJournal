//
//  Navigation.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-25.
//

import Core
import Data

// MARK: Set Navigation

struct SetNavigation: Hashable {
    let workoutId: Workout.ID
    let segmentId: Segment.ID
    let setId: Segment.Set.ID
}

// MARK: WorkoutStore Set Extension

extension WorkoutStore {
    func set(for navigation: SetNavigation) -> Segment.Set? {
        set(
            setId: navigation.setId,
            segmentId: navigation.segmentId,
            workoutId: navigation.workoutId,
        )
    }
    
    func segment(for navigation: SetNavigation) -> Segment? {
        segment(segmentId: navigation.segmentId, workoutId: navigation.workoutId)
    }
    
    func workout(for navigation: SetNavigation) -> Workout? {
        workout(with: navigation.workoutId)
    }
}

// MARK: Segment Navigation

struct SegmentNavigation: Hashable {
    let workoutId: Workout.ID
    let segmentId: Segment.ID
}

// MARK: WorkoutStore Exercise Extension

extension WorkoutStore {
    func segment(for navigation: SegmentNavigation) -> Segment? {
        segment(segmentId: navigation.segmentId, workoutId: navigation.workoutId)
    }
    
    func workout(for navigation: SegmentNavigation) -> Workout? {
        workout(with: navigation.workoutId)
    }
}
