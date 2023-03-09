//
//  Authenticator.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
import Core

public class Authenticator {

    private let policy = LAPolicy.deviceOwnerAuthentication

    public func canAuthenticate() -> Bool {
        let context = LAContext()
        var error: NSError?
        let canAuthenticate = context.canEvaluatePolicy(policy, error: &error)
        return canAuthenticate
    }

    @available(*, deprecated, message: "Use async/await")
    public func authenticate(reply: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        let reason = UserText.appUnlock
        context.evaluatePolicy(policy, localizedReason: reason) { (success, error) in
            DispatchQueue.main.async {
                reply(success, error)
            }
        }
    }

    public func authenticate(reason: String) async -> Bool {
        let context = LAContext()
        do {
            return try await context.evaluatePolicy(policy, localizedReason: reason)
        } catch {
            Pixel.fire(pixel: .dbLocalAuthenticationError, error: error)
        }
        return false
    }

}
