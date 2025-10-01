//
//  NavigateToSegmentAction.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-25.
//

import Core
import Data
import SwiftUI

struct NavigateToSegmentAction: AppAction {
    let navigation: SegmentNavigation
    
    init(navigation: SegmentNavigation) {
        self.navigation = navigation
    }
    
    init(workoutId: Workout.ID, segmentId: Segment.ID) {
        self.init(
            navigation: SegmentNavigation(
                workoutId: workoutId,
                segmentId: segmentId
            )
        )
    }
}

extension NavigateToSegmentAction {
    fileprivate struct Handler: ViewModifier {
        @Environment(\.appActions) var appActions
        
        let store: WorkoutStore
        @Binding var path: NavigationPath
        
        func body(content: Content) -> some View {
            content
                .onReceive(appActions.events(for: NavigateToSegmentAction.self)) { action in
                    path.append(action.navigation)
                }
                .navigationDestination(for: SegmentNavigation.self) { navigation in
                    SegmentView(store: store, navigation: navigation)
                }
        }
    }
}

extension View {
    func registerSegmentNavigationHandler(store: WorkoutStore, path: Binding<NavigationPath>) -> some View {
        modifier(NavigateToSegmentAction.Handler(store: store, path: path))
    }
}
