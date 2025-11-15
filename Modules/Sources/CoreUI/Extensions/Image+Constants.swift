//
//  Image+Constants.swift
//  Modules
//
//  Created by Inal Gotov on 2025-11-15.
//

import SwiftUI

extension Image {
    static var rateOfPerceivedExertion: Self {
        Self(systemName: "chart.bar.xaxis.ascending")
    }

    static var totalWeight: Self {
        Image(systemName: "scalemass.fill")
    }

    static var dumbbellWeight: Self {
        Image(systemName: "dumbbell.fill")
    }

    static var barbellWeight: Self {
        Image(systemName: "figure.strengthtraining.traditional")
    }
}
