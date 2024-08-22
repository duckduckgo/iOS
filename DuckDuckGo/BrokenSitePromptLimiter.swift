//
//  BrokenSitePromptLimiter.swift
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
import Core
import BrowserServicesKit

protocol BrokenSitePromptLimiterStoring {
    var lastToastShownDate: Date { get set }
    var toastDismissStreakCounter: Int { get set }
}

final class BrokenSitePromptLimiterStore: BrokenSitePromptLimiterStoring {
    @UserDefaultsWrapper(key: .lastBrokenSiteToastShownDate, defaultValue: .distantPast)
    var lastToastShownDate: Date

    @UserDefaultsWrapper(key: .toastDismissStreakCounter, defaultValue: 0)
    var toastDismissStreakCounter: Int
}

final class BrokenSitePromptLimiter {

    struct BrokenSitePromptLimiterSettings: Codable {
        let maxDismissStreak: Int
        let dismissStreakResetDays: Int
        let coolDownDays: Int
    }

    private var lastToastShownDate: Date {
        get { store.lastToastShownDate }
        set { store.lastToastShownDate = newValue }
    }

    private var toastDismissStreakCounter: Int {
        get { store.toastDismissStreakCounter }
        set { store.toastDismissStreakCounter = newValue }
    }

    private var privacyConfigManager: PrivacyConfigurationManaging
    private var store: BrokenSitePromptLimiterStoring

    init(privacyConfigManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager,
         store: BrokenSitePromptLimiterStoring = BrokenSitePromptLimiterStore()) {
        self.privacyConfigManager = privacyConfigManager
        self.store = store
    }

    private func getSettingsFromConfig() -> BrokenSitePromptLimiterSettings {
        let settings = privacyConfigManager.privacyConfig.settings(for: .brokenSitePrompt)

        // Get settings from config or fallback to standard defaults
        return BrokenSitePromptLimiterSettings(
            maxDismissStreak: settings["maxDismissStreak"] as? Int ?? 3,
            dismissStreakResetDays: settings["dismissStreakResetDays"] as? Int ?? 30,
            coolDownDays: settings["coolDownDays"] as? Int ?? 7
        )
    }

    /// If it has been `dismissStreakResetDays` or more since the last time we showed the prompt, reset the dismiss counter to 0
    private func resetDismissStreakIfNeeded(dismissStreakResetDays: Int) {
        if !lastToastShownDate.isLessThan(daysAgo: dismissStreakResetDays) {
            toastDismissStreakCounter = 0
        }
    }

    public func shouldShowToast() -> Bool {
        guard privacyConfigManager.privacyConfig.isEnabled(featureKey: .brokenSitePrompt) else { return false }

        let settings = getSettingsFromConfig()

        resetDismissStreakIfNeeded(dismissStreakResetDays: settings.dismissStreakResetDays)
        guard toastDismissStreakCounter < settings.maxDismissStreak else { return false } // Don't show the toast if the user dismissed it more than `maxDismissStreak` times in a row
        guard !lastToastShownDate.isLessThan(daysAgo: settings.coolDownDays) else { return false } // Only show the toast once per `coolDownDays` days

        return true
    }

    public func didShowToast() {
        lastToastShownDate = Date()
    }

    public func didDismissToast() {
        toastDismissStreakCounter += 1
    }

    public func didOpenReport() {
        toastDismissStreakCounter = 0
    }

}
