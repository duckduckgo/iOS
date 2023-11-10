//
//  EmailManagerRequestDelegate.swift
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
import BrowserServicesKit
import Networking
import Core

// MARK: - EmailManagerRequestDelegate
extension EmailManagerRequestDelegate {

    // swiftlint:disable unused_setter_value
    public var activeTask: URLSessionTask? {
        get { return nil }
        set {}
    }
    // swiftlint:enable unused_setter_value

    // swiftlint:disable function_parameter_count
    func emailManager(_ emailManager: EmailManager, requested url: URL, method: String, headers: [String: String], parameters: [String: String]?, httpBody: Data?, timeoutInterval: TimeInterval) async throws -> Data {
        let finalURL = url.appendingParameters(parameters ?? [:])
        var request = URLRequest(url: finalURL, timeoutInterval: timeoutInterval)
        request.allHTTPHeaderFields = headers
        request.httpMethod = method
        request.httpBody = httpBody

        activeTask?.cancel() // Cancel active request (if any)

        let (data, response) = try await URLSession.shared.data(for: request)
        activeTask = URLSession.shared.dataTask(with: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 300 {
            throw EmailManagerRequestDelegateError.serverError(statusCode: httpResponse.statusCode)
        }

        return data
    }
    // swiftlint:enable function_parameter_count

    func emailManagerKeychainAccessFailed(_ emailManager: EmailManager,
                                          accessType: EmailKeychainAccessType,
                                          error: EmailKeychainAccessError) {
        var parameters = [
            PixelParameters.emailKeychainAccessType: accessType.rawValue,
            PixelParameters.emailKeychainError: error.errorDescription
        ]
        
        var errorCode: Int32?
        if case let .keychainLookupFailure(status) = error {
            errorCode = status
            parameters[PixelParameters.emailKeychainKeychainStatus] = String(status)
            parameters[PixelParameters.emailKeychainKeychainOperation] = "lookup"
        }

        if case let .keychainDeleteFailure(status) = error {
            errorCode = status
            parameters[PixelParameters.emailKeychainKeychainStatus] = String(status)
            parameters[PixelParameters.emailKeychainKeychainOperation] = "delete"
        }

        if case let .keychainSaveFailure(status) = error {
            errorCode = status
            parameters[PixelParameters.emailKeychainKeychainStatus] = String(status)
            parameters[PixelParameters.emailKeychainKeychainOperation] = "save"
        }

        // https://app.asana.com/0/414709148257752/1205196846001239/f
        if errorCode == errSecNotAvailable {
            emailManager.forceSignOut()
        }

        Pixel.fire(pixel: .emailAutofillKeychainError, withAdditionalParameters: parameters)
    }

}
