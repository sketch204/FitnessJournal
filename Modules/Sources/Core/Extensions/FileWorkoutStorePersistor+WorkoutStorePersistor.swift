//
//  FileWorkoutStorePersistor+WorkoutStorePersistor.swift
//  Modules
//
//  Created by Inal Gotov on 2025-11-08.
//

import Foundation
import Persistance

extension FileWorkoutStorePersistor: WorkoutStorePersistor {}

extension WorkoutStorePersistor where Self == FileWorkoutStorePersistor {
    public static var file: Self {
        .file()
    }

    public static func file(_ fileUrl: URL = FileWorkoutStorePersistor.defaultFileUrl) -> Self {
        Self(fileUrl: fileUrl)
    }

    #if DEBUG

    public static func previewFile(_ fileUrl: URL = FileWorkoutStorePersistor.sampleFileUrl) -> Self {
        Self(fileUrl: fileUrl)
    }

    #endif
}
