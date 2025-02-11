//
//  AppStateMachine.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

enum AppEvent {

    case didFinishLaunching(isTesting: Bool)
    case didBecomeActive
    case didEnterBackground
    case willResignActive
    case willEnterForeground
    case willTerminate(UIApplication.TerminationReason)

}

enum AppAction {

    case openURL(URL)
    case handleShortcutItem(UIApplicationShortcutItem)

}

@MainActor
protocol AppState {

    func apply(event: AppEvent) -> any AppState
    mutating func handle(action: AppAction)

}

@MainActor
protocol AppEventHandler {

    func handle(_ event: AppEvent)
    func handle(_ action: AppAction)

}

@MainActor
final class AppStateMachine: AppEventHandler {

    private(set) var currentState: any AppState = Initializing()

    func handle(_ event: AppEvent) {
        currentState = currentState.apply(event: event)
    }

    func handle(_ action: AppAction) {
        currentState.handle(action: action)
    }

}
