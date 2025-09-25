//
//  AppAction.swift
//  Modules
//
//  Created by Inal Gotov on 2025-09-25.
//

import Combine
import SwiftUI

protocol AppAction {}

struct AppActions {
    private let subject = PassthroughSubject<AppAction, Never>()
    
    init() {}
    
    func events<T>(for actionType: T.Type) -> AnyPublisher<T, Never> where T: AppAction {
        subject
            .compactMap({ $0 as? T })
            .eraseToAnyPublisher()
    }
    
    func perform(_ action: some AppAction) {
        subject.send(action)
    }
}

extension EnvironmentValues {
    @Entry var appActions = AppActions()
}
