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

    private let didFinishLaunchingStartTime = CFAbsoluteTimeGetCurrent()
    private let window: UIWindow = UIWindow(frame: UIScreen.main.bounds)

    /// Handles one-time application setup during launch
    private let configuration = AppConfiguration()

    /// Holds app-wide services that respond to lifecycle events and live throughout the app's lifetime.
    private let services: AppServices

    /// Coordinates and initializes the main view controller.
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
        configuration.start()
        let overlayWindowManager = OverlayWindowManager(window: window,
                                                        appSettings: appSettings,
                                                        voiceSearchHelper: voiceSearchHelper,
                                                        featureFlagger: featureFlagger,
                                                        aiChatSettings: aiChatSettings)
        let servicesBuilder = AppServicesBuilder(window: window,
                                                 fireproofing: fireproofing,
                                                 overlayWindowManager: overlayWindowManager,
                                                 persistentStoresConfiguration: configuration.persistentStoresConfiguration)
        mainCoordinator = MainCoordinator(syncService: servicesBuilder.syncService,
                                          bookmarksDatabase: configuration.persistentStoresConfiguration.bookmarksDatabase,
                                          remoteMessagingService: servicesBuilder.remoteMessagingService,
                                          daxDialogs: configuration.onboardingConfiguration.daxDialogs,
                                          reportingService: servicesBuilder.reportingService,
                                          variantManager: configuration.atbAndVariantConfiguration.variantManager,
                                          subscriptionService: servicesBuilder.subscriptionService,
                                          voiceSearchHelper: voiceSearchHelper,
                                          featureFlagger: featureFlagger,
                                          aiChatSettings: aiChatSettings,
                                          fireproofing: fireproofing,
                                          maliciousSiteProtectionService: servicesBuilder.maliciousSiteProtectionService,
                                          didFinishLaunchingStartTime: didFinishLaunchingStartTime)
        services = servicesBuilder.complete(with: mainCoordinator)
        services.syncService.presenter = mainCoordinator.controller

        startServices()
        configuration.finalize(with: services.reportingService)
        setupWindow()
    }

    private func startServices() {
        services.crashCollectionService.start()
        services.syncService.start()
        services.remoteMessagingService.start()
        services.autoClearService.start()
        services.vpnService.start()
        services.subscriptionService.start()
        services.autofillService.start()
        services.maliciousSiteProtectionService.start()
    }

    private func setupWindow() {
        ThemeManager.shared.updateUserInterfaceStyle(window: window)
        window.rootViewController = mainCoordinator.controller
        UIApplication.shared.setWindow(window)
        window.makeKeyAndVisible()
        mainCoordinator.start()
    }

    // MARK: -

    private var appDependencies: AppDependencies {
        .init(
            mainCoordinator: mainCoordinator,
            services: services
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
