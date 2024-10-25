//
//  VideoPlayerViewModelTests.swift
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
import AVFoundation
@testable import DuckDuckGo

final class VideoPlayerViewModelTests: XCTestCase {
    private let fakeURL = URL(string: "https://duckduckgo.com")
    private var sut: VideoPlayerViewModel!
    private var mockPlayer: MockAVQueuePlayer!

    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()
        let url = try XCTUnwrap(fakeURL)
        mockPlayer = .init()
        sut = VideoPlayerViewModel(url: url, loopVideo: false, player: mockPlayer)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    @MainActor
    func testWhenInitWithURLThenPlayerItemIsAssignedToPlayer() throws {
        // GIVEN
        let url = try XCTUnwrap(fakeURL)
        mockPlayer = .init()
        XCTAssertFalse(mockPlayer.didCallReplaceCurrentItem)
        XCTAssertNil(mockPlayer.capturedCurrentItem)

        // WHEN
        sut = VideoPlayerViewModel(url: url, loopVideo: true, player: mockPlayer)

        // THEN
        let asset = try XCTUnwrap(mockPlayer.capturedCurrentItem?.asset as? AVURLAsset)
        XCTAssertTrue(mockPlayer.didCallReplaceCurrentItem)
        XCTAssertEqual(asset.url, url)
    }

    @MainActor
    func testWhenIsLoopingVideoCalledAndLoopVideoIsTrueThenReturnTrue() throws {
        // GIVEN
        let url = try XCTUnwrap(fakeURL)
        mockPlayer = .init()
        sut = VideoPlayerViewModel(url: url, loopVideo: true, player: mockPlayer)

        // WHEN
        let result = sut.isLoopingVideo

        // THEN
        XCTAssertTrue(result)
    }

    @MainActor
    func testWhenIsLoopingVideoCalledAndLoopVideoIsFalseThenReturnFalse() throws {
        // GIVEN
        let url = try XCTUnwrap(fakeURL)
        mockPlayer = .init()
        sut = VideoPlayerViewModel(url: url, loopVideo: false, player: mockPlayer)

        // WHEN
        let result = sut.isLoopingVideo

        // THEN
        XCTAssertFalse(result)
    }

    func testWhenInitThenVideoPlayerConfigurationIsTheOneExpected() throws {
        // THEN
        XCTAssertFalse(mockPlayer.preventsDisplaySleepDuringVideoPlayback)
        XCTAssertFalse(mockPlayer.allowsExternalPlayback)
    }

    @MainActor
    func testWhenPlayIsCalledThenAskPlayerToPlay() {
        // GIVEN
        XCTAssertFalse(mockPlayer.didCallPlay)

        // WHEN
        sut.play()

        // THEN
        XCTAssertTrue(mockPlayer.didCallPlay)
    }

    @MainActor
    func testWhenPauseIsCalledThenAskPlayerToPause() {
        // GIVEN
        XCTAssertFalse(mockPlayer.didCallPause)

        // WHEN
        sut.pause()

        // THEN
        XCTAssertTrue(mockPlayer.didCallPause)
    }

}

final class MockAVQueuePlayer: AVQueuePlayer {
    private(set) var didCallPlay = false
    private(set) var didCallPause = false
    private(set) var didCallReplaceCurrentItem = false
    private(set) var capturedCurrentItem: AVPlayerItem?

    override func replaceCurrentItem(with item: AVPlayerItem?) {
        didCallReplaceCurrentItem = true
        self.capturedCurrentItem = item
    }

    override func play() {
        didCallPlay = true
    }

    override func pause() {
        didCallPause = true
    }
}
