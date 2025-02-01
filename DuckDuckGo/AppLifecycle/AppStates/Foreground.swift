//
//  Foreground.swift
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
import UIKit
import Core
import BackgroundTasks

/// Represents the state where the app is active and available for user interaction.
/// - Usage:
///   - This state is typically associated with the `applicationDidBecomeActive(_:)` method.
///   - The app transitions to this state after completing the launch process or resuming from the background.
///   - During this state, the app is fully interactive, and the user can engage with the app's UI.
/// - Transitions:
///   - `Suspending`: The app transitions to this state when it begins the process of moving to the background,
///     typically triggered by the `applicationWillResignActive(_:)` method, e.g.:
///     - When the user presses the home button, swipes up to the App Switcher, or receives a system interruption.
/// - Notes:
///   - This is one of the two long-living states in the app's lifecycle (along with `Background`).
@MainActor
struct Foreground: AppState {

    var appDependencies: AppDependencies
    private var mainCoordinator: MainCoordinator { appDependencies.mainCoordinator }

    private var urlToOpen: URL?
    private var shortcutItemToHandle: UIApplicationShortcutItem?
    private var lastBackgroundDate: Date?

    private let privacyConfigurationManager = ContentBlocking.shared.privacyConfigurationManager

    private var didEnterForeground: Bool = false

    // MARK: Handle logic when transitioning from Launched to Foreground
    // This transition occurs when the app has completed its launch process and becomes active.
    // Note: You want to add here code that will happen one-time per app lifecycle, but you require the UI to be active at this point!
    init(stateContext: Launching.StateContext, application: UIApplication = UIApplication.shared) {
        appDependencies = stateContext.appDependencies
        urlToOpen = stateContext.urlToOpen
        shortcutItemToHandle = stateContext.shortcutItemToHandle

        appDependencies.subscriptionService.onFirstForeground() // could it be on launching then?
        initialiseBackgroundFetch(application) // could it be on launching then?
        applyAppearanceChanges() // could it be on launching then?
        appDependencies.remoteMessagingService.onForeground() // could it be on launching then?

        let authenticationService = appDependencies.authenticationService
        guard authenticationService.isAuthenticated else {
            authenticationService.beginAuthentication()
            return
        }

        onForeground()
    }

    // MARK: Handle logic when transitioning from Resuming to Foreground
    // This transition occurs when the app returns to the foreground after being backgrounded (e.g., after unlocking the app).
    init(stateContext: Resuming.StateContext) {
        appDependencies = stateContext.appDependencies
        urlToOpen = stateContext.urlToOpen
        shortcutItemToHandle = stateContext.shortcutItemToHandle
        lastBackgroundDate = stateContext.lastBackgroundDate

        let authenticationService = appDependencies.authenticationService
        guard authenticationService.isAuthenticated else {
            authenticationService.beginAuthentication()
            return
        }

        onForeground()
    }

    // MARK: Handle logic when transitioning from Suspending to Foreground
    // This transition occurs when the app returns to the foreground after briefly being suspended (e.g., user dismisses a notification).
    init(stateContext: Suspending.StateContext) {
        appDependencies = stateContext.appDependencies
        urlToOpen = stateContext.urlToOpen
        shortcutItemToHandle = stateContext.shortcutItemToHandle

        onForeground()
    }

    // MARK: handle applicationDidBecomeActive(_:) logic here
    private mutating func onForeground() {
        didEnterForeground = true
        appDependencies.autoClearService.registerForDataCleared(onDataCleared)

        appDependencies.syncService.onForeground()

        StatisticsLoader.shared.load(completion: onStatisticsLoaded)

        mainCoordinator.onForeground()

        appDependencies.configurationService.onConfigurationFetched = onConfigurationFetched
        appDependencies.configurationService.onForeground()

        appDependencies.vpnService.onForeground()
        appDependencies.subscriptionService.onForeground()
        appDependencies.autofillService.syncService = appDependencies.syncService
        appDependencies.autofillService.onForeground()

        appDependencies.reportingService.syncService = appDependencies.syncService
        appDependencies.reportingService.onForeground()
    }

    private func onStatisticsLoaded() {
        StatisticsLoader.shared.refreshAppRetentionAtb()
        appDependencies.reportingService.onStatisticsLoaded()
    }

