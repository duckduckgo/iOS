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

struct AppDependencies { // should we initialize some of these in place or all in Launched state? ; also struct/class?

    // embed in Subscription service
    let accountManager: AccountManager
    // embed in VPN service
    let vpnWorkaround: VPNRedditSessionWorkaround
    let vpnFeatureVisibility: DefaultNetworkProtectionVisibility

    // embed in DBService
    let appSettings: AppSettings
    let privacyStore: PrivacyUserDefaults

    // ..
    let uiService: UIService

    // ..

    let voiceSearchHelper: VoiceSearchHelper
    let autoClear: AutoClear
    let autofillLoginSession: AutofillLoginSession
    let marketplaceAdPostbackManager: MarketplaceAdPostbackManager
    let syncService: DDGSync
    let isSyncInProgressCancellable: AnyCancellable
    let privacyProDataReporter: PrivacyProDataReporting
    let remoteMessagingClient: RemoteMessagingClient

    let subscriptionService: SubscriptionService

    let onboardingPixelReporter: OnboardingPixelReporter
    // ..
    


}
