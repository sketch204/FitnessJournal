//
//  SetRow.swift
//  Modules
//
//  Created by Inal Gotov on 2025-08-31.
//

import Core
import Data
import SwiftUI

struct SetRow: View {
    let set: Segment.Set
    
    var body: some View {
        HStack {
            Text("\(set.repetitions) Reps")
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            WeightView(weight: set.weight)
        }
    }
}

#Preview {
    let workout = Workout.sample
    let segment = workout.segments.first!
    
    List(segment.sets) { set in
        SetRow(
            set: set
        )
    }
}
