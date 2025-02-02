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

    private let accountManager = AppDependencyProvider.shared.accountManager
    private let appSettings = AppDependencyProvider.shared.appSettings
    private let voiceSearchHelper = VoiceSearchHelper()
    private let fireproofing = UserDefaultsFireproofing.xshared
    private let featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger

    private let didFinishLaunchingStartTime = CFAbsoluteTimeGetCurrent()

    private let screenshotService: ScreenshotService
    private let authenticationService: AuthenticationService
    private let syncService: SyncService
    private let vpnService: VPNService
    private let autofillService = AutofillService()
    private let persistenceService = PersistenceService()
    private let remoteMessagingService: RemoteMessagingService
    private let keyboardService: KeyboardService
    private let configurationService = ConfigurationService(isDebugBuild: isDebugBuild)
    private let autoClearService: AutoClearService
    private let reportingService: ReportingService
    private let subscriptionService: SubscriptionService
    private let crashCollectionService = CrashCollectionService()

    private let onboardingConfiguration = OnboardingConfiguration()
    private let atbAndVariantConfiguration = ATBAndVariantConfiguration()

    private let window: UIWindow
    private let mainCoordinator: MainCoordinator

    var urlToOpen: URL?
    var shortcutItemToHandle: UIApplicationShortcutItem?

    init(stateContext: Initializing.StateContext, application: UIApplication = UIApplication.shared) {
        defer {
            let launchTime = CFAbsoluteTimeGetCurrent() - didFinishLaunchingStartTime
            Pixel.fire(pixel: .appDidFinishLaunchingTime(time: Pixel.Event.BucketAggregation(number: launchTime)),
                       withAdditionalParameters: [PixelParameters.time: String(launchTime)])
        }

        reportingService = ReportingService(fireproofing: fireproofing)
        KeyboardConfiguration.configure()
        PixelConfiguration.configure(featureFlagger: featureFlagger)
        ContentBlockingConfiguration.configure()
        UserAgentConfiguration.configure()
        NewTabPageIntroMessageConfiguration().configure() // todo: @Mariusz can it be moved up here?

        configurationService.onLaunching()
        crashCollectionService.onLaunching()
        persistenceService.onLaunching()

        WidgetCenter.shared.reloadAllTimelines()

        PrivacyFeatures.httpsUpgrade.loadDataAsync()

        let privacyConfigurationManager = ContentBlocking.shared.privacyConfigurationManager
        syncService = SyncService(bookmarksDatabase: persistenceService.bookmarksDatabase)
        remoteMessagingService = RemoteMessagingService(persistenceService: persistenceService,
                                                        appSettings: appSettings,
                                                        internalUserDecider: AppDependencyProvider.shared.internalUserDecider,
                                                        configurationStore: AppDependencyProvider.shared.configurationStore,
                                                        privacyConfigurationManager: privacyConfigurationManager)
        subscriptionService = SubscriptionService(privacyConfigurationManager: privacyConfigurationManager)
        mainCoordinator = MainCoordinator(syncService: syncService,
                                          persistenceService: persistenceService,
                                          remoteMessagingService: remoteMessagingService,
                                          daxDialogs: onboardingConfiguration.daxDialogs,
                                          reportingService: reportingService,
                                          variantManager: atbAndVariantConfiguration.variantManager,
                                          subscriptionService: subscriptionService,
                                          voiceSearchHelper: voiceSearchHelper,
                                          featureFlagger: featureFlagger,
                                          fireproofing: fireproofing,
                                          accountManager: accountManager,
                                          didFinishLaunchingStartTime: didFinishLaunchingStartTime)
        let mainViewController = mainCoordinator.controller
        syncService.syncErrorHandler.alertPresenter = mainViewController

        window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = mainViewController
        application.setWindow(window)

        let overlayWindowManager = OverlayWindowManager(window: window,
                                                        addressBarPosition: appSettings.currentAddressBarPosition,
                                                        voiceSearchHelper: voiceSearchHelper)
        vpnService = VPNService(mainCoordinator: mainCoordinator)
        autoClearService = AutoClearService(worker: mainViewController, overlayWindowManager: overlayWindowManager)
        screenshotService = ScreenshotService(window: window)
        authenticationService = AuthenticationService(overlayWindowManager: overlayWindowManager)
        keyboardService = KeyboardService(mainViewController: mainViewController)

        ThemeManager.shared.updateUserInterfaceStyle(window: window)

        autoClearService.onLaunching()
        vpnService.onLaunching()
        subscriptionService.onLaunching()
        autofillService.onLaunching()

        atbAndVariantConfiguration.configure(onVariantAssigned: onVariantAssigned)
        stateContext.crashHandlersConfiguration.handleCrashDuringCrashHandlersSetup()

        window.makeKeyAndVisible()
        mainCoordinator.start()
    }

    func onVariantAssigned() {
        onboardingConfiguration.onVariantAssigned()

        // New users don't see the message
        let historyMessageManager = HistoryMessageManager()
        historyMessageManager.dismiss()

        reportingService.onVariantAssigned()
    }

    private var appDependencies: AppDependencies {
        AppDependencies(
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
            reportingService: reportingService
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
