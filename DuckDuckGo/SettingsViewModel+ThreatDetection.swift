//
//  SettingsViewModel+ThreatDetection.swift
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
import SwiftUI

final class ThreatDetectionSettingsViewModel: ObservableObject {
    @Published var shouldShowMaliciousSiteProtectionSection: Bool = false

    var threatDetectionBinding: Binding<Bool> {
        Binding<Bool>(
            get: {
                self.manager.isEnabled
            },
            set: {
                self.manager.isEnabled = $0
            }
        )
    }

    private let manager: ThreatDetetctionPreferencesManaging
    private let featureChecker: ThreatDetectionSettingsChecking

    init(
        manager: ThreatDetetctionPreferencesManaging = ThreatDetectionPreferencesManager(),
        featureChecker: ThreatDetectionSettingsChecking = ThreatDetectionFeatureCheck()
    ) {
        self.manager = manager
        self.featureChecker = featureChecker
        shouldShowMaliciousSiteProtectionSection = featureChecker.isThreatDetectionSettingsEnabled
    }
}

protocol ThreatDetectionPreferencesStorage: AnyObject {
    var isEnabled: Bool { get set }
}

final class ThreatDetectionPreferencesUserDefaultsStore: ThreatDetectionPreferencesStorage {
    @UserDefaultsWrapper(key: .threatDetectionEnabled, defaultValue: false)
    var isEnabled: Bool
}

protocol ThreatDetetctionPreferencesManaging: AnyObject {
    var isEnabled: Bool { get set }
}

final class ThreatDetectionPreferencesManager: ThreatDetetctionPreferencesManaging {

    @Published var isEnabled: Bool {
        didSet {
            store.isEnabled = isEnabled
            print("~~~IS ENABLED: ", isEnabled)
        }
    }

    private let store: ThreatDetectionPreferencesStorage

    init(store: ThreatDetectionPreferencesStorage = ThreatDetectionPreferencesUserDefaultsStore()) {
        self.store = store
        self.isEnabled = store.isEnabled
    }
}
