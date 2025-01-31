//
//  MaliciousSiteProtectionSettingsViewModel.swift
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
import MaliciousSiteProtection

final class MaliciousSiteProtectionSettingsViewModel: ObservableObject {
    @Published var shouldShowMaliciousSiteProtectionSection: Bool
    @Published var isMaliciousSiteProtectionOn: Bool {
        didSet {
            updateMaliciousSiteProtection(enabled: isMaliciousSiteProtectionOn)
        }
    }

    private let manager: MaliciousSiteProtectionPreferencesManaging
    private let featureFlagger: MaliciousSiteProtectionFeatureFlagger
    private let urlOpener: URLOpener

    init(
        manager: MaliciousSiteProtectionPreferencesManaging,
        featureFlagger: MaliciousSiteProtectionFeatureFlagger = MaliciousSiteProtectionFeatureFlags(featureFlagger: AppDependencyProvider.shared.featureFlagger),
        urlOpener: URLOpener = UIApplication.shared
    ) {
        self.manager = manager
        self.featureFlagger = featureFlagger
        self.urlOpener = urlOpener
        shouldShowMaliciousSiteProtectionSection = featureFlagger.isMaliciousSiteProtectionEnabled
        isMaliciousSiteProtectionOn = manager.isMaliciousSiteProtectionOn
    }

    func learnMoreAction() {
        urlOpener.open(URL.maliciousSiteProtectionLearnMore)
    }

    private func updateMaliciousSiteProtection(enabled isEnabled: Bool) {
        manager.isMaliciousSiteProtectionOn = isEnabled
        Pixel.fire(MaliciousSiteProtection.Event.settingToggled(to: isEnabled))
    }
}
