//
//  AppServicesBuilder.swift
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

struct AppServicesBuilder {

    private let appSettings = AppDependencyProvider.shared.appSettings
    private let privacyConfigurationManager = ContentBlocking.shared.privacyConfigurationManager
    private let featureFlagger = AppDependencyProvider.shared.featureFlagger
    private let overlayWindowManager: OverlayWindowManager

    private let autofillService = AutofillService()
    private let configurationService = ConfigurationService()
    private let crashCollectionService = CrashCollectionService()
    private let statisticsService = StatisticsService()
    private let screenshotService: ScreenshotService
    private let authenticationService: AuthenticationService
    
    let syncService: SyncService
    let remoteMessagingService: RemoteMessagingService
    let reportingService: ReportingService
    let subscriptionService: SubscriptionService
    let maliciousSiteProtectionService: MaliciousSiteProtectionService

    init(window: UIWindow,
         fireproofing: Fireproofing,
         overlayWindowManager: OverlayWindowManager,
         persistentStoresConfiguration: PersistentStoresConfiguration) {
        self.overlayWindowManager = overlayWindowManager
        screenshotService = ScreenshotService(window: window)
        reportingService = ReportingService(fireproofing: fireproofing)
        syncService = SyncService(bookmarksDatabase: persistentStoresConfiguration.bookmarksDatabase)
        reportingService.syncService = syncService
        autofillService.syncService = syncService
        remoteMessagingService = RemoteMessagingService(bookmarksDatabase: persistentStoresConfiguration.bookmarksDatabase,
                                                        database: persistentStoresConfiguration.database,
                                                        appSettings: appSettings,
                                                        internalUserDecider: AppDependencyProvider.shared.internalUserDecider,
                                                        configurationStore: AppDependencyProvider.shared.configurationStore,
                                                        privacyConfigurationManager: privacyConfigurationManager)
        subscriptionService = SubscriptionService(privacyConfigurationManager: privacyConfigurationManager)
        maliciousSiteProtectionService = MaliciousSiteProtectionService(featureFlagger: featureFlagger)
        authenticationService = AuthenticationService(overlayWindowManager: overlayWindowManager)
    }

    func complete(with mainCoordinator: MainCoordinator) -> AppServices {
        AppServices(
            screenshotService: screenshotService,
            authenticationService: authenticationService,
            syncService: syncService,
            vpnService: VPNService(mainCoordinator: mainCoordinator),
            autofillService: autofillService,
            remoteMessagingService: remoteMessagingService,
            configurationService: configurationService,
            autoClearService: AutoClearService(mainViewController: mainCoordinator.controller, overlayWindowManager: overlayWindowManager),
            reportingService: reportingService,
            subscriptionService: subscriptionService,
            crashCollectionService: crashCollectionService,
            maliciousSiteProtectionService: maliciousSiteProtectionService,
            statisticsService: statisticsService
        )
    }

}
