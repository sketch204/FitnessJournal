//
//  WeightEditSection.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-15.
//

import Data
import SwiftUI

struct WeightEditSection: View {
    private enum Distribution: Hashable {
        case total
        case dumbbell
        case barbell
    }
    
    @Binding var weight: Weight
    
    @State private var distribution: Distribution
    @State private var mainWeight: Double
    @State private var barWeight: Double
    
    init(weight: Binding<Weight>) {
        _weight = weight
        
        switch weight.wrappedValue.distribution {
        case .total(let totalWeight):
            _distribution = State(initialValue: .total)
            _mainWeight = State(initialValue: totalWeight)
            _barWeight = State(initialValue: 45)
        case .dumbbell(let totalWeight):
            _distribution = State(initialValue: .dumbbell)
            _mainWeight = State(initialValue: totalWeight)
            _barWeight = State(initialValue: 45)
        case .barbell(let plates, let bar):
            _distribution = State(initialValue: .barbell)
            _mainWeight = State(initialValue: plates)
            _barWeight = State(initialValue: bar)
        }
    }
    
    var body: some View {
        Section("Weight") {
            Picker("Distribution", selection: $distribution) {
                Text("Total")
                    .tag(Distribution.total)
                Text("Dumbbells")
                    .tag(Distribution.dumbbell)
                Text("Barbell")
                    .tag(Distribution.barbell)
            }
            .pickerStyle(.segmented)
            
            LabeledContent("Weight") {
                TextField("Weight", value: $mainWeight, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
            
            if distribution == .barbell {
                LabeledContent("Bar Weight") {
                    TextField("Bar Weight", value: $barWeight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            Picker("Units", selection: $weight.units) {
                Text("kg")
                    .tag(Weight.Units.kilograms)
                Text("lb")
                    .tag(Weight.Units.pounds)
            }
            .pickerStyle(.menu)
        }
        .onChange(of: mainWeight) {
            switch weight.distribution {
            case .total:
                weight.distribution = .total(mainWeight)
            case .dumbbell:
                weight.distribution = .dumbbell(mainWeight)
            case .barbell(_, let bar):
                weight.distribution = .barbell(plates: mainWeight, bar: bar)
            }
        }
        .onChange(of: barWeight) {
            switch weight.distribution {
            case .total, .dumbbell:
                break
            case .barbell(let platesWeight, _):
                weight.distribution = .barbell(plates: platesWeight, bar: barWeight)
            }
        }
        .onChange(of: distribution) {
            switch distribution {
            case .total:
                weight.distribution = .total(mainWeight)
            case .dumbbell:
                weight.distribution = .dumbbell(mainWeight)
            case .barbell:
                weight.distribution = .barbell(plates: mainWeight, bar: barWeight)
            }
        }
    }
}

#Preview {
    @Previewable @State var weight = Weight(
        distribution: .dumbbell(50),
        units: .pounds
    )
    
    Form {
        WeightEditSection(weight: $weight)
    }
    .overlay(alignment: .bottom) {
        WeightView(weight: weight)
    }
}
