//
//  ExerciseLookupView.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-27.
//

import Core
import Data
import SwiftUI

struct ExerciseLookupView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let store: WorkoutStore
    private let onSelect: (Exercise) -> Void
    
    @State private var searchString: String = ""
    
    private var filteredExercises: [Exercise] {
        guard !searchString.isEmpty else {
            return store.exercises
        }
        let tokens = searchString.split(separator: " ")
            .map { $0.lowercased() }
        
        return store.exercises
            .filter { exercise in
                tokens.contains(where: {
                    exercise.name.lowercased().contains($0)
                })
            }
            .sorted(using: KeyPathComparator(\.name))
    }
    
    init(store: WorkoutStore, onSelect: @escaping (Exercise) -> Void) {
        self.store = store
        self.onSelect = onSelect
    }
    
    var body: some View {
        List {
            if !searchString.isEmpty {
                Button("Create new \"\(searchString)\" exercise") {
                    createExercise(searchString)
                }
                .buttonStyle(.borderless)
            }
            
            ForEach(filteredExercises) { exercise in
                Button {
                    selectExercise(exercise)
                } label: {
                    ExerciseRow(exercise)
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchString, prompt: "Find or create new exercise")
        .animation(.default, value: filteredExercises)
        .navigationTitle("Select Exercise")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
        }
    }
    
    private func createExercise(_ searchString: String) {
        let name = searchString.trimmingCharacters(in: .whitespacesAndNewlines)
        let exercise = Exercise(name: name)
        store.createExercise(exercise)
        
        selectExercise(exercise)
    }
    
    private func selectExercise(_ exercise: Exercise) {
        dismiss()
        onSelect(exercise)
    }
}

#Preview {
    let store = WorkoutStore.preview()
    
    NavigationStack {
        ExerciseLookupView(store: store) { exercise in
            print("Did select \(exercise)")
        }
    }
}
