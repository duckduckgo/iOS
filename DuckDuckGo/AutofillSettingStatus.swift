//
//  AutofillSettingStatus.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

import Foundation
import LocalAuthentication
import UIKit

struct AutofillSettingStatus {

    static var isAutofillEnabledInSettings: Bool {
        setupNotificationObserversIfNeeded()
        
        canAuthenticate = canAuthenticate ?? refreshCanAuthenticate()

        return appSettings.autofillCredentialsEnabled && (canAuthenticate ?? false)
    }

    private static let appSettings = AppDependencyProvider.shared.appSettings

    private static var observersSetUp = false

    private static var canAuthenticate: Bool? = {
        return refreshCanAuthenticate()
    }()

    private static func refreshCanAuthenticate() -> Bool {
        var result = false

        let performAuthenticationCheck = {
            var error: NSError?
            result = LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        }
        
        if Thread.isMainThread {
            performAuthenticationCheck()
        } else {
            DispatchQueue.main.sync {
                performAuthenticationCheck()
            }
        }
        
        return result
    }

    /// Clears the cached device authentication status when the app goes to the background
    /// to ensure that the next time the app is brought to the foreground, the authentication
    /// status is re-evaluated.
    private static func setupNotificationObserversIfNeeded() {
        guard !observersSetUp else { return }
        observersSetUp = true

        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
            canAuthenticate = nil
        }
    }

}
