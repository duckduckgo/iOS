//
//  ConfigurationService.swift
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
import Core
import Configuration

final class ConfigurationService {

    @UserDefaultsWrapper(key: .privacyConfigCustomURL, defaultValue: nil)
    private var privacyConfigCustomURL: String?
    private let isDebugBuild: Bool

    var onConfigurationFetch: (() -> Void)?

    init(isDebugBuild: Bool) {
        self.isDebugBuild = isDebugBuild
    }

    func onLaunching() {
        if isDebugBuild, let privacyConfigCustomURL, let url = URL(string: privacyConfigCustomURL) {
            Configuration.setURLProvider(CustomConfigurationURLProvider(customPrivacyConfigurationURL: url))
        } else {
            Configuration.setURLProvider(AppConfigurationURLProvider())
        }

        // Task handler registration needs to happen before the end of `didFinishLaunching`, otherwise submitting a task can throw an exception.
        // Having both in `didBecomeActive` can sometimes cause the exception when running on a physical device, so registration happens here.
        AppConfigurationFetch.registerBackgroundRefreshTaskHandler()
    }

    func onForeground() {
        if AppConfigurationFetch.shouldScheduleRulesCompilationOnAppLaunch {
            ContentBlocking.shared.contentBlockingManager.scheduleCompilation() // TODO: should compilation happen in line here
            // or should other service be responsible for it?
            AppConfigurationFetch.shouldScheduleRulesCompilationOnAppLaunch = false
        }
        AppDependencyProvider.shared.configurationManager.loadPrivacyConfigFromDiskIfNeeded()

        AppConfigurationFetch().start { result in
            self.onConfigurationFetch?()
            if case .assetsUpdated(let protectionsUpdated) = result, protectionsUpdated {
                ContentBlocking.shared.contentBlockingManager.scheduleCompilation()
            }
        }
    }



}
