//
//  AnimatableTypingTextModelTests.swift
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
@testable import DuckDuckGo

final class AnimatableTypingTextModelTests: XCTestCase {
    private var factoryMock: MockTimerFactory!
    private var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()

        factoryMock = MockTimerFactory()
        cancellables = []
    }

    override func tearDownWithError() throws {
        factoryMock = nil
        cancellables = nil
        try super.tearDownWithError()
    }

    func testWhenStartAnimatingIsCalledThenTimerIsStarted() {
        // GIVEN
        let sut = AnimatableTypingTextModel(text: "Hello World!!!", onTypingFinished: nil, timerFactory: factoryMock)
        XCTAssertFalse(factoryMock.didCallMakeTimer)
        XCTAssertNil(factoryMock.capturedInterval)
        XCTAssertNil(factoryMock.capturedRepeats)

        // WHEN
        sut.startAnimating()

        // THEN
        XCTAssertTrue(factoryMock.didCallMakeTimer)
        XCTAssertEqual(factoryMock.capturedInterval, 0.02)
        XCTAssertEqual(factoryMock.capturedRepeats, true)
    }

    func testWhenStopAnimatingIsCalledThenTimerIsInvalidate() throws {
        // GIVEN
        let sut = AnimatableTypingTextModel(text: "Hello World!!!", onTypingFinished: nil, timerFactory: factoryMock)
        sut.startAnimating()
        let timerMock = try XCTUnwrap(factoryMock.createdTimer)
        XCTAssertFalse(timerMock.didCallInvalidate)

        // WHEN
        sut.stopAnimating()

        // THEN
        XCTAssertTrue(timerMock.didCallInvalidate)
    }

    func testWhenTimerFiresThenTypedTextIsPublished_iOS15() throws {
        // GIVEN
        let text = "Hello World!!!"
        var typedText: NSAttributedString = .init(string: "")
        let sut = AnimatableTypingTextModel(text: text, onTypingFinished: nil, timerFactory: factoryMock)
        sut.startAnimating()
        let timerMock = try XCTUnwrap(factoryMock.createdTimer)
        sut.$typedAttributedText
            .dropFirst()
            .sink { attributedString in
                typedText = attributedString
            }
            .store(in: &cancellables)
        XCTAssertTrue(typedText.string.isEmpty)

        for i in 0 ..< text.count {
            // WHEN
            timerMock.fire()
            
            // THEN checks that the right character doesn't have clear color applied but the rest of the string has
            XCTAssertTrue(assertTypedChar(forTypedText: typedText, at: i))
        }
    }

    func testWhenStopAnimatingIsCalledThenWholeTextIsPublished_iOS15() throws {
        // GIVEN
        let text = "Hello World!!!"
        var typedText: NSAttributedString = .init(string: "")
        let sut = AnimatableTypingTextModel(text: text, onTypingFinished: nil, timerFactory: factoryMock)
        sut.startAnimating()
        let timerMock = try XCTUnwrap(factoryMock.createdTimer)
        sut.$typedAttributedText
            .dropFirst()
            .sink { attributedString in
                typedText = attributedString
            }
            .store(in: &cancellables)
        XCTAssertTrue(typedText.string.isEmpty)
        timerMock.fire()

        // WHEN
        sut.stopAnimating()

        // THEN the string does not have any clear character
        XCTAssertEqual(typedText.string, text)
        let attributes = typedText.attributes(at: 0, effectiveRange: nil)
        let foregroundcColor = attributes[.foregroundColor] as? UIColor
        XCTAssertNil(foregroundcColor)
    }

    func testWhenTimerFiresLastCharOfTextThenTimerIsInvalidated() throws {
        // GIVEN
        let text = "Hello World!!!"
        let sut = AnimatableTypingTextModel(text: text, onTypingFinished: nil, timerFactory: factoryMock)
        sut.startAnimating()
        let timerMock = try XCTUnwrap(factoryMock.createdTimer)
        XCTAssertFalse(timerMock.didCallInvalidate)

        // WHEN
        text.forEach { _ in
            timerMock.fire()
        }
        timerMock.fire() // Simulate timer firing after whole text shown

        // THEN
        XCTAssertTrue(timerMock.didCallInvalidate)
    }

    func testWhenTimerFinishesThenOnTypingFinishedBlockIsCalled() throws {
        // GIVEN
        let expectation = self.expectation(description: #function)
        let text = "Hello World!!!"
        let sut = AnimatableTypingTextModel(text: text, onTypingFinished: { expectation.fulfill() }, timerFactory: factoryMock)
        sut.startAnimating()
        let timerMock = try XCTUnwrap(factoryMock.createdTimer)

        // WHEN
        text.forEach { _ in
            timerMock.fire()
        }
        timerMock.fire() // Simulate timer firing after whole text shown

        // THEN
        waitForExpectations(timeout: 2.0)
    }

}

private extension AnimatableTypingTextModelTests {

    func assertTypedChar(forTypedText typedText: NSAttributedString, at position: Int) -> Bool {
        let typedTextAttribute = typedText.attribute(.foregroundColor, at: position, effectiveRange: nil)

        let location = position + 1

        // If it's the last char just check the currenct character as there's no remaining string to check
        guard location < typedText.length else {
            return typedTextAttribute == nil
        }

        // Checks that the remaining substring has a clear color
        let remainingTextRange = NSRange(location: location, length: typedText.string.count)
        let remainingTextAttributes = typedText.attributes(at: location, longestEffectiveRange: nil, in: remainingTextRange)
        let remainingTextForegroundColor = remainingTextAttributes[.foregroundColor] as? UIColor

        return typedTextAttribute == nil &&
            remainingTextForegroundColor == .clear
    }

}
