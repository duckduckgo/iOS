//
//   ContextualOnboardingNewTabDialogFactoryTests.swift
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
    var mockDelegate: MockOnboardingNavigationDelegate!
    var onDismissCalled: Bool!

    override func setUp() {
        super.setUp()
        mockDelegate = MockOnboardingNavigationDelegate()
        onDismissCalled = false
        factory = NewTabDaxDialogFactory(delegate: mockDelegate) {
            self.onDismissCalled = true
        }
    }

    override func tearDown() {
        factory = nil
        mockDelegate = nil
        onDismissCalled = nil
        super.tearDown()
    }

    func testCreateInitialDialog() {
        // Given
        let homeDialog = DaxDialogs.HomeScreenSpec.initial

        // When
        let view = factory.createDaxDialog(for: homeDialog)

        // Then
        XCTAssertTrue(view is OnboardingTrySearchDialog)
    }

//    func testCreateAddFavoriteDialog() {
//        let homeDialog = DaxDialogs.HomeScreenSpec.addFavorite(message: "Test Message")
//        let view = factory.createDaxDialog(for: homeDialog)
//
//        // Verify the view type
//        XCTAssertTrue(view is AnyView)
//        // Additional type checking if necessary
//    }
//
//    func testCreateSubsequentDialog() {
//        let homeDialog = DaxDialogs.HomeScreenSpec.subsequent
//        let view = factory.createDaxDialog(for: homeDialog)
//
//        // Verify the view type
//        XCTAssertTrue(view is AnyView)
//        // Additional type checking if necessary
//    }
//
//    func testOnDismissCalled() {
//        let homeDialog = DaxDialogs.HomeScreenSpec.subsequent
//        let view = factory.createDaxDialog(for: homeDialog)
//
//        // Since we can't directly simulate the button press, check the onDismiss logic directly
//        factory.onDismiss()
//        XCTAssertTrue(onDismissCalled)
//    }
}

class MockOnboardingNavigationDelegate: OnboardingNavigationDelegate {
    func suggestedSearchPressed(_ query: String) {

    }
    
}
