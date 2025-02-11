//
//  Launching.swift
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

import Core
import UIKit
import BrowserServicesKit
import WidgetKit

/// Represents the transient state where the app is being prepared for user interaction after being launched by the system.
/// - Usage:
///   - This state is typically associated with the `application(_:didFinishLaunchingWithOptions:)` method.
///   - It is responsible for performing the app's initial setup, including configuring dependencies and preparing the UI.
///   - As part of this state, the `MainViewController` is created and set as the `rootViewController` of the app's primary `UIWindow`.
/// - Transitions:
///   - `Foreground`: Standard transition when the app completes its launch process and becomes active.
///   - `Background`: Occurs when the app is launched but transitions directly to the background, e.g:
///     - The app is protected by a FaceID lock mechanism (introduced in iOS 18.0). If the user opens the app
///       but does not authenticate and then leaves.
///     - The app is launched by the system for background execution but does not immediately become active.
/// - Notes:
///   - Avoid performing heavy or blocking operations during this phase to ensure smooth app startup.
@MainActor
struct Launching: AppState {

    private let appSettings = AppDependencyProvider.shared.appSettings
    private let voiceSearchHelper = VoiceSearchHelper()
    private let fireproofing = UserDefaultsFireproofing.xshared
    private let featureFlagger = AppDependencyProvider.shared.featureFlagger
    private let aiChatSettings = AIChatSettings()
    private let privacyConfigurationManager = ContentBlocking.shared.privacyConfigurationManager

    private let didFinishLaunchingStartTime = CFAbsoluteTimeGetCurrent()

    private let screenshotService: ScreenshotService
    private let authenticationService: AuthenticationService
    private let syncService: SyncService
    private let vpnService: VPNService
    private let autofillService = AutofillService()
    private let remoteMessagingService: RemoteMessagingService
    private let keyboardService: KeyboardService
    private let configurationService = ConfigurationService(isDebugBuild: isDebugBuild)
    private let autoClearService: AutoClearService
    private let reportingService: ReportingService
    private let subscriptionService: SubscriptionService
    private let crashCollectionService = CrashCollectionService()
    private let maliciousSiteProtectionService: MaliciousSiteProtectionService

    private let persistentStoresConfiguration = PersistentStoresConfiguration()
    private let onboardingConfiguration = OnboardingConfiguration()
    private let atbAndVariantConfiguration = ATBAndVariantConfiguration()
    private let historyManagerConfiguration = HistoryManagerConfiguration()

    private let window: UIWindow = UIWindow(frame: UIScreen.main.bounds)
    private let mainCoordinator: MainCoordinator

    var urlToOpen: URL?
    var shortcutItemToHandle: UIApplicationShortcutItem?

