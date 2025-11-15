//
//  SegmentTests.swift
//  Modules
//
//  Created by Inal Gotov on 2025-11-09.
//

import Data
import Testing

@Suite("Segment")
struct SegmentTests {
    @Test func `It should return common display weight when there is a common weight`() {
        let segment = Segment(exercise: .new, sets: [
            .init(weight: Weight(distribution: .total(50), units: .pounds), repetitions: 10),
            .init(weight: Weight(distribution: .total(50), units: .pounds), repetitions: 10),
            .init(weight: Weight(distribution: .total(50), units: .pounds), repetitions: 10),
        ])

        #expect(segment.displayWeight == Weight(distribution: .total(50), units: .pounds))
    }

    @Test func `It should return max display weight when there is no common weight`() {
        let segment = Segment(exercise: .new, sets: [
            .init(weight: Weight(distribution: .total(45), units: .pounds), repetitions: 10),
            .init(weight: Weight(distribution: .total(50), units: .pounds), repetitions: 10),
            .init(weight: Weight(distribution: .total(55), units: .pounds), repetitions: 10),
        ])

        #expect(segment.displayWeight == Weight(distribution: .total(55), units: .pounds))
    }

    @Test func `It should return common displayRepetitions when there is a common repetition`() {
        let segment = Segment(exercise: .new, sets: [
            .init(weight: Weight(distribution: .total(50), units: .pounds), repetitions: 10),
            .init(weight: Weight(distribution: .total(50), units: .pounds), repetitions: 10),
            .init(weight: Weight(distribution: .total(55), units: .pounds), repetitions: 10),
        ])

        #expect(segment.displayRepetitionsString == "10")
    }

    @Test func `It should return breakdown of repetitions for displayRepetitions when there is no common repetition`() {
        let segment = Segment(exercise: .new, sets: [
            .init(weight: Weight(distribution: .total(45), units: .pounds), repetitions: 8),
            .init(weight: Weight(distribution: .total(50), units: .pounds), repetitions: 10),
            .init(weight: Weight(distribution: .total(55), units: .pounds), repetitions: 12),
        ])

        #expect(segment.displayRepetitionsString == "8/10/12")
    }

    @Test func `It should return correct composition string`() {
        let segment = Segment(exercise: .new, sets: [
            .init(weight: Weight(distribution: .total(45), units: .pounds), repetitions: 10),
            .init(weight: Weight(distribution: .total(50), units: .pounds), repetitions: 10),
            .init(weight: Weight(distribution: .total(55), units: .pounds), repetitions: 10),
        ])

        #expect(segment.compositionString == "3x10")
    }
}
