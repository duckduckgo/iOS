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

    init() {
        fatalError("App is in unrecoverable state")
    }

    init(terminationReason: UIApplication.TerminationReason,
         application: UIApplication = UIApplication.shared) {
        alertAndTerminate(application: application, terminationReason: terminationReason)
    }

    private func alertAndTerminate(application: UIApplication, terminationReason: UIApplication.TerminationReason) {
        let alertController: UIAlertController
        switch terminationReason {
        case .insufficientDiskSpace:
            alertController = CriticalAlerts.makeInsufficientDiskSpaceAlert()
        case .unrecoverableState:
            alertController = CriticalAlerts.makePreemptiveCrashAlert()
        }
        application.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }

}

extension Terminating {

    mutating func handle(action: AppAction) { }

}
