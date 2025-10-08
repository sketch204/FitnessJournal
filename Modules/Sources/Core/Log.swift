//
//  Log.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-25.
//

import os

public enum Log {
    public nonisolated static let core = Logger(subsystem: "com.sketch204.FitnessJournal", category: "Core")
    public nonisolated static let ui = Logger(subsystem: "com.sketch204.FitnessJournal", category: "UI")
}
