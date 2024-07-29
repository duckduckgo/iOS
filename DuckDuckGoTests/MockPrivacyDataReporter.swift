//
//  MockPrivacyDataReporter.swift
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
import DDGSync
@testable import DuckDuckGo

final class MockPrivacyProDataReporter: PrivacyProDataReporting {

    func isReinstall() -> Bool {
        false
    }

    func isFireButtonUser() -> Bool {
        false
    }

    func isSyncUsed() -> Bool {
        false
    }

    func isFireproofingUsed() -> Bool {
        false
    }

    func isAppOnboardingCompleted() -> Bool {
        false
    }

    func isEmailEnabled() -> Bool {
        false
    }

    func isWidgetAdded() -> Bool {
        false
    }

    func isFrequentUser() -> Bool {
        false
    }

    func isLongTermUser() -> Bool {
        false
    }

    func isAutofillUser() -> Bool {
        false
    }

    func isValidOpenTabsCount() -> Bool {
        false
    }

    func isSearchUser() -> Bool {
        false
    }

    func injectSyncService(_ service: DDGSync) {}

    func injectTabsModel(_ model: DuckDuckGo.TabsModel) {}

    func saveFireCount() {}

    func saveWidgetAdded() async {}

    func saveApplicationLastSessionEnded() {}

    func saveSearchCount() {}

    func randomizedParameters(for useCase: DuckDuckGo.PrivacyProDataReportingUseCase) -> [String: String] {
        [:]
    }

    func mergeRandomizedParameters(for useCase: DuckDuckGo.PrivacyProDataReportingUseCase, with parameters: [String: String]) -> [String: String] {
        [:]
    }
}
