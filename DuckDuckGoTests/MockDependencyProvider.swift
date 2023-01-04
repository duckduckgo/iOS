//
//  MockDependencyProvider.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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
@testable import DuckDuckGo

class MockDependencyProvider: DependencyProvider {
    var appSettings: AppSettings
    var variantManager: VariantManager
    var featureFlagger: FeatureFlagger
    var featureFlaggerInternalUserDecider: FeatureFlaggerInternalUserDecider
    var remoteMessagingStore: RemoteMessagingStore
    var homePageConfiguration: HomePageConfiguration
    var storageCache: StorageCacheProvider
    var voiceSearchHelper: VoiceSearchHelperProtocol
    var downloadManager: DownloadManager
    var autofillLoginSession: AutofillLoginSession

    init() {
        let defaultProvider = AppDependencyProvider()
        appSettings = defaultProvider.appSettings
        variantManager = defaultProvider.variantManager
        featureFlagger = defaultProvider.featureFlagger
        featureFlaggerInternalUserDecider = defaultProvider.featureFlaggerInternalUserDecider
        remoteMessagingStore = defaultProvider.remoteMessagingStore
        homePageConfiguration = defaultProvider.homePageConfiguration
        storageCache = defaultProvider.storageCache
        voiceSearchHelper = defaultProvider.voiceSearchHelper
        downloadManager = defaultProvider.downloadManager
        autofillLoginSession = defaultProvider.autofillLoginSession
    }
}
