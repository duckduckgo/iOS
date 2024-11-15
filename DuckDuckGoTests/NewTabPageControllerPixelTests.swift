//
//  NewTabPageControllerPixelTests.swift
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
import Core
@testable import DuckDuckGo
import SwiftUI

final class NewTabPageControllerPixelTests: XCTestCase {

    override func setUp() {
        super.setUp()

        PixelFiringMock.tearDown()
    }

    override func tearDown() {
        super.tearDown()

        PixelFiringMock.tearDown()
    }

    func testHomeScreenPixelIsFiredOnAppear() {
        let sut = createSUT()
        sut.loadViewIfNeeded()

        sut.viewDidAppear(false)

        let count = PixelFiringMock.allPixelsFired.filter { $0.pixelName == Pixel.Event.homeScreenShown.name }.count

        XCTAssertEqual(count, 1)
    }

    func testHomeScreenPixelIsNotFired_WhenPresentingOtherController() {
        let expectation = XCTestExpectation(description: "View loaded")
        let sut = createSUT()

        let window = UIWindow(frame: UIScreen.main.bounds)
        let presentedVC = UIViewController()
        window.rootViewController = sut
        window.makeKeyAndVisible()
        window.rootViewController?.present(presentedVC, animated: false, completion: nil)

        DispatchQueue.main.async {
            XCTAssertTrue(sut.isViewLoaded)
            XCTAssertTrue(presentedVC.isViewLoaded)
            XCTAssertNotNil(sut.presentedViewController)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)

        sut.viewDidAppear(false)

        let count = PixelFiringMock.allPixelsFired.filter { $0.pixelName == Pixel.Event.homeScreenShown.name }.count

        XCTAssertEqual(count, 0)
    }

    private func createSUT() -> NewTabPageViewController {
        NewTabPageViewController(tab: Tab(),
                                 isNewTabPageCustomizationEnabled: false,
                                 interactionModel: MockFavoritesListInteracting(),
                                 homePageMessagesConfiguration: HomePageMessagesConfigurationMock(homeMessages: []),
                                 variantManager: MockVariantManager(),
                                 newTabDialogFactory: MockDaxDialogFactory(),
                                 newTabDialogTypeProvider: MockNewTabDialogSpecProvider(),
                                 faviconLoader: EmptyFaviconLoading(),
                                 pixelFiring: PixelFiringMock.self)
    }
}

private class MockDaxDialogFactory: NewTabDaxDialogProvider {
    func createDaxDialog(for homeDialog: DaxDialogs.HomeScreenSpec, onDismiss: @escaping () -> Void) -> EmptyView {
        EmptyView()
    }
}
