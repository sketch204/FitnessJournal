//
//  PreviewingStore.swift
//  Modules
//
//  Created by Inal Gotov on 2025-11-08.
//

#if DEBUG

import Core
import SwiftUI

struct PreviewingStore<Content: View>: View {
    @State private var didLoad: Bool = false

    @State var store: WorkoutStore
    let storeSetup: ((WorkoutStore) -> Void)?
    let content: (WorkoutStore) -> Content

    init(
        store: WorkoutStore = .previewFile(),
        executing storeSetup: ((WorkoutStore) -> Void)? = nil,
        @ViewBuilder content: @escaping (WorkoutStore) -> Content
    ) {
        _store = State(initialValue: store)
        self.storeSetup = storeSetup
        self.content = content
    }

    var body: some View {
        Group {
            if didLoad {
                content(store)
            } else {
                ProgressView()
            }
        }
        .task {
            while !didLoad {
                if !store.workouts.isEmpty {
                    storeSetup?(store)
                    didLoad = true
                } else {
                    try? await Task.sleep(for: .microseconds(100))
                }
            }
        }
    }
}

#endif
