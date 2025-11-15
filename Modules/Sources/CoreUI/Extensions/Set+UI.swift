//
//  Set+UI.swift
//  Modules
//
//  Created by Inal Gotov on 2025-11-15.
//

import Data
import SwiftUI

extension Segment.Set {
    var rateOfPerceivedExertionColor: Color {
        Self.color(forRpe: rateOfPerceivedExertion)
    }

    static func color(forRpe rpe: Int?) -> Color {
        guard let rpe else { return Color.gray }

        switch rpe {
        case 0...1:
            return .green
        case 2...3:
            return .teal
        case 4...5:
            return .blue
        case 6...7:
            return .yellow
        case 8...9:
            return .orange
        case 10:
            return .red
        default:
            return .gray
        }
    }
}