    // MARK: - Handle application(_:didFinishLaunchingWithOptions:) logic here
    init() {
        defer {
            let launchTime = CFAbsoluteTimeGetCurrent() - didFinishLaunchingStartTime
            Pixel.fire(pixel: .appDidFinishLaunchingTime(time: Pixel.Event.BucketAggregation(number: launchTime)),
                       withAdditionalParameters: [PixelParameters.time: String(launchTime)])
        }
        reportingService = ReportingService(fireproofing: fireproofing)
        KeyboardConfiguration.configure()
        PixelConfiguration.configure(featureFlagger: featureFlagger)
        ContentBlockingConfiguration.configure()
        UserAgentConfiguration.configureAPIRequestUserAgent()
        NewTabPageIntroMessageConfiguration().configure()
        onboardingConfiguration.migrate()

        persistentStoresConfiguration.configure()

        configurationService.onLaunching()
        crashCollectionService.onLaunching()

        WidgetCenter.shared.reloadAllTimelines()
        PrivacyFeatures.httpsUpgrade.loadDataAsync()

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
        mainCoordinator = MainCoordinator(syncService: syncService,
                                          bookmarksDatabase: persistentStoresConfiguration.bookmarksDatabase,
                                          remoteMessagingService: remoteMessagingService,
                                          daxDialogs: onboardingConfiguration.daxDialogs,
                                          reportingService: reportingService,
                                          variantManager: atbAndVariantConfiguration.variantManager,
                                          subscriptionService: subscriptionService,
                                          voiceSearchHelper: voiceSearchHelper,
                                          featureFlagger: featureFlagger,
                                          aiChatSettings: aiChatSettings,
                                          fireproofing: fireproofing,
                                          maliciousSiteProtectionService: maliciousSiteProtectionService,
                                          didFinishLaunchingStartTime: didFinishLaunchingStartTime)
        syncService.presenter = mainCoordinator.controller
        vpnService = VPNService(mainCoordinator: mainCoordinator)
        let overlayWindowManager = OverlayWindowManager(window: window,
                                                        appSettings: appSettings,
                                                        voiceSearchHelper: voiceSearchHelper,
                                                        featureFlagger: featureFlagger,
                                                        aiChatSettings: aiChatSettings)
        autoClearService = AutoClearService(worker: mainCoordinator.controller, overlayWindowManager: overlayWindowManager)
        screenshotService = ScreenshotService(window: window)
        authenticationService = AuthenticationService(overlayWindowManager: overlayWindowManager)
        keyboardService = KeyboardService(mainViewController: mainCoordinator.controller)

        autoClearService.onLaunching()
        vpnService.onLaunching()
        subscriptionService.onLaunching()
        autofillService.onLaunching()
        maliciousSiteProtectionService.onLaunching()

        atbAndVariantConfiguration.configure(onVariantAssigned: onVariantAssigned)
        CrashHandlersConfiguration.handleCrashDuringCrashHandlersSetup()
        TabInteractionStateConfiguration.configure(autoClearService: autoClearService, mainViewController: mainCoordinator.controller)
        UserAgentConfiguration.configureUserBrowsingUserAgent()

        setupWindow()
    }

    private func setupWindow() {
        ThemeManager.shared.updateUserInterfaceStyle(window: window)
        window.rootViewController = mainCoordinator.controller
        UIApplication.shared.setWindow(window)
        window.makeKeyAndVisible()
        mainCoordinator.start()
    }

    // MARK: - Handle ATB and variant assigned logic here
    func onVariantAssigned() {
        onboardingConfiguration.onVariantAssigned()
        historyManagerConfiguration.onVariantAssigned()
        reportingService.onVariantAssigned()
    }

    // MARK: -
    private var appDependencies: AppDependencies {
        .init(
            mainCoordinator: mainCoordinator,
            vpnService: vpnService,
            authenticationService: authenticationService,
            screenshotService: screenshotService,
            autoClearService: autoClearService,
            syncService: syncService,
            remoteMessagingService: remoteMessagingService,
            subscriptionService: subscriptionService,
            autofillService: autofillService,
            crashCollectionService: crashCollectionService,
            keyboardService: keyboardService,
            configurationService: configurationService,
            reportingService: reportingService,
            maliciousSiteProtectionService: maliciousSiteProtectionService
        )
    }
    
}

extension Launching {

    struct StateContext {

        let didFinishLaunchingStartTime: CFAbsoluteTime
        let urlToOpen: URL?
        let shortcutItemToHandle: UIApplicationShortcutItem?
        let appDependencies: AppDependencies

    }

    func makeStateContext() -> StateContext {
        .init(didFinishLaunchingStartTime: didFinishLaunchingStartTime,
              urlToOpen: urlToOpen,
              shortcutItemToHandle: shortcutItemToHandle,
              appDependencies: appDependencies)
    }

}

extension Launching {

    mutating func handle(action: AppAction) {
        switch action {
        case .openURL(let url):
            urlToOpen = url
        case .handleShortcutItem(let shortcutItem):
            shortcutItemToHandle = shortcutItem
        }
    }

}
