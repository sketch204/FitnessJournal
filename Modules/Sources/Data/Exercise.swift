//
//  Exercise.swift
//  FitnessJournal
//
//  Created by Inal Gotov on 2025-08-31.
//

import Foundation

public struct Exercise: Hashable, Sendable, Identifiable {
    public let id: Identifier<Self, UUID>
    public var name: String
    
    public init(id: Identifier<Self, UUID> = .new, name: String) {
        self.id = id
        self.name = name
    }
}

#if DEBUG
public extension Exercise {
    static var sample: Exercise { .sampleBenchPress }
    
    static var sampleBicepCurl: Exercise {
        .init(name: "Bicep Curl")
    }
    
    static var sampleBenchPress: Exercise {
        .init(name: "Bench Press")
    }
    
    static var sampleDeadlifts: Exercise {
        .init(name: "Deadlifts")
    }
    
    static var sampleLegExtensions: Exercise {
        .init(name: "Leg Extensions")
    }
    
    static var sampleChestFlys: Exercise {
        .init(name: "Chest Flys")
    }
}
#endif
