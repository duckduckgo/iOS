//
//  MaliciousSiteProtectionPreferencesManager.swift
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

import Foundation
import Combine
import Core

protocol MaliciousSiteProtectionPreferencesStorage: AnyObject {
    var isEnabled: Bool { get set }
}

final class MaliciousSiteProtectionPreferencesUserDefaultsStore: MaliciousSiteProtectionPreferencesStorage {
    @UserDefaultsWrapper(key: .maliciousSiteProtectionEnabled, defaultValue: false)
    var isEnabled: Bool
}

protocol MaliciousSiteProtectionPreferencesPublishing {
    var isEnabled: Bool { get }
    var isEnabledPublisher: AnyPublisher<Bool, Never> { get }
}

protocol MaliciousSiteProtectionPreferencesManaging: AnyObject {
    var isEnabled: Bool { get set }
}

final class MaliciousSiteProtectionPreferencesManager: MaliciousSiteProtectionPreferencesManaging, MaliciousSiteProtectionPreferencesPublishing {
    @Published var isEnabled: Bool {
        didSet {
            store.isEnabled = isEnabled
        }
    }

    var isEnabledPublisher: AnyPublisher<Bool, Never> { $isEnabled.eraseToAnyPublisher() }

    private let store: MaliciousSiteProtectionPreferencesStorage

    init(store: MaliciousSiteProtectionPreferencesStorage = MaliciousSiteProtectionPreferencesUserDefaultsStore()) {
        self.store = store
        isEnabled = store.isEnabled
    }
}
