//
//  FavoritesListInteractingAdapterTests.swift
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
import Combine
import Bookmarks

@testable import DuckDuckGo

final class FavoritesListInteractingAdapterTests: XCTestCase {

    private var favoritesListInteracting: MockFavoritesListInteracting!
    private var appSettings: AppSettingsMock!

    private var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        favoritesListInteracting = MockFavoritesListInteracting()
        appSettings = AppSettingsMock()
    }

    override func tearDownWithError() throws {
        cancellables.removeAll()
    }

    func testPublishesUpdateWhenFavoritesDisplayModeChanges() {
        let expectation = XCTestExpectation(description: #function)
        let sut = createSUT()

        sut.externalUpdates.sink {
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        .store(in: &cancellables)

        NotificationCenter.default.post(name: AppUserDefaults.Notifications.favoritesDisplayModeChange, object: nil)

        wait(for: [expectation], timeout: 1.0)
    }

    func testPublishesUpdateOnExternalListUpdate() {
        let expectation = XCTestExpectation(description: #function)
        let publisher = PassthroughSubject<Void, Never>()
        favoritesListInteracting.externalUpdates = publisher.eraseToAnyPublisher()

        let sut = createSUT()

        sut.externalUpdates.sink {
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        .store(in: &cancellables)

        publisher.send()

        wait(for: [expectation], timeout: 1.0)
    }

    private func createSUT() -> FavoritesListInteractingAdapter {
        return FavoritesListInteractingAdapter(favoritesListInteracting: favoritesListInteracting, appSettings: appSettings)
    }
}

private class FavoritesListInteractingMock: FavoritesListInteracting {
    var favoritesDisplayMode: Bookmarks.FavoritesDisplayMode = .displayNative(.mobile)
    var favorites: [Bookmarks.BookmarkEntity] = []
    func favorite(at index: Int) -> Bookmarks.BookmarkEntity? {
        return nil
    }
    func removeFavorite(_ favorite: Bookmarks.BookmarkEntity) {}
    func moveFavorite(_ favorite: Bookmarks.BookmarkEntity, fromIndex: Int, toIndex: Int) {    }
    var externalUpdates: AnyPublisher<Void, Never> = PassthroughSubject<Void, Never>().eraseToAnyPublisher()
    var localUpdates: AnyPublisher<Void, Never> = PassthroughSubject<Void, Never>().eraseToAnyPublisher()
    func reloadData() {}
}
