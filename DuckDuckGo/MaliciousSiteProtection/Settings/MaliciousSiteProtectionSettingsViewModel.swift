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

final class MaliciousSiteProtectionSettingsViewModel: ObservableObject {
    @Published var shouldShowMaliciousSiteProtectionSection = false
    @Published var isMaliciousSiteProtectionEnabled: Bool = false

    var maliciousSiteProtectionBinding: Binding<Bool> {
        Binding<Bool>(
            get: {
                self.manager.isEnabled
            },
            set: {
                self.manager.isEnabled = $0
                self.isMaliciousSiteProtectionEnabled = $0
            }
        )
    }

    private let manager: MaliciousSiteProtectionPreferencesManaging
    private let featureFlagger: MaliciousSiteProtectionFeatureFlagger
    private let urlOpener: URLOpener

    init(
        manager: MaliciousSiteProtectionPreferencesManaging = MaliciousSiteProtectionPreferencesManager(),
        featureFlagger: MaliciousSiteProtectionFeatureFlagger = MaliciousSiteProtectionFeatureFlags(),
        urlOpener: URLOpener = UIApplication.shared
    ) {
        self.manager = manager
        self.featureFlagger = featureFlagger
        self.urlOpener = urlOpener
        shouldShowMaliciousSiteProtectionSection = true //featureFlagger.isMaliciousSiteProtectionEnabled
        isMaliciousSiteProtectionEnabled = manager.isEnabled
    }

    func learnMoreAction() {
        urlOpener.open(URL.maliciousSiteProtectionLearnMore)
    }
}
