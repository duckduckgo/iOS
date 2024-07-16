//
//  ContextualOnboardingNewTabDialogFactoryTests.swift
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
import SwiftUI
@testable import DuckDuckGo

class ContextualOnboardingNewTabDialogFactoryTests: XCTestCase {

    var factory: NewTabDaxDialogFactory!
    var mockDelegate: CapturingOnboardingNavigationDelegate!
    var onDismissCalled: Bool!

    override func setUp() {
        super.setUp()
        mockDelegate = CapturingOnboardingNavigationDelegate()
        onDismissCalled = false
        factory = NewTabDaxDialogFactory(delegate: mockDelegate)
    }

    override func tearDown() {
        factory = nil
        mockDelegate = nil
        onDismissCalled = nil
        super.tearDown()
    }

    func testCreateInitialDialogCreatesAnOnboardingTrySearchDialog() {
        // Given
        let homeDialog = DaxDialogs.HomeScreenSpec.initial

        // When
        let view = factory.createDaxDialog(for: homeDialog, onDismiss: {})
        let host = UIHostingController(rootView: view)
        XCTAssertNotNil(host.view)

        // Then
        let trySearchDialog = find(OnboardingTrySearchDialog.self, in: host)
        XCTAssertNotNil(trySearchDialog)
        XCTAssertTrue(trySearchDialog?.viewModel.delegate === mockDelegate)
    }

    func testCreateSubsequentDialogCreatesAnOnboardingTryVisitingSiteDialog() {
        // Given
        let homeDialog = DaxDialogs.HomeScreenSpec.subsequent

        // When
        let view = factory.createDaxDialog(for: homeDialog, onDismiss: {})
        let host = UIHostingController(rootView: view)
        XCTAssertNotNil(host.view)

        // Then
        let trySiteDialog = find(OnboardingTryVisitingSiteDialog.self, in: host)
        XCTAssertNotNil(trySiteDialog)
        XCTAssertTrue(trySiteDialog?.viewModel.delegate === mockDelegate)
    }

    func testCreateFinalDialogCreatesAnOnboardingFinalDialog() {
        // Given
        var onDismissedRun = false
        let homeDialog = DaxDialogs.HomeScreenSpec.final
        let onDimsiss = { onDismissedRun = true }

        // When
        let view = factory.createDaxDialog(for: homeDialog, onDismiss: onDimsiss)
        let host = UIHostingController(rootView: view)
        XCTAssertNotNil(host.view)

        // Then
        let finalDialog = find(OnboardingFinalDialog.self, in: host)
        XCTAssertNotNil(finalDialog)
        finalDialog?.highFiveAction()
        XCTAssertTrue(onDismissedRun)
    }

    func testCreateAddFavoriteDialogCreatesAnContextualDaxDialog() {
        // Given
        let homeDialog = DaxDialogs.HomeScreenSpec.addFavorite

        // When
        let view = factory.createDaxDialog(for: homeDialog, onDismiss: {})
        let host = UIHostingController(rootView: view)
        XCTAssertNotNil(host.view)

        // Then
        let addFavoriteDialog = find(ContextualDaxDialog.self, in: host)
        XCTAssertNotNil(addFavoriteDialog)
        XCTAssertEqual(addFavoriteDialog?.message.string, homeDialog.message)
    }

    private func find<T: View>(_ type: T.Type, in root: Any) -> T? {
        let mirror = Mirror(reflecting: root)
        for child in mirror.children {
            if let view = child.value as? T {
                return view
            }
            if let found = find(type, in: child.value) {
                return found
            }
        }
        return nil
    }
}
