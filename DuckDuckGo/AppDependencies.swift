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

    let window: UIWindow
    let mainCoordinator: MainCoordinator
    let overlayWindowManager: OverlayWindowManager // TODO: perhaps we don't need to pass it here

    let vpnService: VPNService
    let authenticationService: AuthenticationService
    let screenshotService: ScreenshotService
    let autoClearService: AutoClearService
    let syncService: SyncService
    let remoteMessagingService: RemoteMessagingService
    let subscriptionService: SubscriptionService
    let autofillService: AutofillService
    let crashService: CrashService
    let keyboardService: KeyboardService
    let configurationService: ConfigurationService

    // TODO: should we have a reporting service?
    let marketplaceAdPostbackManager: MarketplaceAdPostbackManaging
    let privacyProDataReporter: PrivacyProDataReporting
    let onboardingPixelReporter: OnboardingPixelReporter

    var cancellables = Set<AnyCancellable>()

}
