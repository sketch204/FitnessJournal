//
//  SetTests.swift
//  Modules
//
//  Created by Inal Gotov on 2025-11-15.
//

import Data
import Testing

@Suite("Set")
struct SetTests {
    @Test func `It should duplicate with the same ID correctly`() {
        let set = Segment.Set(weight: Weight(distribution: .total(50), units: .pounds), repetitions: 10, rateOfPerceivedExertion: 5)
        let duplicated = set.duplicated(newId: false)
        #expect(set == duplicated)
    }

    @Test func `It should duplicate with new ID correctly`() {
        let set = Segment.Set(weight: Weight(distribution: .total(50), units: .pounds), repetitions: 10, rateOfPerceivedExertion: 5)
        let duplicated = set.duplicated(newId: true)
        #expect(set.id != duplicated.id)
        #expect(set.weight == duplicated.weight)
        #expect(set.repetitions == duplicated.repetitions)
        #expect(set.rateOfPerceivedExertion == duplicated.rateOfPerceivedExertion)
    }
}
