//
//  WorkoutStore+Preview.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-15.
//

#if DEBUG

import Data
import Foundation
import Persistance

public extension WorkoutStore {
    static func preview(
        fileUrl: URL = FileWorkoutStorePersistor.sampleFileUrl,
        executing setup: ((WorkoutStore) -> Void)? = nil
    ) -> Self {
        let output = Self(persistor: .previewFile(fileUrl))
        output.isPersistentWritesDisabled = true
        setup?(output)
        return output
    }
}

#endif
