//
//  WeightEditSection.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-15.
//

import Data
import SwiftUI

struct WeightEditSection: View {
    private enum Field {
        case mainWeight
        case barWeight
    }
    
    private enum Distribution: Hashable {
        case total
        case dumbbell
        case barbell
    }
    
    @Binding var weight: Weight
    
    @State private var distribution: Distribution
    
    @FocusState private var focusedField: Field?
    @State private var mainWeight: Double?
    @State private var previousMainWeight: Double
    
    @State private var barWeight: Double?
    @State private var previousBarWeight: Double
    
    init(weight: Binding<Weight>) {
        _weight = weight
        
        switch weight.wrappedValue.distribution {
        case .total(let totalWeight):
            _distribution = State(initialValue: .total)
            _mainWeight = State(initialValue: totalWeight)
            _previousMainWeight = State(initialValue: totalWeight)
            _barWeight = State(initialValue: 45)
            _previousBarWeight = State(initialValue: 45)
        case .dumbbell(let totalWeight):
            _distribution = State(initialValue: .dumbbell)
            _mainWeight = State(initialValue: totalWeight)
            _previousMainWeight = State(initialValue: totalWeight)
            _barWeight = State(initialValue: 45)
            _previousBarWeight = State(initialValue: 45)
        case .barbell(let plates, let bar):
            _distribution = State(initialValue: .barbell)
            _mainWeight = State(initialValue: plates)
            _previousMainWeight = State(initialValue: plates)
            _barWeight = State(initialValue: bar)
            _previousBarWeight = State(initialValue: bar)
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
                TextField(
                    "Weight",
                    value: $mainWeight,
                    format: .number,
                    prompt: Text(previousMainWeight, format: .number)
                )
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .focused($focusedField, equals: .mainWeight)
                .onSubmit {
                    if distribution == .barbell {
                        focusedField = .barWeight
                    } else {
                        focusedField = nil
                    }
                }
            }
            
            if distribution == .barbell {
                LabeledContent("Bar Weight") {
                    TextField(
                        "Bar Weight",
                        value: $barWeight,
                        format: .number,
                        prompt: Text(previousBarWeight, format: .number)
                    )
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .focused($focusedField, equals: .barWeight)
                    .onSubmit {
                        focusedField = nil
                    }
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
        .onChange(of: focusedField) { oldValue, newValue in
            switch oldValue {
            case .mainWeight where mainWeight == nil:
                mainWeight = previousMainWeight
            case .barWeight where barWeight == nil:
                barWeight = previousBarWeight
            case .none:
                if let mainWeight {
                    previousMainWeight = mainWeight
                }
                if let barWeight {
                    previousBarWeight = barWeight
                }
            default:
                break
            }
            
            switch newValue {
            case .mainWeight:
                mainWeight = nil
            case .barWeight:
                barWeight = nil
            case nil:
                break
            }
        }
        .onChange(of: mainWeight) {
            guard let mainWeight else { return }
            
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
            guard let barWeight else { return }
            
            switch weight.distribution {
            case .total, .dumbbell:
                break
            case .barbell(let platesWeight, _):
                weight.distribution = .barbell(plates: platesWeight, bar: barWeight)
            }
        }
        .onChange(of: distribution) {
            guard let mainWeight, let barWeight else { return }
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
        distribution: .barbell(plates: 45, bar: 50),
        units: .pounds
    )
    
    Form {
        WeightEditSection(weight: $weight)
    }
    .overlay(alignment: .bottom) {
        WeightView(weight: weight)
    }
}
