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

import Foundation
import LocalAuthentication
import os.log
import Core

final class AutofillLoginListAuthenticator {
    enum AuthError: Equatable {
        case noAuthAvailable(AutofillNoAuthAvailableView.ViewState)
        case failedToAuthenticate
    }
    
    enum AuthenticationState {
        case loggedIn, loggedOut, notAvailable
    }
    
    private var context = LAContext()
    @Published private(set) var state = AuthenticationState.loggedOut
        
    func logOut() {
        state = .loggedOut
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
        
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = reason
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
            
                DispatchQueue.main.async {
                    if success {
                        self.state = .loggedIn
                        completion?(nil)
                    } else {
                        os_log("Failed to authenticate: %s", log: generalLog, type: .debug, error?.localizedDescription ?? "nil error")
                        switch error {
                        case LAError.biometryNotAvailable?, LAError.biometryNotEnrolled?:
                            self.handleBiometryType(self.context.biometryType, completion: completion)
                        default:
                            completion?(.failedToAuthenticate)
                        }
                    }
                }
            }
        } else {
            handleBiometryType(context.biometryType, completion: completion)
        }
    }

    private func handleBiometryType(_ biometryType: LABiometryType, completion: ((AuthError?) -> Void)?) {
        state = .notAvailable

        switch context.biometryType {
        case .faceID:
            completion?(.noAuthAvailable(.faceId))
        case .touchID:
            completion?(.noAuthAvailable(.touchId))
        default:
            completion?(.noAuthAvailable(.faceId))
        }
    }
}
