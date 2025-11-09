//
//  Log.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-25.
//

import Foundation
import os

nonisolated let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.sketch204.FitnessJournal"

public enum Log {
    public nonisolated static let core = Logger(subsystem: bundleIdentifier, category: "Core")
    public nonisolated static let ui = Logger(subsystem: bundleIdentifier, category: "UI")
}
