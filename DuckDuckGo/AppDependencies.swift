//
//  AppDependencies.swift
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

import Subscription
import UIKit
import Core
import DDGSync
import Combine
import BrowserServicesKit

struct AppDependencies {

    let accountManager: AccountManager
    let vpnWorkaround: VPNRedditSessionWorkaround
    let vpnFeatureVisibility: DefaultNetworkProtectionVisibility

    let appSettings: AppSettings
    let privacyStore: PrivacyUserDefaults

    let uiService: UIService
    let mainViewController: MainViewController

    let voiceSearchHelper: VoiceSearchHelper
    let autoClear: AutoClear
    let autofillLoginSession: AutofillLoginSession
    let marketplaceAdPostbackManager: MarketplaceAdPostbackManaging
    let syncService: DDGSync
    let syncDataProviders: SyncDataProviders
    let isSyncInProgressCancellable: AnyCancellable
    let privacyProDataReporter: PrivacyProDataReporting
    let remoteMessagingClient: RemoteMessagingClient

    let subscriptionService: SubscriptionService

    let onboardingPixelReporter: OnboardingPixelReporter
    let widgetRefreshModel: NetworkProtectionWidgetRefreshModel
    let autofillPixelReporter: AutofillPixelReporter
    let crashReportUploaderOnboarding: CrashCollectionOnboarding

    var syncDidFinishCancellable: AnyCancellable?

}
