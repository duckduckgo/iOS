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

struct AppDependencies {

    let mainCoordinator: MainCoordinator
    let services: AppServices

}

struct AppServices {

    let screenshotService: ScreenshotService
    let authenticationService: AuthenticationService
    let syncService: SyncService
    let vpnService: VPNService
    let autofillService: AutofillService
    let remoteMessagingService: RemoteMessagingService
    let configurationService: ConfigurationService
    let autoClearService: AutoClearService
    let reportingService: ReportingService
    let subscriptionService: SubscriptionService
    let crashCollectionService: CrashCollectionService
    let maliciousSiteProtectionService: MaliciousSiteProtectionService
    let statisticsService: StatisticsService

}
