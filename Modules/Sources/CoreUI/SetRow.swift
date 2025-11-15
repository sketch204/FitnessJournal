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
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(set.repetitions) Reps")
                    .multilineTextAlignment(.leading)

                rpeView
            }

            Spacer()

            WeightView(weight: set.weight)
        }
    }

    @ViewBuilder
    var rpeView: some View {
        HStack(alignment: .lastTextBaseline, spacing: 4) {
            Image.rateOfPerceivedExertion
                .foregroundStyle(set.rateOfPerceivedExertionColor)
                .imageScale(.large)

            Text(set.rateOfPerceivedExertion.map(String.init) ?? "-")
        }
        .opacity(set.rateOfPerceivedExertion == nil ? 0.5 : 1)
        .font(.callout)
    }
}

#if DEBUG

#Preview {
    PreviewingStore { store in
        let workout = store.workouts.first!
        let segment = workout.segments.first!
        let sets = segment.sets.map { set in
            var set = set
            set.rateOfPerceivedExertion = Bool.random() ? Int.random(in: 0...10) : nil
            return set
        }

        List(sets) { set in
            SetRow(
                set: set
            )
        }
    }
}

#endif
