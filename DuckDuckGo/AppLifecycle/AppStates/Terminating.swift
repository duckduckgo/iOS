//
//  Terminating.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

struct Terminating: AppState {

    init(stateContext: Launching.StateContext, terminationReason: UIApplication.TerminationReason) {
        alertAndTerminate(application: stateContext.application, terminationReason: terminationReason)
    }

    init(stateContext: Foreground.StateContext, terminationReason: UIApplication.TerminationReason) {
        alertAndTerminate(application: stateContext.application, terminationReason: terminationReason)
    }

    init(stateContext: Background.StateContext, terminationReason: UIApplication.TerminationReason) {
        fatalError("App is in unrecoverable state")
    }

    private func alertAndTerminate(application: UIApplication, terminationReason: UIApplication.TerminationReason) {
        if case .insufficientDiskSpace = terminationReason {
            let alertController = CriticalAlerts.makeInsufficientDiskSpaceAlert()
            application.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        } else {
            fatalError("Unrecognized state")
        }
    }

}

extension Terminating {

    mutating func handle(action: AppAction) { }

}
