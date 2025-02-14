//
//  AppConfiguration.swift
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

import BrowserServicesKit
import WidgetKit
import Core
import Networking
import Configuration

protocol AppConfigurationDelegate {

    func appConfigurationDidAssignVariant()

}

struct AppConfiguration {

    @UserDefaultsWrapper(key: .privacyConfigCustomURL, defaultValue: nil)
    private var privacyConfigCustomURL: String?

    private let featureFlagger = AppDependencyProvider.shared.featureFlagger

    let persistentStoresConfiguration = PersistentStoresConfiguration()
    let onboardingConfiguration = OnboardingConfiguration()
    let atbAndVariantConfiguration = ATBAndVariantConfiguration()

    func start() {
        KeyboardConfiguration.disableHardwareKeyboardForUITests()
        PixelConfiguration.configure(with: featureFlagger)
        ContentBlockingConfiguration.prepareContentBlocking()
        NewTabPageIntroMessageConfiguration().disableIntroMessageForReturningUsers()

        configureAPIRequestUserAgent()
        onboardingConfiguration.migrateToNewOnboarding()
        persistentStoresConfiguration.configure()
        setConfigurationURLProvider()

        WidgetCenter.shared.reloadAllTimelines()
        PrivacyFeatures.httpsUpgrade.loadDataAsync()
    }

    private func configureAPIRequestUserAgent() {
        APIRequest.Headers.setUserAgent(DefaultUserAgentManager.duckDuckGoUserAgent)
    }

    private func setConfigurationURLProvider() {
        if isDebugBuild, let privacyConfigCustomURL, let url = URL(string: privacyConfigCustomURL) {
            Configuration.setURLProvider(CustomConfigurationURLProvider(customPrivacyConfigurationURL: url))
        } else {
            Configuration.setURLProvider(AppConfigurationURLProvider())
        }
    }

    func finalize(with reportingService: ReportingService) {
        atbAndVariantConfiguration.cleanUpATBAndAssignVariant {
            onVariantAssigned(reportingService: reportingService)
        }
        CrashHandlersConfiguration.handleCrashDuringCrashHandlersSetup()
        configureUserBrowsingUserAgent() // Called at launch end to avoid IPC race when spawning WebView for content blocking.
    }

    private func configureUserBrowsingUserAgent() {
        _ = DefaultUserAgentManager.shared
    }

    // MARK: - Handle ATB and variant assigned logic here

    private func onVariantAssigned(reportingService: ReportingService) {
        onboardingConfiguration.adjustDialogsForUITesting()
        hideHistoryMessageForNewUsers()
        reportingService.setupStorageForMarketPlacePostback()
    }

    private func hideHistoryMessageForNewUsers() {
        HistoryMessageManager().dismiss()
    }


}
