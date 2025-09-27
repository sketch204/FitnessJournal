import Core
import Data
import SwiftUI

public struct WorkoutsListView: View {
    @Environment(\.appActions) private var appActions
    
    let store: WorkoutStore
    
    var workouts: [Workout] {
        store.workouts
            .sorted(using: KeyPathComparator(\.date, order: .reverse))
    }
    
    init(store: WorkoutStore) {
        self.store = store
    }
    
    public var body: some View {
        List {
            ForEach(workouts) { workout in
                NavigationLink(value: workout.id) {
                    WorkoutRow(workout: workout)
                }
            }
            .onDelete { indexSet in
                indexSet.map({ store.workouts[$0] })
                    .forEach { workout in
                        store.deleteWorkout(workout)
                    }
            }
        }
        .animation(.default, value: store.workouts.count)
        .overlay(alignment: .bottom, content: {
            Button(action: addNewWorkout) {
                Label("Add Workout", systemImage: "plus")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .padding()
            .buttonStyle(.borderedProminent)
        })
        .listStyle(.plain)
        .navigationTitle("Workouts")
    }
    
    private func addNewWorkout() {
        let workout = store.createWorkout()
        appActions.perform(NavigateToWorkoutAction(workoutId: workout.id))
    }
}

#Preview {
    NavigationStack {
        WorkoutsListView(store: .preview())
    }
}
