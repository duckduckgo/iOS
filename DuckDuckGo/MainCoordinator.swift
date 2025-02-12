//
//  MainCoordinator.swift
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
import BrowserServicesKit
import Subscription
import Persistence

@MainActor
final class MainCoordinator {

    let controller: MainViewController
    private let accountManager: AccountManager

    init(syncService: SyncService,
         bookmarksDatabase: CoreDataDatabase,
         remoteMessagingService: RemoteMessagingService,
         daxDialogs: DaxDialogs,
         reportingService: ReportingService,
         variantManager: DefaultVariantManager,
         subscriptionService: SubscriptionService,
         voiceSearchHelper: VoiceSearchHelper,
         featureFlagger: FeatureFlagger,
         aiChatSettings: AIChatSettings,
         fireproofing: Fireproofing,
         accountManager: AccountManager = AppDependencyProvider.shared.accountManager,
         maliciousSiteProtectionService: MaliciousSiteProtectionService,
         didFinishLaunchingStartTime: CFAbsoluteTime) {
        self.accountManager = accountManager
        let homePageConfiguration = HomePageConfiguration(variantManager: AppDependencyProvider.shared.variantManager,
                                                          remoteMessagingClient: remoteMessagingService.remoteMessagingClient,
                                                          privacyProDataReporter: reportingService.privacyProDataReporter)
        let previewsSource = TabPreviewsSource()
        let historyManager = Self.makeHistoryManager()
        let tabsModel = Self.prepareTabsModel(previewsSource: previewsSource)
        reportingService.privacyProDataReporter.injectTabsModel(tabsModel)

        let daxDialogsFactory = ExperimentContextualDaxDialogsFactory(contextualOnboardingLogic: daxDialogs,
                                                                      contextualOnboardingPixelReporter: reportingService.onboardingPixelReporter)
        let contextualOnboardingPresenter = ContextualOnboardingPresenter(variantManager: variantManager, daxDialogsFactory: daxDialogsFactory)
        controller = MainViewController(bookmarksDatabase: bookmarksDatabase,
                                        bookmarksDatabaseCleaner: syncService.syncDataProviders.bookmarksAdapter.databaseCleaner,
                                        historyManager: historyManager,
                                        homePageConfiguration: homePageConfiguration,
                                        syncService: syncService.sync,
                                        syncDataProviders: syncService.syncDataProviders,
                                        appSettings: AppDependencyProvider.shared.appSettings,
                                        previewsSource: previewsSource,
                                        tabsModel: tabsModel,
                                        syncPausedStateManager: syncService.syncErrorHandler,
                                        privacyProDataReporter: reportingService.privacyProDataReporter,
                                        variantManager: variantManager,
                                        contextualOnboardingPresenter: contextualOnboardingPresenter,
                                        contextualOnboardingLogic: daxDialogs,
                                        contextualOnboardingPixelReporter: reportingService.onboardingPixelReporter,
                                        subscriptionFeatureAvailability: subscriptionService.subscriptionFeatureAvailability,
                                        voiceSearchHelper: voiceSearchHelper,
                                        featureFlagger: featureFlagger,
                                        fireproofing: fireproofing,
                                        subscriptionCookieManager: subscriptionService.subscriptionCookieManager,
                                        textZoomCoordinator: Self.makeTextZoomCoordinator(),
                                        websiteDataManager: Self.makeWebsiteDataManager(fireproofing: fireproofing),
                                        appDidFinishLaunchingStartTime: didFinishLaunchingStartTime,
                                        maliciousSiteProtectionManager: maliciousSiteProtectionService.manager,
                                        maliciousSiteProtectionPreferencesManager: maliciousSiteProtectionService.preferencesManager,
                                        aichatSettings: aiChatSettings)
    }

    func start() {
        controller.loadViewIfNeeded()
    }

    private static func makeHistoryManager() -> HistoryManaging {
        let provider = AppDependencyProvider.shared
        switch HistoryManager.make(isAutocompleteEnabledByUser: provider.appSettings.autocomplete,
                                   isRecentlyVisitedSitesEnabledByUser: provider.appSettings.recentlyVisitedSites,
                                   privacyConfigManager: ContentBlocking.shared.privacyConfigurationManager,
                                   tld: provider.storageCache.tld) {

        case .failure(let error):
            Pixel.fire(pixel: .historyStoreLoadFailed, error: error)
            if error.isDiskFull {
                NotificationCenter.default.post(name: .databaseDidEncounterInsufficientDiskSpace, object: nil)
            } else {
                NotificationCenter.default.post(name: .appDidEncounterUnrecoverableState, object: nil)
            }
            return NullHistoryManager()
        case .success(let historyManager):
            return historyManager
        }
    }

