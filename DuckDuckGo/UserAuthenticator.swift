//
//  UserAuthenticator.swift
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

import Common
import Foundation
import LocalAuthentication
import Core
import os.log

class UserAuthenticator {
    enum AuthError: Error, Equatable {
        case noAuthAvailable
        case failedToAuthenticate
    }

    enum AuthenticationState {
        case loggedIn, loggedOut, notAvailable
    }

    public struct Notifications {
        public static let invalidateContext = Notification.Name("com.duckduckgo.app.UserAuthenticator.invalidateContext")
    }

    private var context = LAContext()
    private var reason: String
    @Published private(set) var state = AuthenticationState.loggedOut

    init(reason: String) {
        self.reason = reason
    }

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
        context.localizedReason = reason

        if canAuthenticate() {
            let reason = reason
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { [weak self] success, error in

                DispatchQueue.main.async {
                    if success {
                        self?.state = .loggedIn
                        completion?(nil)
                    } else {
                        Logger.general.error("Failed to authenticate: \(error?.localizedDescription ?? "nil", privacy: .public)")
                        completion?(.failedToAuthenticate)
                    }
                }
            }
        } else {
            state = .notAvailable
            completion?(.noAuthAvailable)
        }
    }

    func invalidateContext() {
        context.invalidate()
    }

}
