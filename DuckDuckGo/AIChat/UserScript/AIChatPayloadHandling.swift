//
//  AIChatPayloadHandling.swift
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

typealias AIChatPayload = [String: Any]

/// A protocol that defines a generic interface for handling payloads.
///
/// Types conforming to `PayloadHandler` are responsible for managing a payload
/// of a specific type, including setting, consuming, and resetting the payload.
protocol AIChatPayloadHandling {
    /// The type of payload that the handler manages.
    associatedtype PayloadType

    /// Sets the payload to be managed by the handler.
    ///
    /// - Parameter payload: The payload to be set.
    func setPayload(_ payload: PayloadType)

    /// Consumes and returns the current payload.
    ///
    /// This method returns the current payload and resets the handler,
    /// clearing the payload after it is consumed.
    ///
    /// - Returns: The current payload, or `nil` if no payload is set.
    func consumePayload() -> PayloadType?

    /// Resets the handler, clearing the current payload.
    ///
    /// After calling this method, the handler will no longer have a payload set.
    func reset()
}

final class AIChatPayloadHandler: AIChatPayloadHandling {
    typealias PayloadType = AIChatPayload

    private var payload: AIChatPayload?

    func setPayload(_ payload: AIChatPayload) {
        self.payload = payload
    }

    func consumePayload() -> AIChatPayload? {
        defer { reset() }
        return payload
    }

    func reset() {
        self.payload = nil
    }
}
