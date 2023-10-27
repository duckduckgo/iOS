//
//  BarsAnimatorTests.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

class BarsAnimatorTests: XCTestCase {

    func testDidStartScrollingUpdatesPositionCorrectly() {
        let (sut, delegate) = makeSUT()
        let scrollView = mockScrollView()
        let initialYposition = sut.draggingStartPosY

        scrollView.contentOffset.y = -100
        sut.didStartScrolling(in: scrollView)

        XCTAssertEqual(initialYposition, 0.0)
        XCTAssertEqual(sut.draggingStartPosY, -100)

        XCTAssertEqual(delegate.receivedMessages, [])
    }

    func testBarStateRevealedWhenScrollDownUpdatesToHiddenState() {
        let (sut, delegate) = makeSUT()
        let scrollView = mockScrollView()

        scrollView.contentOffset.y = 100
        sut.didStartScrolling(in: scrollView)
        XCTAssertEqual(sut.barsState, .revealed)

        scrollView.contentOffset.y = 200
        sut.didScroll(in: scrollView)
        XCTAssertEqual(sut.barsState, .transitioning)

        scrollView.contentOffset.y = 300
        sut.didScroll(in: scrollView)
        XCTAssertEqual(sut.barsState, .hidden)

        XCTAssertEqual(delegate.receivedMessages, [.setBarsVisibility(0.0),
                                                   .setBarsVisibility(0.0)])
    }

    func testBarStateHiddenWhenScrollDownKeepsHiddenState() {
        let (sut, delegate) = makeSUT()
        let scrollView = mockScrollView()

        scrollView.contentOffset.y = 100
        sut.didStartScrolling(in: scrollView)
        XCTAssertEqual(sut.barsState, .revealed)

        scrollView.contentOffset.y = 200
        sut.didScroll(in: scrollView)
        XCTAssertEqual(sut.barsState, .transitioning)

        scrollView.contentOffset.y = 300
        sut.didScroll(in: scrollView)
        XCTAssertEqual(sut.barsState, .hidden)

        scrollView.contentOffset.y = 100
        sut.didScroll(in: scrollView)
        XCTAssertEqual(sut.barsState, .hidden)

        XCTAssertEqual(delegate.receivedMessages, [.setBarsVisibility(0.0),
                                                   .setBarsVisibility(0.0)])
    }

    func testBarStateHiddenWhenScrollUpUpdatesToRevealedState() {
        let (sut, delegate) = makeSUT()
        let scrollView = mockScrollView()

        scrollView.contentOffset.y = 100
        sut.didStartScrolling(in: scrollView)
        XCTAssertEqual(sut.barsState, .revealed)

        scrollView.contentOffset.y = 200
        sut.didScroll(in: scrollView)
        XCTAssertEqual(sut.barsState, .transitioning)

        scrollView.contentOffset.y = 400
        sut.didScroll(in: scrollView)
        XCTAssertEqual(sut.barsState, .hidden)

        scrollView.contentOffset.y = -100
        sut.didStartScrolling(in: scrollView)
        sut.didScroll(in: scrollView)
        XCTAssertEqual(sut.barsState, .transitioning)

        scrollView.contentOffset.y = -150
        sut.didScroll(in: scrollView)
        XCTAssertEqual(sut.barsState, .revealed)

        XCTAssertEqual(delegate.receivedMessages, [.setBarsVisibility(0.0),
                                                   .setBarsVisibility(0.0),
                                                   .setBarsVisibility(1.0),
                                                   .setBarsVisibility(1.0)])
    }

    func testBarStateRevealedWhenScrollUpDoNotChangeCurrentState() {
        let (sut, delegate) = makeSUT()
        let scrollView = mockScrollView()

        scrollView.contentOffset.y = 100
        sut.didStartScrolling(in: scrollView)
        XCTAssertEqual(sut.barsState, .revealed)

        scrollView.contentOffset.y = 50
        sut.didScroll(in: scrollView)
        XCTAssertEqual(sut.barsState, .revealed)

        scrollView.contentOffset.y = -50
        sut.didScroll(in: scrollView)
        XCTAssertEqual(sut.barsState, .revealed)

        XCTAssertEqual(delegate.receivedMessages, [])
    }
}

// MARK: - Helpers

private func makeSUT() -> (sut: BarsAnimator, delegate: BrowserChromeDelegateMock) {
    let sut = BarsAnimator()
    let delegate = BrowserChromeDelegateMock()
    sut.delegate = delegate

    return (sut, delegate)
}

private func mockScrollView() -> UIScrollView {
    let scrollView = UIScrollView()
    scrollView.contentSize = .init(width: 300, height: 600)
    scrollView.bounds = .init(x: 0, y: 0, width: 300, height: 300)

    return scrollView
}

private class BrowserChromeDelegateMock: BrowserChromeDelegate {
    enum Message: Equatable {
        case setBarsHidden(Bool)
        case setNavigationBarHidden(Bool)
        case setBarsVisibility(CGFloat)
    }

    var receivedMessages: [Message] = []

    func setBarsHidden(_ hidden: Bool, animated: Bool) {
        receivedMessages.append(.setBarsHidden(hidden))
    }

    func setNavigationBarHidden(_ hidden: Bool) {
        receivedMessages.append(.setNavigationBarHidden(hidden))
    }

    func setBarsVisibility(_ percent: CGFloat, animated: Bool) {
        receivedMessages.append(.setBarsVisibility(percent))
    }

    var canHideBars: Bool = false

    var isToolbarHidden: Bool = false

    var toolbarHeight: CGFloat = 0.0

    var barsMaxHeight: CGFloat = 30

    var omniBar: OmniBar = OmniBar(frame: CGRect(x: 0, y: 0, width: 300, height: 30))

    var tabBarContainer: UIView = UIView()
}