    private func onDataCleared() {
        appDependencies.vpnService.onDataCleared()

        if let url = urlToOpen {
            openURL(url)
        } else if let shortcutItemToHandle = shortcutItemToHandle {
            handleShortcutItem(shortcutItemToHandle, appIsLaunching: true)
        } else {
            appDependencies.keyboardService.showKeyboardOnLaunch(lastBackgroundDate: lastBackgroundDate)
            // is this logic correct? should we show keyboard on link/shortcut opening?
        }
    }

    private func onConfigurationFetched() { // TODO: needs documentation
        appDependencies.reportingService.onConfigurationFetched()
    }

    // MARK: handle application(_:open:options:) logic here
    func openURL(_ url: URL) {
        Logger.sync.debug("App launched with url \(url.absoluteString)")
        guard mainCoordinator.shouldProcessDeepLink(url) else { return }

        NotificationCenter.default.post(name: AutofillLoginListAuthenticator.Notifications.invalidateContext, object: nil)

        // TODO: to be refactored after introducing autoclearservice, we won't need clearNavigationStack, it should be hidden implementation, we
        // TODO: should just call mainCoordinator.handleURL or processDeeplink
        // The openVPN action handles the navigation stack on its own and does not need it to be cleared
        if url != AppDeepLinkSchemes.openVPN.url {
            mainCoordinator.clearNavigationStack()
        }

        appDependencies.keyboardService.showKeyboardIfSettingOn = false
        mainCoordinator.handleURL(url)
    }

    private func initialiseBackgroundFetch(_ application: UIApplication) {
        guard UIApplication.shared.backgroundRefreshStatus == .available else {
            return
        }

        // BackgroundTasks will automatically replace an existing task in the queue if one with the same identifier is queued, so we should only
        // schedule a task if there are none pending in order to avoid the config task getting perpetually replaced.
        BGTaskScheduler.shared.getPendingTaskRequests { tasks in
            let hasConfigurationTask = tasks.contains { $0.identifier == AppConfigurationFetch.Constants.backgroundProcessingTaskIdentifier }
            if !hasConfigurationTask {
                AppConfigurationFetch.scheduleBackgroundRefreshTask()
            }

            let hasRemoteMessageFetchTask = tasks.contains { $0.identifier == RemoteMessagingClient.Constants.backgroundRefreshTaskIdentifier }
            if !hasRemoteMessageFetchTask {
                RemoteMessagingClient.scheduleBackgroundRefreshTask()
            }
        }
    }

    private func applyAppearanceChanges() {
        UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).numberOfLines = 0
    }

    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem, appIsLaunching: Bool = false) {
        Logger.general.debug("Handling shortcut item: \(shortcutItem.type)")
        if shortcutItem.type == AppDelegate.ShortcutKey.clipboard, let query = UIPasteboard.general.string {
            mainCoordinator.handleQuery(query)
        } else if shortcutItem.type == AppDelegate.ShortcutKey.passwords {
            mainCoordinator.handleSearchPassword()
        } else if shortcutItem.type == AppDelegate.ShortcutKey.openVPNSettings {
            mainCoordinator.presentNetworkProtectionStatusSettingsModal()
        }
    }

}

extension Foreground {

    struct StateContext {

        let urlToOpen: URL?
        let shortcutItemToHandle: UIApplicationShortcutItem?
        let appDependencies: AppDependencies

        init(urlToOpen: URL? = nil, shortcutItemToHandle: UIApplicationShortcutItem? = nil, appDependencies: AppDependencies) {
            self.urlToOpen = urlToOpen
            self.shortcutItemToHandle = shortcutItemToHandle
            self.appDependencies = appDependencies
        }

    }

    func makeStateContext() -> StateContext {
        /// Authentication causes the app to leave the `Foreground` state and move to the `Suspending` state.
        /// This means we must retain `urlToOpen` and `shortcutItemToHandle` to ensure they are available
        /// when the app resumes after authentication. Otherwise, they would be lost during state transitions.
        if didEnterForeground {
            return .init(appDependencies: appDependencies)
        }
        return .init(
            urlToOpen: urlToOpen,
            shortcutItemToHandle: shortcutItemToHandle,
            appDependencies: appDependencies
        )
    }

}

extension Foreground {

    func handle(action: AppAction) {
        switch action {
        case .openURL(let url):
            openURL(url)
        case .handleShortcutItem(let shortcutItem):
            handleShortcutItem(shortcutItem)
        }
    }

}
