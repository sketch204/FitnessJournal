//
//  WeightView.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-15.
//

import Data
import SwiftUI

struct WeightView: View {
    @AppStorage("prefersTotalWeightDisplay")
    private var isShowingTotalWeight: Bool = false
    
    let weight: Weight
    
    private var weightUnitLabel: String {
        switch weight.units {
        case .kilograms: "kg"
        case .pounds: "lb"
        }
    }
    
    var body: some View {
        HStack {
            Text(isShowingTotalWeight ? totalWeightLabel : detailedWeightLabel)
            
            Button {
                isShowingTotalWeight.toggle()
            } label: {
                icon.foregroundStyle(Color.accentColor)
                    .imageScale(.large)
            }
        }
    }
    
    private var totalWeightLabel: String {
        "\(weight.totalWeight) \(weightUnitLabel)"
    }
    
    private var detailedWeightLabel: String {
        switch weight.distribution {
        case .total(let totalWeight):
            "\(totalWeight) \(weightUnitLabel)"
        case .dumbbell(let totalWeight):
            "\(totalWeight) \(weightUnitLabel) x 2"
        case .barbell(plates: let platesWeight, bar: let barWeight):
            "\(platesWeight) \(weightUnitLabel) x 2 + \(barWeight) \(weightUnitLabel)"
        }
    }
    
    private var icon: Image {
        switch weight.distribution {
        case .total: .totalWeight
        case .dumbbell: .dumbbellWeight
        case .barbell: .barbellWeight
        }
    }
}

#Preview {
    WeightView(
        weight: Weight(
            distribution: .total(145),
            units: .pounds
        )
    )
    
    WeightView(
        weight: Weight(
            distribution: .dumbbell(50),
            units: .pounds
        )
    )
    
    WeightView(
        weight: Weight(
            distribution: .barbell(plates: 55, bar: 45),
            units: .pounds
        )
    )
    
    WeightView(
        weight: Weight(
            distribution: .total(145),
            units: .kilograms
        )
    )
    
    WeightView(
        weight: Weight(
            distribution: .total(145),
            units: .kilograms
        )
    )
    .foregroundStyle(.secondary)
    
    WeightView(
        weight: Weight(
            distribution: .total(145),
            units: .kilograms
        )
    )
    .foregroundStyle(.tertiary)
}
