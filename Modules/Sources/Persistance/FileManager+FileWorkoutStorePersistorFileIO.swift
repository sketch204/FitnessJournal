//
//  FileManager+FileWorkoutStorePersistorFileIO.swift
//  Modules
//
//  Created by Inal Gotov on 2025-11-09.
//

import Foundation

nonisolated extension FileManager: FileWorkoutStorePersistorFileIO {
    public func fileExists(at url: URL) -> Bool {
        fileExists(atPath: url.path(percentEncoded: false))
    }

    public func read(from url: URL) throws -> Data {
        try Data(contentsOf: url)
    }

    public func write(_ data: Data, to url: URL) throws {
        try data.write(to: url, options: .atomic)
    }
}
