//
//  MaliciousSiteProtectionPreferencesManager.swift
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
import Combine
import Core

protocol MaliciousSiteProtectionPreferencesStorage: AnyObject {
    var isEnabled: Bool { get set }
}

final class MaliciousSiteProtectionPreferencesUserDefaultsStore: MaliciousSiteProtectionPreferencesStorage {
    @UserDefaultsWrapper(key: .maliciousSiteProtectionEnabled, defaultValue: true)
    var isEnabled: Bool
}

protocol MaliciousSiteProtectionPreferencesPublishing {
    var isMaliciousSiteProtectionOnPublisher: AnyPublisher<Bool, Never> { get }
}

protocol MaliciousSiteProtectionPreferencesReading {
    var isMaliciousSiteProtectionOn: Bool { get }
}

typealias MaliciousSiteProtectionPreferencesProvider = MaliciousSiteProtectionPreferencesReading & MaliciousSiteProtectionPreferencesPublishing

protocol MaliciousSiteProtectionPreferencesWriting: AnyObject {
    var isMaliciousSiteProtectionOn: Bool { get set }
}

typealias MaliciousSiteProtectionPreferencesManaging = MaliciousSiteProtectionPreferencesWriting & MaliciousSiteProtectionPreferencesProvider

final class MaliciousSiteProtectionPreferencesManager: MaliciousSiteProtectionPreferencesManaging {
    @Published var isMaliciousSiteProtectionOn: Bool {
        didSet {
            store.isEnabled = isMaliciousSiteProtectionOn
        }
    }

    var isMaliciousSiteProtectionOnPublisher: AnyPublisher<Bool, Never> { $isMaliciousSiteProtectionOn.eraseToAnyPublisher() }

    private let store: MaliciousSiteProtectionPreferencesStorage

    init(store: MaliciousSiteProtectionPreferencesStorage = MaliciousSiteProtectionPreferencesUserDefaultsStore()) {
        self.store = store
        isMaliciousSiteProtectionOn = store.isEnabled
    }
}
