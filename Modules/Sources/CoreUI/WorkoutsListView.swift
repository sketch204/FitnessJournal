import Core
import Data
import SwiftUI

public struct WorkoutsListView: View {
    @Environment(\.appActions) private var appActions
    
    let store: WorkoutStore
    
    var workouts: [Workout] {
        store.workouts
            .sorted { $0.date > $1.date }
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
                indexSet.map({ workouts[$0] })
                    .forEach { workout in
                        store.deleteWorkout(workout)
                    }
            }
        }
        .background {
            if workouts.isEmpty {
                ContentUnavailableView(
                    "No Workouts Yet",
                    systemImage: "dumbbell.fill",
                    description: Text("Add your first workout by tapping the button below.")
                )
            }
        }
        .animation(.default, value: store.workouts.count)
        .safeAreaInset(edge: .bottom, content: {
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

#Preview("Default") {
    NavigationStack {
        WorkoutsListView(store: .preview())
    }
}

#Preview("No workouts") {
    NavigationStack {
        WorkoutsListView(store: .preview(workouts: []))
    }
}

#Preview("Many Workouts") {
    NavigationStack {
        WorkoutsListView(
            store: .preview(
                workouts: [
                    .init(),
                    .init(),
                    .init(),
                    .init(),
                    .init(),
                    .init(),
                    .init(),
                    .init(),
                    .init(),
                ]
            )
        )
    }
}
