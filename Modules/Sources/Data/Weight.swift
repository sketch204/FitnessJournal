//
//  Weight.swift
//  FitnessJournal
//
//  Created by Inal Gotov on 2025-08-31.
//

public struct Weight: Hashable, Codable, Sendable {
    public enum Distribution: Hashable, Codable, Sendable {
        /// Defines the total weight
        case total(Double)
        /// Defines the weight of a single dumbbell used in the exercise. Will be doubled.
        case dumbbell(Double)
        /// Defines the weight of a set of plates on one side of the bar (will be doubled), plus the weight of the bar itself.
        case barbell(plates: Double, bar: Double)
    }
    
    public enum Units: Hashable, Codable, Sendable {
        case kilograms
        case pounds
    }
    
    public var distribution: Distribution
    public var units: Units
    
    public init(distribution: Distribution, units: Units) {
        self.distribution = distribution
        self.units = units
    }
}

public extension Weight {
    var totalWeight: Double {
        switch distribution {
        case .total(let weight): weight
        case .dumbbell(let weight): weight * 2
        case .barbell(plates: let plates, bar: let bar): plates * 2 + bar
        }
    }
}
