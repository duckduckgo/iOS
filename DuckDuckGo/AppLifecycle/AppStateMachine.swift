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

    case launching(UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    case activating
    case backgrounding
    case suspending

    case openURL(URL)

}

protocol AppState {

    func apply(event: AppEvent) -> any AppState

}

protocol AppEventHandler {

    func handle(_ event: AppEvent)

}

final class AppStateMachine: AppEventHandler {

    private(set) var currentState: any AppState = Init()

    func handle(_ event: AppEvent) {
        currentState = currentState.apply(event: event)
    }

}

struct AppContext {

    let application: UIApplication
    let launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    var urlToOpen: URL?

}

struct TransitionContext {

    let event: AppEvent
    let sourceState: AppState

}


