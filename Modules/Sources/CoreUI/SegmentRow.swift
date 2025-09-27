//
//  SegmentRow.swift
//  Modules
//
//  Created by Inal Gotov on 2025-08-31.
//

import Data
import SwiftUI

struct SegmentRow: View {
    let segment: Segment
    
    init(_ segment: Segment) {
        self.segment = segment
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading) {
                Text(segment.exercise.name)
                    .multilineTextAlignment(.leading)
                    .font(.title)
                
                Text("\(segment.sets.count) Sets")
                    .multilineTextAlignment(.leading)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
                
            Spacer()
            
            if let weight = segment.displayWeight {
                WeightView(weight: weight)
            }
        }
    }
}

#Preview("Default") {
    List {
        SegmentRow(.sampleBenchPress)
        SegmentRow(.sampleDeadlifts)
        SegmentRow(.sampleChestFlys)
    }
    .listStyle(.plain)
}
