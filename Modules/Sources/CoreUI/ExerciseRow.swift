//
//  ExerciseRow.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-27.
//

import Data
import SwiftUI

struct ExerciseRow: View {
    let exercise: Exercise
    
    init(_ exercise: Exercise) {
        self.exercise = exercise
    }
    
    var body: some View {
        Text(exercise.name)
            .font(.title2)
    }
}
