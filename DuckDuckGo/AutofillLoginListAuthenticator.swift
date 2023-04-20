//
//  AutofillLoginListAuthenticator.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

import Common
import Foundation
import LocalAuthentication
import Core

final class AutofillLoginListAuthenticator {
    enum AuthError: Equatable {
        case noAuthAvailable
        case failedToAuthenticate
    }
    
    enum AuthenticationState {
        case loggedIn, loggedOut, notAvailable
    }

    public struct Notifications {
        public static let invalidateContext = Notification.Name("com.duckduckgo.app.AutofillLoginListAuthenticator.invalidateContext")
    }
    
    private var context = LAContext()
    @Published private(set) var state = AuthenticationState.loggedOut
        
    func logOut() {
        state = .loggedOut
    }

    func canAuthenticate() -> Bool {
        var error: NSError?
        let canAuthenticate = LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        return canAuthenticate
    }

    func authenticate(completion: ((AuthError?) -> Void)? = nil) {
       
        if state == .loggedIn {
            completion?(nil)
            return
        }

        context = LAContext()
        context.localizedCancelTitle = UserText.autofillLoginListAuthenticationCancelButton
        let reason = UserText.autofillLoginListAuthenticationReason
        context.localizedReason = reason
        
        if canAuthenticate() {
            let reason = reason
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
            
                DispatchQueue.main.async {
                    if success {
                        self.state = .loggedIn
                        completion?(nil)
                    } else {
                        os_log("Failed to authenticate: %s", log: .generalLog, type: .debug, error?.localizedDescription ?? "nil error")
                        AppDependencyProvider.shared.autofillLoginSession.endSession()
                        completion?(.failedToAuthenticate)
                    }
                }
            }
        } else {
            state = .notAvailable
            AppDependencyProvider.shared.autofillLoginSession.endSession()
            completion?(.noAuthAvailable)
        }
    }

    func invalidateContext() {
        context.invalidate()
    }
}
