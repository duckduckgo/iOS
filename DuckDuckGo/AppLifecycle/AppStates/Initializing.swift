//
//  Initializing.swift
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

/// The initial setup phase of the app, where basic services or components are initialized.
/// This state can be invoked when the system prewarms the app but does not fully launch it.
/// - Transitions:
///   - `Launching` after initialization is complete.
@MainActor
struct Initializing: AppState {

    init() {
        CrashHandlersConfiguration.setupCrashHandlers()
    }

}

extension Initializing {

    mutating func handle(action: AppAction) { }

}
