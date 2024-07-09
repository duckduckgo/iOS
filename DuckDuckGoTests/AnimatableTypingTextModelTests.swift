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
        let sut = AnimatableTypingTextModel(text: NSAttributedString(string: "Hello World!!!"), onTypingFinished: nil, timerFactory: factoryMock)
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
        let sut = AnimatableTypingTextModel(text: NSAttributedString(string: "Hello World!!!"), onTypingFinished: nil, timerFactory: factoryMock)
        sut.startAnimating()
        let timerMock = try XCTUnwrap(factoryMock.createdTimer)
        XCTAssertFalse(timerMock.didCallInvalidate)

        // WHEN
        sut.stopAnimating()

        // THEN
        XCTAssertTrue(timerMock.didCallInvalidate)
    }

    func testWhenTimerFiresThenTypedTextIsPublished_iOS15() throws {
        guard #available(iOS 15, *) else {
            throw XCTSkip("Test available only on iOS 15*")
        }

        // GIVEN
        let text = NSAttributedString(string: "Hello World!!!")
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

        for i in 0 ..< text.length {
            // WHEN
            timerMock.fire()

            // THEN
            XCTAssertTrue(isAttributedStringColorsCorrect(typedText, visibleLength: i + 1))
        }
    }

    func testWhenStopAnimatingIsCalledThenWholeTextIsPublished_iOS15() throws {
        guard #available(iOS 15, *) else {
            throw XCTSkip("Test available only on iOS 15*")
        }

        // GIVEN
        let text = NSAttributedString(string: "Hello World!!!")
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
        XCTAssertEqual(typedText, text)
        let attributes = typedText.attributes(at: 0, effectiveRange: nil)
        let foregroundcColor = attributes[.foregroundColor] as? UIColor
        XCTAssertNil(foregroundcColor)
    }

    func testWhenTimerFiresLastCharOfTextThenTimerIsInvalidated() throws {
        // GIVEN
        let text = NSAttributedString(string: "Hello World!!!")
        let sut = AnimatableTypingTextModel(text: text, onTypingFinished: nil, timerFactory: factoryMock)
        sut.startAnimating()
        let timerMock = try XCTUnwrap(factoryMock.createdTimer)
        XCTAssertFalse(timerMock.didCallInvalidate)

        // WHEN
        text.string.forEach { _ in
            timerMock.fire()
        }
        timerMock.fire() // Simulate timer firing after whole text shown

        // THEN
        XCTAssertTrue(timerMock.didCallInvalidate)
    }

    func testWhenTimerFinishesThenOnTypingFinishedBlockIsCalled() throws {
        // GIVEN
        let expectation = self.expectation(description: #function)
        let text = NSAttributedString(string: "Hello World!!!")
        let sut = AnimatableTypingTextModel(text: text, onTypingFinished: { expectation.fulfill() }, timerFactory: factoryMock)
        sut.startAnimating()
        let timerMock = try XCTUnwrap(factoryMock.createdTimer)

        // WHEN
        text.string.forEach { _ in
            timerMock.fire()
        }
        timerMock.fire() // Simulate timer firing after whole text shown

        // THEN
        waitForExpectations(timeout: 2.0)
    }

}

private extension AnimatableTypingTextModelTests {

    func isAttributedStringColorsCorrect(_ attributedString: NSAttributedString, visibleLength: Int) -> Bool {
        var isCorrect = true
        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.enumerateAttribute(.foregroundColor, in: range, options: []) { value, range, _ in
            guard let color = value as? UIColor else {
                isCorrect = false
                return
            }
            if range.location < visibleLength {
                if color != .label {
                    isCorrect = false
                }
            } else {
                if color != .clear {
                    isCorrect = false
                }
            }
        }
        return isCorrect
    }

}
