//
//  NewTabPageControllerDaxDialogTests.swift
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
@testable import DuckDuckGo
import Bookmarks
import Combine
import Core
import SwiftUI
import Persistence
import BrowserServicesKit

final class NewTabPageControllerDaxDialogTests: XCTestCase {

    var variantManager: CapturingVariantManager!
    var dialogFactory: CapturingNewTabDaxDialogProvider!
    var specProvider: MockNewTabDialogSpecProvider!
    var hvc: NewTabPageViewController!

    override func setUpWithError() throws {
        let db = CoreDataDatabase.bookmarksMock
        variantManager = CapturingVariantManager()
        dialogFactory = CapturingNewTabDaxDialogProvider()
        specProvider = MockNewTabDialogSpecProvider()

        let remoteMessagingClient = RemoteMessagingClient(
            bookmarksDatabase: db,
            appSettings: AppSettingsMock(),
            internalUserDecider: DefaultInternalUserDecider(),
            configurationStore: MockConfigurationStoring(),
            database: db,
            errorEvents: nil,
            remoteMessagingAvailabilityProvider: MockRemoteMessagingAvailabilityProviding(),
            duckPlayerStorage: MockDuckPlayerStorage())
        let homePageConfiguration = HomePageConfiguration(remoteMessagingClient: remoteMessagingClient, privacyProDataReporter: MockPrivacyProDataReporter())
        hvc = NewTabPageViewController(
            tab: Tab(),
            isNewTabPageCustomizationEnabled: false,
            interactionModel: MockFavoritesListInteracting(),
            homePageMessagesConfiguration: homePageConfiguration,
            variantManager: variantManager,
            newTabDialogFactory: dialogFactory,
            newTabDialogTypeProvider: specProvider,
            faviconLoader: EmptyFaviconLoading()
        )

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        window.rootViewController?.present(hvc, animated: false, completion: nil)

        let viewLoadedExpectation = expectation(description: "View is loaded")
        DispatchQueue.main.async {
            XCTAssertNotNil(self.hvc.view, "The view should be loaded")
            viewLoadedExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        specProvider.nextHomeScreenMessageCalled = false
        specProvider.nextHomeScreenMessageNewCalled = false
    }

    override func tearDownWithError() throws {
        variantManager = nil
        dialogFactory = nil
        specProvider = nil
        hvc = nil
    }

    func testWhenViewDidAppear_CorrectTypePassedToDialogFactory() throws {
        // GIVEN
        let expectedSpec = randomDialogType()
        specProvider.specToReturn = expectedSpec

        // WHEN
        hvc.viewDidAppear(false)

        // THEN
        XCTAssertFalse(self.specProvider.nextHomeScreenMessageCalled)
        XCTAssertTrue(self.specProvider.nextHomeScreenMessageNewCalled)
        XCTAssertEqual(self.dialogFactory.homeDialog, expectedSpec)
        XCTAssertNotNil(self.dialogFactory.onDismiss)
    }

    func testWhenOnboardingComplete_CorrectTypePassedToDialogFactory() throws {
        // GIVEN
        let expectedSpec = randomDialogType()
        specProvider.specToReturn = expectedSpec

        // WHEN
        hvc.onboardingCompleted()

        // THEN
        XCTAssertFalse(self.specProvider.nextHomeScreenMessageCalled)
        XCTAssertTrue(self.specProvider.nextHomeScreenMessageNewCalled)
        XCTAssertEqual(self.dialogFactory.homeDialog, expectedSpec)
        XCTAssertNotNil(self.dialogFactory.onDismiss)
    }

    func testWhenShowNextDaxDialog_AndShouldShowDaxDialogs_ThenReturnTrue() {
        // WHEN
        hvc.showNextDaxDialog()

        // THEN
        XCTAssertTrue(specProvider.nextHomeScreenMessageNewCalled)
    }

    private func randomDialogType() -> DaxDialogs.HomeScreenSpec {
        let specs: [DaxDialogs.HomeScreenSpec] = [.initial, .subsequent, .final, .addFavorite]
        return specs.randomElement()!
    }
}

class CapturingVariantManager: VariantManager {
    var currentVariant: Variant?
    var capturedFeatureName: FeatureName?
    var supportedFeatures: [FeatureName] = []

    func assignVariantIfNeeded(_ newInstallCompletion: (BrowserServicesKit.VariantManager) -> Void) {
    }

    func isSupported(feature: FeatureName) -> Bool {
        capturedFeatureName = feature
        return supportedFeatures.contains(feature)
    }
}


class MockFavoritesListInteracting: FavoritesListInteracting {
    var favoritesDisplayMode: Bookmarks.FavoritesDisplayMode = .displayNative(.mobile)
    var favorites: [Bookmarks.BookmarkEntity] = []
    func favorite(at index: Int) -> Bookmarks.BookmarkEntity? {
        return nil
    }
    func removeFavorite(_ favorite: Bookmarks.BookmarkEntity) {}
    func moveFavorite(_ favorite: Bookmarks.BookmarkEntity, fromIndex: Int, toIndex: Int) {    }
    var externalUpdates: AnyPublisher<Void, Never> = Empty<Void, Never>().eraseToAnyPublisher()
    var localUpdates: AnyPublisher<Void, Never> = Empty<Void, Never>().eraseToAnyPublisher()
    func reloadData() {}
}

class CapturingNewTabDaxDialogProvider: NewTabDaxDialogProvider {
    var homeDialog: DaxDialogs.HomeScreenSpec?
    var onDismiss: (() -> Void)?
    func createDaxDialog(for homeDialog: DaxDialogs.HomeScreenSpec, onDismiss: @escaping () -> Void) -> some View {
        self.homeDialog = homeDialog
        self.onDismiss = onDismiss
        return EmptyView()
    }
}


class MockNewTabDialogSpecProvider: NewTabDialogSpecProvider {
    var nextHomeScreenMessageCalled = false
    var nextHomeScreenMessageNewCalled = false
    var dismissCalled = false
    var specToReturn: DaxDialogs.HomeScreenSpec?

    func nextHomeScreenMessage() -> DaxDialogs.HomeScreenSpec? {
        nextHomeScreenMessageCalled = true
        return specToReturn
    }

    func nextHomeScreenMessageNew() -> DaxDialogs.HomeScreenSpec? {
        nextHomeScreenMessageNewCalled = true
        return specToReturn
    }

    func dismiss() {
        dismissCalled = true
    }
}

struct MockVariant: Variant {
    var name: String = ""
    var weight: Int = 0
    var isIncluded: () -> Bool = { false }
    var features: [BrowserServicesKit.FeatureName] = []

    init(features: [BrowserServicesKit.FeatureName]) {
        self.features = features
    }
}
