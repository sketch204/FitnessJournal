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
