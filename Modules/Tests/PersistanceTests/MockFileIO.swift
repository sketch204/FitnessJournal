//
//  MockFileIO.swift
//  Modules
//
//  Created by Inal Gotov on 2025-11-09.
//

import Foundation
import Persistance

enum MockFileIOError: Error {
    case waitTimeout
}

final actor MockFileIO: FileWorkoutStorePersistorFileIO, Sendable {
    enum Event {
        case fileExists
        case read
        case write
    }

    private(set) var events: [Event] = []

    var fileExistsOverride: Bool?
    var data = Data()

    init<D: Encodable>(_ data: D, fileExistsOverride: Bool? = nil) throws {
        self.data = try JSONEncoder().encode(data)
        self.fileExistsOverride = fileExistsOverride
    }

    init(data: Data = Data(), fileExistsOverride: Bool? = nil) {
        self.data = data
        self.fileExistsOverride = fileExistsOverride
    }

    func fileExists(at url: URL) -> Bool {
        defer { events.append(.fileExists) }
        return fileExistsOverride ?? !data.isEmpty
    }
    
    func read(from url: URL) throws -> Data {
        defer { events.append(.read) }
        return data
    }
    
    func write(_ data: Data, to url: URL) throws {
        events.append(.write)
    }
    
    func setEncodedData<D: Encodable>(_ encodedData: D) throws {
        self.data = try JSONEncoder().encode(encodedData)
    }

    func waitUntilEvent(_ event: Event, timeout: TimeInterval = 1.0) async throws {
        let start = Date()

        while !self.events.contains(event) {
            await Task.yield()

            if Date().timeIntervalSince(start) > timeout {
                throw MockFileIOError.waitTimeout
            }
        }
    }
}
