//
//  MockTimer.swift
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

import Foundation
@testable import Core

final class MockTimer: TimerInterface {
    var isValid: Bool = true
    private(set) var didCallInvalidate = false

    let timeInterval: TimeInterval
    let repeats: Bool
    private let block: (TimerInterface) -> Void

    init(timeInterval: TimeInterval, repeats: Bool, block: @escaping (TimerInterface) -> Void) {
        self.timeInterval = timeInterval
        self.repeats = repeats
        self.block = block
    }

    func invalidate() {
        didCallInvalidate = true
    }

    func fire() {
        block(self)
    }
}

final class MockTimerFactory: TimerCreating {
    private(set) var didCallMakeTimer = false
    private(set) var capturedInterval: TimeInterval?
    private(set) var capturedRepeats: Bool?

    private(set) var createdTimer: MockTimer?

    func makeTimer(withTimeInterval interval: TimeInterval, repeats: Bool, on runLoop: RunLoop, block: @escaping @Sendable (TimerInterface) -> Void) -> TimerInterface {
        didCallMakeTimer = true
        capturedInterval = interval
        capturedRepeats = repeats

        let timer = MockTimer(timeInterval: interval, repeats: repeats, block: block)
        createdTimer = timer
        return timer
    }

}
