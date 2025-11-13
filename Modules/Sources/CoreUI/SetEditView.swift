//
//  SetEditView.swift
//  Modules
//
//  Created by Inal Gotov on 2025-08-31.
//

import Core
import Data
import SwiftUI

struct SetEditView: View {
    let store: WorkoutStore
    let navigation: SetNavigation

    @State private var repetitions: Int
    @State private var weight: Weight
    @State private var rateOfPerceivedExertion: Int

    init(store: WorkoutStore, navigation: SetNavigation) {
        self.store = store
        self.navigation = navigation
        
        let set = store.set(for: navigation)
        _repetitions = State(initialValue: set?.repetitions ?? 0)
        _weight = State(initialValue: set?.weight ?? .init(distribution: .total(0), units: .pounds))
        _rateOfPerceivedExertion = State(initialValue: set?.rateOfPerceivedExertion ?? -1)
    }
    
    var body: some View {
        Form {
            Stepper("\(repetitions) Repetitions", value: $repetitions, in: 1...100)
            
            WeightEditSection(weight: $weight)

            RPEEditSection($rateOfPerceivedExertion)
        }
        .onChange(of: weight, updateSet)
        .onChange(of: repetitions, updateSet)
        .onChange(of: rateOfPerceivedExertion, updateSet)
        .navigationTitle("Set")
    }

    private func updateSet() {
        store.updateSet(
            with: navigation.setId,
            segmentId: navigation.segmentId,
            workoutId: navigation.workoutId
        ) { set in
            set.weight = weight
            set.repetitions = repetitions
            if rateOfPerceivedExertion < 0 {
                set.rateOfPerceivedExertion = nil
            } else {
                set.rateOfPerceivedExertion = rateOfPerceivedExertion
            }
        }
    }
}

#if DEBUG

#Preview {
    PreviewingStore { store in
        let workout = store.workouts.first!
        let segment = store.segments(for: workout.id)!.first!
        let set = store.sets(segmentId: segment.id, workoutId: workout.id)!.first!

        SetEditView(
            store: store,
            navigation: SetNavigation(
                workoutId: workout.id,
                segmentId: segment.id,
                setId: set.id
            )
        )
    }
}

#endif
