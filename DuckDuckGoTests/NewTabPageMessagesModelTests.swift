//
//  NewTabPageMessagesModelTests.swift
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
import RemoteMessaging
import XCTest

@testable import DuckDuckGo

final class NewTabPageMessagesModelTests: XCTestCase {

    private var messagesConfiguration: HomePageMessagesConfigurationMock!
    private var notificationCenter: NotificationCenter!


    override func setUpWithError() throws {
        messagesConfiguration = HomePageMessagesConfigurationMock(homeMessages: [])
        notificationCenter = NotificationCenter()
    }

    override func tearDownWithError() throws {
        PixelFiringMock.tearDown()
    }

    func testUpdatesOnNotification() {
        let sut = createSUT()

        sut.load()

        XCTAssertTrue(sut.homeMessageViewModels.isEmpty)

        messagesConfiguration.homeMessages = [.placeholder]

        notificationCenter.post(name: RemoteMessagingStore.Notifications.remoteMessagesDidChange,
                                object: nil)

        XCTAssertEqual(sut.homeMessageViewModels.count, 1)
    }

    // MARK: Callbacks

    func testCallsDismissOnClose() throws {
        let sut = createSUT()
        messagesConfiguration.homeMessages = [
            .mockRemote(withType: .small(titleText: "", descriptionText: "")),
        ]
        sut.load()

        let model = try XCTUnwrap(sut.homeMessageViewModels.first)

        model.onDidClose(.close)

        XCTAssertEqual(messagesConfiguration.lastDismissedHomeMessage, messagesConfiguration.homeMessages.first)
    }

    func testCallsDismissOnAction() throws {
        let sut = createSUT()
        messagesConfiguration.homeMessages = [
            .mockRemote(withType: .small(titleText: "", descriptionText: "")),
        ]
        sut.load()

        let model = try XCTUnwrap(sut.homeMessageViewModels.first)

        model.onDidClose(.action(isShare: false))

        XCTAssertEqual(messagesConfiguration.lastDismissedHomeMessage, messagesConfiguration.homeMessages.first)
    }

    func testCallsDismissOnPrimaryAction() throws {
        let sut = createSUT()
        messagesConfiguration.homeMessages = [
            .mockRemote(withType: .small(titleText: "", descriptionText: "")),
        ]
        sut.load()

        let model = try XCTUnwrap(sut.homeMessageViewModels.first)

        model.onDidClose(.primaryAction(isShare: false))

        XCTAssertEqual(messagesConfiguration.lastDismissedHomeMessage, messagesConfiguration.homeMessages.first)
    }

    func testCallsDismissOnSecondaryAction() throws {
        let sut = createSUT()
        messagesConfiguration.homeMessages = [
            .mockRemote(withType: .small(titleText: "", descriptionText: "")),
        ]
        sut.load()

        let model = try XCTUnwrap(sut.homeMessageViewModels.first)

        model.onDidClose(.secondaryAction(isShare: false))

        XCTAssertEqual(messagesConfiguration.lastDismissedHomeMessage, messagesConfiguration.homeMessages.first)
    }

    func testDoesNotCallDismissWhenSharing() throws {
        let sut = createSUT()
        messagesConfiguration.homeMessages = [
            .mockRemote(withType: .small(titleText: "", descriptionText: "")),
        ]
        sut.load()

        let model = try XCTUnwrap(sut.homeMessageViewModels.first)

        model.onDidClose(.action(isShare: true))
        model.onDidClose(.primaryAction(isShare: true))
        model.onDidClose(.secondaryAction(isShare: true))

        XCTAssertNil(messagesConfiguration.lastDismissedHomeMessage)
    }

    // MARK: Pixels

    func testFiresPixelOnClose() throws {
        let sut = createSUT()
        messagesConfiguration.homeMessages = [
            .mockRemote(withType: .small(titleText: "", descriptionText: "")),
        ]
        sut.load()

        let model = try XCTUnwrap(sut.homeMessageViewModels.first)

        model.onDidClose(.close)

        XCTAssertEqual(PixelFiringMock.lastPixel, .remoteMessageDismissed)
        XCTAssertEqual(PixelFiringMock.lastParams, [PixelParameters.message: "foo"])
    }

    func testFiresPixelOnAction() throws {
        let sut = createSUT()
        messagesConfiguration.homeMessages = [
            .mockRemote(withType: .small(titleText: "", descriptionText: "")),
        ]
        sut.load()

        let model = try XCTUnwrap(sut.homeMessageViewModels.first)
        model.onDidClose(.action(isShare: false))

        XCTAssertEqual(PixelFiringMock.lastPixel, .remoteMessageActionClicked)
        XCTAssertEqual(PixelFiringMock.lastParams, [PixelParameters.message: "foo"])
    }

