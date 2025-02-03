//
//  AIChatDebugSettingsHandling.swift
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

import Foundation

public protocol AIChatDebugSettingsHandling {
    var messagePolicyHostname: String? { get set }
}

public struct AIChatDebugSettings: AIChatDebugSettingsHandling {
    private let userDefaultsKey = "aichat.debug.messagePolicyHostname"
    private let userDefault: UserDefaults

    public init(userDefault: UserDefaults = .standard) {
        self.userDefault = userDefault
    }

    public var messagePolicyHostname: String? {
        get {
            let value = userDefault.string(forKey: userDefaultsKey)
            return value?.isEmpty == true ? nil : value
        }
        set {
            if let newValue = newValue, !newValue.isEmpty {
                userDefault.set(newValue, forKey: userDefaultsKey)
            } else {
                userDefault.removeObject(forKey: userDefaultsKey)
            }
        }
    }
}