    private static func prepareTabsModel(previewsSource: TabPreviewsSource = TabPreviewsSource(),
                                         appSettings: AppSettings = AppDependencyProvider.shared.appSettings,
                                         isDesktop: Bool = UIDevice.current.userInterfaceIdiom == .pad) -> TabsModel {
        let isPadDevice = UIDevice.current.userInterfaceIdiom == .pad
        let tabsModel: TabsModel
        if AutoClearSettingsModel(settings: appSettings) != nil {
            tabsModel = TabsModel(desktop: isPadDevice)
            tabsModel.save()
            previewsSource.removeAllPreviews()
        } else {
            if let storedModel = TabsModel.get() {
                // Save new model in case of migration
                storedModel.save()
                tabsModel = storedModel
            } else {
                tabsModel = TabsModel(desktop: isPadDevice)
            }
        }
        return tabsModel
    }

    private static func makeTextZoomCoordinator() -> TextZoomCoordinator {
        let provider = AppDependencyProvider.shared
        let storage = TextZoomStorage()

        return TextZoomCoordinator(appSettings: provider.appSettings,
                                   storage: storage,
                                   featureFlagger: provider.featureFlagger)
    }

    private static func makeWebsiteDataManager(fireproofing: Fireproofing,
                                               dataStoreIDManager: DataStoreIDManaging = DataStoreIDManager.shared) -> WebsiteDataManaging {
        return WebCacheManager(cookieStorage: MigratableCookieStorage(),
                               fireproofing: fireproofing,
                               dataStoreIDManager: dataStoreIDManager)
    }

    func handleAppDeepLink(url: URL, application: UIApplication = UIApplication.shared) -> Bool {

        if url != AppDeepLinkSchemes.openVPN.url && url.scheme != AppDeepLinkSchemes.openAIChat.url.scheme {
            controller.clearNavigationStack()
        }

        switch AppDeepLinkSchemes.fromURL(url) {
        case .newSearch:
            controller.newTab(reuseExisting: true)
            controller.enterSearch()

        case .favorites:
            controller.newTab(reuseExisting: true, allowingKeyboard: false)

        case .quickLink:
            let query = AppDeepLinkSchemes.query(fromQuickLink: url)
            controller.loadQueryInNewTab(query, reuseExisting: true)

        case .addFavorite:
            controller.startAddFavoriteFlow()

        case .fireButton:
            controller.forgetAllWithAnimation()

        case .voiceSearch:
            controller.onVoiceSearchPressed()

        case .newEmail:
            controller.newEmailAddress()

        case .openVPN:
            presentNetworkProtectionStatusSettingsModal()

        case .openPasswords:
            var source: AutofillSettingsSource = .homeScreenWidget

            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                let queryItems = components.queryItems,
                queryItems.first(where: { $0.name == "ls" }) != nil {
                Pixel.fire(pixel: .autofillLoginsLaunchWidgetLock)
                source = .lockScreenWidget
            } else {
                Pixel.fire(pixel: .autofillLoginsLaunchWidgetHome)
            }

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.controller.launchAutofillLogins(openSearch: true, source: source)
            }
        case .openAIChat:
            AIChatDeepLinkHandler().handleDeepLink(url, on: controller)

        default:
            guard application.applicationState == .active,
                  let currentTab = controller.currentTab else {
                return false
            }

            // If app is in active state, treat this navigation as something initiated form the context of the current tab.
            controller.tab(currentTab,
                           didRequestNewTabForUrl: url,
                           openedByPage: true,
                           inheritingAttribution: nil)
        }

        return true
    }

    func segueToPrivacyPro() {
        controller.segueToPrivacyPro()
    }

    func presentNetworkProtectionStatusSettingsModal() {
        Task {
            if case .success(let hasEntitlements) = await accountManager.hasEntitlement(forProductName: .networkProtection), hasEntitlements {
                controller.segueToVPN()
            } else {
                controller.segueToPrivacyPro()
            }
        }
    }

    private func handleEmailSignUpDeepLink(_ url: URL) -> Bool {
        guard url.absoluteString.starts(with: URL.emailProtection.absoluteString),
              let navViewController = controller.presentedViewController as? UINavigationController,
              let emailSignUpViewController = navViewController.topViewController as? EmailSignupViewController else {
            return false
        }
        emailSignUpViewController.loadUrl(url)
        return true
    }

    func handleQuery(_ query: String) {
        controller.clearNavigationStack()
        controller.loadQueryInNewTab(query)
    }

    func handleSearchPassword() {
        controller.clearNavigationStack()
        // Give the `clearNavigationStack` call time to complete.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.controller.launchAutofillLogins(openSearch: true, source: .appIconShortcut)
        }
        Pixel.fire(pixel: .autofillLoginsLaunchAppShortcut)
    }

    func handleURL(_ url: URL) {
        guard !handleAppDeepLink(url: url) else { return }
        controller.loadUrlInNewTab(url, reuseExisting: true, inheritedAttribution: nil, fromExternalLink: true)
    }

    func shouldProcessDeepLink(_ url: URL) -> Bool {
        // Ignore deeplinks if onboarding is active
        // as well as handle email sign-up deep link separately
        !controller.needsToShowOnboardingIntro() && !handleEmailSignUpDeepLink(url)
    }

    func onForeground() {
        controller.showBars()
        controller.onForeground()
    }

    func onBackground() {
        resetAppStartTime()
    }

    private func resetAppStartTime() {
        controller.appDidFinishLaunchingStartTime = nil
    }

}