    func testFiresPixelOnPrimaryAction() throws {
        let sut = createSUT()
        messagesConfiguration.homeMessages = [
            .mockRemote(withType: .small(titleText: "", descriptionText: "")),
        ]
        sut.load()

        let model = try XCTUnwrap(sut.homeMessageViewModels.first)
        model.onDidClose(.primaryAction(isShare: false))

        XCTAssertEqual(PixelFiringMock.lastPixel, .remoteMessagePrimaryActionClicked)
        XCTAssertEqual(PixelFiringMock.lastParams, [PixelParameters.message: "foo"])
    }

    func testFiresPixelOnSecondaryAction() throws {
        let sut = createSUT()
        messagesConfiguration.homeMessages = [
            .mockRemote(withType: .small(titleText: "", descriptionText: "")),
        ]
        sut.load()

        let model = try XCTUnwrap(sut.homeMessageViewModels.first)
        model.onDidClose(.secondaryAction(isShare: false))

        XCTAssertEqual(PixelFiringMock.lastPixel, .remoteMessageSecondaryActionClicked)
        XCTAssertEqual(PixelFiringMock.lastParams, [PixelParameters.message: "foo"])
    }

    func testDoesNotFirePixelOnCloseWhenMetricsAreDisabled() throws {
        let sut = createSUT()
        messagesConfiguration.homeMessages = [
            .mockRemote(withType: .small(titleText: "", descriptionText: ""), isMetricsEnabled: false),
        ]
        sut.load()

        let model = try XCTUnwrap(sut.homeMessageViewModels.first)

        model.onDidClose(.close)

        XCTAssertNil(PixelFiringMock.lastPixel)
        XCTAssertNil(PixelFiringMock.lastParams)
    }

    func testDoesNotFirePixelOnActionWhenMetricsAreDisabled() throws {
        let sut = createSUT()
        messagesConfiguration.homeMessages = [
            .mockRemote(withType: .small(titleText: "", descriptionText: ""), isMetricsEnabled: false),
        ]
        sut.load()

        let model = try XCTUnwrap(sut.homeMessageViewModels.first)
        model.onDidClose(.action(isShare: false))

        XCTAssertNil(PixelFiringMock.lastPixel)
        XCTAssertNil(PixelFiringMock.lastParams)
    }

    func testDoesNotFirePixelOnPrimaryActionWhenMetricsAreDisabled() throws {
        let sut = createSUT()
        messagesConfiguration.homeMessages = [
            .mockRemote(withType: .small(titleText: "", descriptionText: ""), isMetricsEnabled: false),
        ]
        sut.load()

        let model = try XCTUnwrap(sut.homeMessageViewModels.first)
        model.onDidClose(.primaryAction(isShare: false))

        XCTAssertNil(PixelFiringMock.lastPixel)
        XCTAssertNil(PixelFiringMock.lastParams)
    }

    func testDoesNotFirePixelOnSecondaryActionWhenMetricsAreDisabled() throws {
        let sut = createSUT()
        messagesConfiguration.homeMessages = [
            .mockRemote(withType: .small(titleText: "", descriptionText: ""), isMetricsEnabled: false),
        ]
        sut.load()

        let model = try XCTUnwrap(sut.homeMessageViewModels.first)
        model.onDidClose(.secondaryAction(isShare: false))

        XCTAssertNil(PixelFiringMock.lastPixel)
        XCTAssertNil(PixelFiringMock.lastParams)
    }

    private func createSUT() -> NewTabPageMessagesModel {
        NewTabPageMessagesModel(homePageMessagesConfiguration: messagesConfiguration,
                                notificationCenter: notificationCenter,
                                pixelFiring: PixelFiringMock.self)
    }
}

private class HomePageMessagesConfigurationMock: HomePageMessagesConfiguration {
    var homeMessages: [HomeMessage]

    init(homeMessages: [HomeMessage]) {
        self.homeMessages = homeMessages
    }

    private(set) var lastAppearedHomeMessage: HomeMessage?
    func didAppear(_ homeMessage: HomeMessage) {
        lastAppearedHomeMessage = homeMessage
    }

    private(set) var lastDismissedHomeMessage: HomeMessage?
    func dismissHomeMessage(_ homeMessage: HomeMessage) {
        lastDismissedHomeMessage = homeMessage
    }

    private(set) var didRefresh: Bool = false
    func refresh() {
        didRefresh = true
    }
}

private extension HomeMessage {
    static func mockRemote(withType type: RemoteMessageModelType, isMetricsEnabled: Bool = true) -> Self {
        HomeMessage.remoteMessage(
            remoteMessage: .init(
                id: "foo",
                content: type,
                matchingRules: [],
                exclusionRules: [],
                isMetricsEnabled: isMetricsEnabled
            )
        )
    }
}
