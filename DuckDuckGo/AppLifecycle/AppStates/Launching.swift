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

import Foundation
import Core
import Networking
import UIKit
import BrowserServicesKit
import WidgetKit
import WebKit

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

    private let marketplaceAdPostbackManager = MarketplaceAdPostbackManager()
    private let accountManager = AppDependencyProvider.shared.accountManager
    private let appSettings = AppDependencyProvider.shared.appSettings
    private let voiceSearchHelper = VoiceSearchHelper()
    private let onboardingPixelReporter = OnboardingPixelReporter()
    private let fireproofing = UserDefaultsFireproofing.xshared
    private let featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger

    private let privacyProDataReporter: PrivacyProDataReporting
    private let didFinishLaunchingStartTime = CFAbsoluteTimeGetCurrent()

    private let screenshotService: ScreenshotService
    private let overlayWindowManager: OverlayWindowManager
    private let authenticationService: AuthenticationService
    private let syncService: SyncService
    private let vpnService: VPNService
    private let autofillService: AutofillService = AutofillService()
    private let persistenceService = PersistenceService()
    private let remoteMessagingService: RemoteMessagingService
    private let keyboardService: KeyboardService
    private let contentBlockingService: ContentBlockingService = ContentBlockingService()
    private let configurationService: ConfigurationService = ConfigurationService(isDebugBuild: isDebugBuild)
    private let autoClearService: AutoClearService

    private let window: UIWindow

    private let mainCoordinator: MainCoordinator

    var urlToOpen: URL?
    var shortcutItemToHandle: UIApplicationShortcutItem?

    private let application: UIApplication
    private let crashService: CrashService
    private let subscriptionService: SubscriptionService

    init(stateContext: Initializing.StateContext) {

        defer {
            let launchTime = CFAbsoluteTimeGetCurrent() - didFinishLaunchingStartTime
            Pixel.fire(pixel: .appDidFinishLaunchingTime(time: Pixel.Event.BucketAggregation(number: launchTime)),
                       withAdditionalParameters: [PixelParameters.time: String(launchTime)])
        }

        application = stateContext.application
        crashService = stateContext.crashService

        privacyProDataReporter = PrivacyProDataReporter(fireproofing: fireproofing)
        KeyboardConfiguration.configure()
        PixelConfiguration.configure(featureFlagger: featureFlagger)
        contentBlockingService.onLaunching()
        APIRequest.Headers.setUserAgent(DefaultUserAgentManager.duckDuckGoUserAgent)
        configurationService.onLaunching()
        crashService.startAttachingCrashLogMessages(application: application)
        persistenceService.onLaunching()
        _ = DefaultUserAgentManager.shared

        WidgetCenter.shared.reloadAllTimelines()

        PrivacyFeatures.httpsUpgrade.loadDataAsync()

        let variantManager = DefaultVariantManager()
        let daxDialogs = DaxDialogs.shared

        // assign it here, because "did become active" is already too late and "viewWillAppear"
        // has already been called on the HomeViewController so won't show the home row CTA
        cleanUpATBAndAssignVariant(variantManager: variantManager,
                                   daxDialogs: daxDialogs,
                                   marketplaceAdPostbackManager: marketplaceAdPostbackManager)

        func cleanUpATBAndAssignVariant(variantManager: VariantManager,
                                        daxDialogs: DaxDialogs,
                                        marketplaceAdPostbackManager: MarketplaceAdPostbackManager) {
            let historyMessageManager = HistoryMessageManager()

            AtbAndVariantCleanup.cleanup()
            variantManager.assignVariantIfNeeded { _ in
                let launchOptionsHandler = LaunchOptionsHandler()

                // MARK: perform first time launch logic here
                // If it's running UI Tests check if the onboarding should be in a completed state.
                if launchOptionsHandler.isUITesting && launchOptionsHandler.isOnboardingCompleted {
                    daxDialogs.dismiss()
                } else {
                    daxDialogs.primeForUse()
                }

                // New users don't see the message
                historyMessageManager.dismiss()

                // Setup storage for marketplace postback
                marketplaceAdPostbackManager.updateReturningUserValue()
            }
        }

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
                                          privacyProDataReporter: privacyProDataReporter,
                                          daxDialogs: daxDialogs,
                                          onboardingPixelReporter: onboardingPixelReporter,
                                          variantManager: variantManager,
                                          subscriptionService: subscriptionService,
                                          voiceSearchHelper: voiceSearchHelper,
                                          featureFlagger: featureFlagger,
                                          fireproofing: fireproofing,
                                          accountManager: accountManager,
                                          didFinishLaunchingStartTime: didFinishLaunchingStartTime)
        mainCoordinator.start()
        let mainViewController = mainCoordinator.controller
        syncService.syncErrorHandler.alertPresenter = mainViewController

        window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = mainViewController
        window.makeKeyAndVisible()
        application.setWindow(window)

        overlayWindowManager = OverlayWindowManager(window: window,
                                                    addressBarPosition: appSettings.currentAddressBarPosition,
                                                    voiceSearchHelper: voiceSearchHelper)
        vpnService = VPNService(mainCoordinator: mainCoordinator)
        autoClearService = AutoClearService(worker: mainViewController, overlayWindowManager: overlayWindowManager)
        screenshotService = ScreenshotService(window: window)
        authenticationService = AuthenticationService(overlayWindowManager: overlayWindowManager)
        keyboardService = KeyboardService(mainViewController: mainViewController)

        ThemeManager.shared.updateUserInterfaceStyle(window: window)

        NewTabPageIntroMessageSetup().perform()
        autoClearService.onLaunching()
        vpnService.onLaunching()
        subscriptionService.onLaunching()
        autofillService.onLaunching()
        crashService.handleCrashDuringCrashHandlersSetup()
    }

    private var appDependencies: AppDependencies {
        AppDependencies(
            window: window,
            mainCoordinator: mainCoordinator,
            overlayWindowManager: overlayWindowManager,
            vpnService: vpnService,
            authenticationService: authenticationService,
            screenshotService: screenshotService,
            autoClearService: autoClearService,
            syncService: syncService,
            remoteMessagingService: remoteMessagingService,
            subscriptionService: subscriptionService,
            autofillService: autofillService,
            crashService: crashService,
            keyboardService: keyboardService,
            configurationService: configurationService,
            marketplaceAdPostbackManager: marketplaceAdPostbackManager,
            privacyProDataReporter: privacyProDataReporter,
            onboardingPixelReporter: onboardingPixelReporter
        )
    }
    
}

extension Launching {

    struct StateContext {

        let application: UIApplication
        let didFinishLaunchingStartTime: CFAbsoluteTime
        let urlToOpen: URL?
        let shortcutItemToHandle: UIApplicationShortcutItem?
        let appDependencies: AppDependencies

    }

    func makeStateContext() -> StateContext {
        .init(application: application,
              didFinishLaunchingStartTime: didFinishLaunchingStartTime,
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

extension UIApplication {

    enum TerminationReason {

        case insufficientDiskSpace
        case rulesCompilationFatalError

    }

    func setWindow(_ window: UIWindow?) {
        (delegate as? AppDelegate)?.window = window
    }

    var window: UIWindow? {
        delegate?.window ?? nil
    }

}
