//
//  WeightTests.swift
//  Modules
//
//  Created by Inal Gotov on 2025-11-09.
//

import Data
import Testing

@Suite("Weight")
struct WeightTests {
    @Test func `It should return correct weight for total type weights`() {
        let weight = Weight(distribution: .total(50), units: .pounds)

        #expect(weight.totalWeight == 50)
    }

    @Test func `It should return correct weight for dumbbell type weights`() {
        let weight = Weight(distribution: .dumbbell(50), units: .pounds)

        #expect(weight.totalWeight == 100)
    }

    @Test func `It should return correct weight for barbell type weights`() {
        let weight = Weight(distribution: .barbell(plates: 50, bar: 45), units: .pounds)

        #expect(weight.totalWeight == 145)
    }
}
