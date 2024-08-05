//
//  OnboardingDaxFavouritesTests.swift
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

import XCTest
import Persistence
import Bookmarks
import DDGSync
import History
import BrowserServicesKit
import RemoteMessaging
import Configuration
import Core
@testable import DuckDuckGo

final class OnboardingDaxFavouritesTests: XCTestCase {
    private var sut: MainViewController!
    private var tutorialSettingsMock: MockTutorialSettings!
    private var contextualOnboardingLogicMock: ContextualOnboardingLogicMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let db = CoreDataDatabase.bookmarksMock
        let bookmarkDatabaseCleaner = BookmarkDatabaseCleaner(bookmarkDatabase: db, errorEvents: nil)
        let dataProviders = SyncDataProviders(
            bookmarksDatabase: db,
            secureVaultFactory: AutofillSecureVaultFactory,
            secureVaultErrorReporter: SecureVaultReporter(),
            settingHandlers: [],
            favoritesDisplayModeStorage: MockFavoritesDisplayModeStoring(),
            syncErrorHandler: SyncErrorHandler()
        )

        let remoteMessagingClient = RemoteMessagingClient(
            bookmarksDatabase: db,
            appSettings: AppSettingsMock(),
            internalUserDecider: DefaultInternalUserDecider(),
            configurationStore: MockConfigurationStoring(),
            database: db,
            errorEvents: nil,
            remoteMessagingAvailabilityProvider: MockRemoteMessagingAvailabilityProviding(),
            duckPlayerStorage: MockDuckPlayerStorage()
        )
        let homePageConfiguration = HomePageConfiguration(remoteMessagingClient: remoteMessagingClient, privacyProDataReporter: MockPrivacyProDataReporter())
        let tabsModel = TabsModel(desktop: true)
        tutorialSettingsMock = MockTutorialSettings(hasSeenOnboarding: false)
        contextualOnboardingLogicMock = ContextualOnboardingLogicMock()
        sut = MainViewController(
            bookmarksDatabase: db,
            bookmarksDatabaseCleaner: bookmarkDatabaseCleaner,
            historyManager: MockHistoryManager(historyCoordinator: MockHistoryCoordinator(), isEnabledByUser: true, historyFeatureEnabled: true),
            homePageConfiguration: homePageConfiguration,
            syncService: MockDDGSyncing(authState: .active, isSyncInProgress: false),
            syncDataProviders: dataProviders,
            appSettings: AppSettingsMock(),
            previewsSource: TabPreviewsSource(),
            tabsModel: tabsModel,
            syncPausedStateManager: CapturingSyncPausedStateManager(),
            privacyProDataReporter: MockPrivacyProDataReporter(),
            variantManager: MockVariantManager(),
            contextualOnboardingPresenter: ContextualOnboardingPresenterMock(),
            contextualOnboardingLogic: contextualOnboardingLogicMock,
            contextualOnboardingPixelReporter: OnboardingPixelReporterMock(),
            tutorialSettings: tutorialSettingsMock
        )
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        window.rootViewController?.present(sut, animated: false, completion: nil)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testWhenMakeOnboardingSeenIsCalled_ThenSetHasSeenOnboardingTrue() {
        // GIVEN
        XCTAssertFalse(tutorialSettingsMock.hasSeenOnboarding)

        // WHEN
        tutorialSettingsMock.hasSeenOnboarding = true

        // THEN
        XCTAssertTrue(tutorialSettingsMock.hasSeenOnboarding)
    }

    func testWhenHasSeenOnboardingIntroIsCalled_AndHasSeenOnboardingSettingIsTrue_ThenReturnFalse() throws {
        // GIVEN
        tutorialSettingsMock.hasSeenOnboarding = true

        // WHEN
        let result = sut.needsToShowOnboardingIntro()

        // THEN
        XCTAssertFalse(result)
    }

    func testWhenHasSeenOnboardingIntroIsCalled_AndHasSeenOnboardingIsFalse_ThenReturnTrue() throws {
        // GIVEN
        tutorialSettingsMock.hasSeenOnboarding = false

        // WHEN
        let result = sut.needsToShowOnboardingIntro()

        // THEN
        XCTAssertTrue(result)
    }

    func testWhenAddFavouriteIsCalled_ThenItShouldAskContextualOnboardingLogicIfAddFavoriteFlowCanStart() {
        // GIVEN
        XCTAssertFalse(contextualOnboardingLogicMock.didCallCanEnableAddFavoriteFlow)

        // WHEN
        sut.startAddFavoriteFlow()

        // THEN
        XCTAssertTrue(contextualOnboardingLogicMock.didCallCanEnableAddFavoriteFlow)
    }

    func testWhenAddFavouriteIsCalled_AndCanStartAddFavouriteFlow_ThenItShouldEnableAddFavouriteFlowOnContextualOnboardingLogic() {
        // GIVEN
        contextualOnboardingLogicMock.canStartFavoriteFlow = true
        XCTAssertFalse(contextualOnboardingLogicMock.didCallEnableAddFavoriteFlow)

        // WHEN
        sut.startAddFavoriteFlow()

        // THEN
        XCTAssertTrue(contextualOnboardingLogicMock.didCallEnableAddFavoriteFlow)
    }

    func testWhenAddFavouriteIsCalled_AndCannotStartAddFavouriteFlow_ThenItShouldNotEnableAddFavouriteFlowOnContextualOnboardingLogic() {
        // GIVEN
        contextualOnboardingLogicMock.canStartFavoriteFlow = false
        XCTAssertFalse(contextualOnboardingLogicMock.didCallEnableAddFavoriteFlow)

        // WHEN
        sut.startAddFavoriteFlow()

        // THEN
        XCTAssertFalse(contextualOnboardingLogicMock.didCallEnableAddFavoriteFlow)
    }

    func testWhenAddFavouriteIsCalled_AndCannotStartAddFavouriteFlow_ThenOpenANewTab() {
        // GIVEN
        contextualOnboardingLogicMock.canStartFavoriteFlow = false
        XCTAssertEqual(sut.tabManager.model.tabs.count, 1)

        // WHEN
        sut.startAddFavoriteFlow()

        // THEN
        XCTAssertEqual(sut.tabManager.model.tabs.count, 2)
    }
}
