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

    @State private var isRenamingExercise: Bool = false
    @State private var renamedExercise: Exercise?
    
    @State private var newExerciseName: String = ""
    
    @State private var isPresentingError: Bool = false
    @State private var exerciseDeletionError: WorkoutStoreError?
    private var errorDescription: String {
        "Could not delete exercise. \(exerciseDeletionError?.description ?? "")"
    }
    
    private var filteredExercises: [Exercise] {
        guard !searchString.isEmpty else {
            return store.exercises
                .sorted { $0.name < $1.name }
        }
        let tokens = searchString.split(separator: " ")
            .map { $0.lowercased() }
        
        return store.exercises
            .filter { exercise in
                tokens.contains(where: {
                    exercise.name.lowercased().contains($0)
                })
            }
            .sorted { $0.name < $1.name }
    }
    
    init(store: WorkoutStore, onSelect: @escaping (Exercise) -> Void) {
        self.store = store
        self.onSelect = onSelect
    }
    
    var body: some View {
        List {
            ForEach(filteredExercises) { exercise in
                Button {
                    selectExercise(exercise)
                } label: {
                    ExerciseRow(store: store, exerciseId: exercise.id)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .contextMenu {
                    renameButton(exercise)
                    Button(role: .destructive) {
                        deleteExercise(exercise)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    renameButton(exercise)
                }
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
        .safeAreaInset(edge: .bottom, content: {
            if !searchString.isEmpty {
                Button("Create new \"\(searchString)\" exercise") {
                    createExercise(searchString)
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
            }
        })
        .alert("Rename Exercise", isPresented: $isRenamingExercise, presenting: renamedExercise) { exercise in
            TextField("New name", text: $newExerciseName, prompt: Text(exercise.name))
            
            Button("Rename") {
                renameExercise(exercise.id, name: newExerciseName)
            }
            
            Button("Cancel", role: .cancel) {
                dismissExerciseRenameDialog()
            }
        }
        .alert(errorDescription, isPresented: $isPresentingError, presenting: exerciseDeletionError) { error in
            Button("OK") {
                isPresentingError = false
                exerciseDeletionError = nil
            }
        }
    }
    
    private func renameButton(_ exercise: Exercise) -> some View {
        Button {
            renamedExercise = exercise
            isRenamingExercise = true
        } label: {
            Label("Rename", systemImage: "pencil")
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
    
    private func renameExercise(_ exerciseId: Exercise.ID, name: String) {
        store.updateExercise(with: exerciseId) { exercise in
            exercise.name = name
        }
        
        dismissExerciseRenameDialog()
    }
    
    private func dismissExerciseRenameDialog() {
        isRenamingExercise = false
        renamedExercise = nil
        newExerciseName = ""
    }
    
    private func deleteExercise(_ exercise: Exercise) {
        do {
            try store.deleteExercise(exercise)
        } catch {
            isPresentingError = true
            exerciseDeletionError = error
        }
    }
}

#if DEBUG

#Preview {
    PreviewingStore { store in
        NavigationStack {
            ExerciseLookupView(store: store) { exercise in
                print("Did select \(exercise)")
            }
        }
    }
}

#endif
