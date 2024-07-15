//
//  HomeViewControllerDaxDialogTests.swift
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

final class HomeViewControllerDaxDialogTests: XCTestCase {

    var variantManager: CapturingVariantManager!
    var dialogFactory: CapturingNewTabDaxDialogProvider!
    var specProvider: MockNewTabDialogSpecProvider!
    var hvc: HomeViewController!

    override func setUpWithError() throws {
        let model = CoreDataDatabase.loadModel(from: Bookmarks.bundle, named: "BookmarksModel")!
        let db = CoreDataDatabase(name: "Test", containerLocation: tempDBDir(), model: model)
        variantManager = CapturingVariantManager()
        dialogFactory = CapturingNewTabDaxDialogProvider()
        specProvider = MockNewTabDialogSpecProvider()
        let dataProviders = SyncDataProviders(
            bookmarksDatabase: db,
            secureVaultFactory: AutofillSecureVaultFactory,
            secureVaultErrorReporter: SecureVaultReporter(),
            settingHandlers: [],
            favoritesDisplayModeStorage: MockFavoritesDisplayModeStoring(),
            syncErrorHandler: SyncErrorHandler()
        )
        let dependencies = HomePageDependencies(
            model: Tab(),
            favoritesViewModel: MockFavoritesListInteracting(),
            appSettings: AppSettingsMock(),
            syncService: MockDDGSyncing(authState: .active, isSyncInProgress: false),
            syncDataProviders: dataProviders,
            variantManager: variantManager,
            newTabDialogFactory: dialogFactory,
            newTabDialogTypeProvider: specProvider)
        hvc = HomeViewController.loadFromStoryboard(
            homePageDependecies: dependencies)

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

    func testWhenNewOnboarding_OnViewDidAppear_CorrectTypePassedToDialogFactory() throws {
        // GIVEN
        variantManager.isSupported = true
        let expectedSpec = randomDialogType()
        specProvider.specToReturn = expectedSpec

        // WHEN
        hvc.viewDidAppear(true)

        // THEN
        XCTAssertEqual(self.variantManager.capturedFeatureName?.rawValue, FeatureName.newOnboardingIntro.rawValue)
        XCTAssertFalse(self.specProvider.nextHomeScreenMessageCalled)
        XCTAssertTrue(self.specProvider.nextHomeScreenMessageNewCalled)
        XCTAssertEqual(self.dialogFactory.homeDialog, expectedSpec)
        XCTAssertNotNil(self.dialogFactory.onDismiss)
    }

    func testWhenOldOnboarding_OnViewDidAppear_NothingPassedDialogFactory() throws {
        // GIVEN
        variantManager.isSupported = false

        // WHEN
        hvc.viewDidAppear(true)

        // THEN
        XCTAssertTrue(specProvider.nextHomeScreenMessageCalled)
        XCTAssertFalse(specProvider.nextHomeScreenMessageNewCalled)
        XCTAssertNil(dialogFactory.homeDialog)
        XCTAssertNil(dialogFactory.onDismiss)
    }

    func testWhenNewOnboarding_OnOnboardingComplete_CorrectTypePassedToDialogFactory() throws {
        // GIVEN
        variantManager.isSupported = true
        let expectedSpec = randomDialogType()
        specProvider.specToReturn = expectedSpec

        // WHEN
        hvc.onboardingCompleted()
        
        // THEN
        XCTAssertEqual(self.variantManager.capturedFeatureName?.rawValue, FeatureName.newOnboardingIntro.rawValue)
        XCTAssertFalse(self.specProvider.nextHomeScreenMessageCalled)
        XCTAssertTrue(self.specProvider.nextHomeScreenMessageNewCalled)
        XCTAssertEqual(self.dialogFactory.homeDialog, expectedSpec)
        XCTAssertNotNil(self.dialogFactory.onDismiss)
    }

    func testWhenOldOnboarding_OnOnboardingComplete_NothingPassedDialogFactory() throws {
        // GIVEN
        variantManager.isSupported = false

        // WHEN
        hvc.onboardingCompleted()

        // THEN
        XCTAssertTrue(specProvider.nextHomeScreenMessageCalled)
        XCTAssertFalse(specProvider.nextHomeScreenMessageNewCalled)
        XCTAssertNil(dialogFactory.homeDialog)
        XCTAssertNil(dialogFactory.onDismiss)
    }

    func testWhenNewOnboarding_OnOpenedAsNewTab_CorrectTypePassedToDialogFactory() throws {
        // GIVEN
        variantManager.isSupported = true
        let expectedSpec = randomDialogType()
        specProvider.specToReturn = expectedSpec

        // WHEN
        hvc.openedAsNewTab(allowingKeyboard: true)

        // THEN
        XCTAssertEqual(self.variantManager.capturedFeatureName?.rawValue, FeatureName.newOnboardingIntro.rawValue)
        XCTAssertFalse(self.specProvider.nextHomeScreenMessageCalled)
        XCTAssertTrue(self.specProvider.nextHomeScreenMessageNewCalled)
        XCTAssertEqual(self.dialogFactory.homeDialog, expectedSpec)
        XCTAssertNotNil(self.dialogFactory.onDismiss)
    }

    func testWhenOldOnboarding_OnOpenedAsNewTab_NothingPassedDialogFactory() throws {
        // GIVEN
        variantManager.isSupported = false

        // WHEN
        hvc.openedAsNewTab(allowingKeyboard: true)

        // THEN
        XCTAssertTrue(specProvider.nextHomeScreenMessageCalled)
        XCTAssertFalse(specProvider.nextHomeScreenMessageNewCalled)
        XCTAssertNil(dialogFactory.homeDialog)
        XCTAssertNil(dialogFactory.onDismiss)
    }

    private func randomDialogType() -> DaxDialogs.HomeScreenSpec {
        let specs: [DaxDialogs.HomeScreenSpec] = [.initial, .subsequent, .final, .addFavorite]
        return specs.randomElement()!
    }
}

class CapturingVariantManager: VariantManager {
    var currentVariant: Variant?
    var capturedFeatureName: FeatureName?
    var isSupported = false

    func assignVariantIfNeeded(_ newInstallCompletion: (BrowserServicesKit.VariantManager) -> Void) {
    }

    func isSupported(feature: FeatureName) -> Bool {
        capturedFeatureName = feature
        return isSupported
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
    var specToReturn: DaxDialogs.HomeScreenSpec?

    func nextHomeScreenMessage() -> DaxDialogs.HomeScreenSpec? {
        nextHomeScreenMessageCalled = true
        return specToReturn
    }

    func nextHomeScreenMessageNew() -> DaxDialogs.HomeScreenSpec? {
        nextHomeScreenMessageNewCalled = true
        return specToReturn
    }
}
