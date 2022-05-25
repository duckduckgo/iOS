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

final class AutofillLoginListAuthenticator {
    enum AuthError {
        case noAuthAvailable
        case failedToAuthenticate
    }
    
    enum AuthenticationState {
        case loggedIn, loggedOut
    }
    
    private var context = LAContext()
    @Published private(set) var state = AuthenticationState.loggedOut
        
    func logOut() {
        state = .loggedOut
    }
    
    func authenticate(completion: @escaping(AuthError?) -> Void) {
        context = LAContext()
        context.localizedCancelTitle = "custom cancel" // TODO strings
        context.localizedReason = "custom reason"
        context.localizedFallbackTitle = "custom fallback"
        
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Custom reason text"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
            
                DispatchQueue.main.async {
                    if success {
                        self.state = .loggedIn
                        completion(nil)
                    } else {
                        print(error?.localizedDescription ?? "Failed to authenticate but error nil")
                        completion(.failedToAuthenticate)
                    }
                }
            }
        } else {
            completion(.noAuthAvailable)
        }
    }
}
