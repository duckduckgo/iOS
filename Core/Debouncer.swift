//
//  Debouncer.swift
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

/// A class that provides a debouncing mechanism.
public final class Debouncer {
    private let runLoop: RunLoop
    private let mode: RunLoop.Mode
    private var timer: Timer?

    /// Initializes a new instance of `Debouncer`.
    ///
    /// - Parameters:
    ///   - runLoop: The `RunLoop` on which the debounced actions will be scheduled. Defaults to the current run loop.
    ///
    ///   - mode: The `RunLoop.Mode` in which the debounced actions will be scheduled. Defaults to `.default`.
    ///
    /// Use `RunLoop.main` for UI-related actions to ensure they run on the main thread.
    public init(runLoop: RunLoop = .current, mode: RunLoop.Mode = .default) {
        self.runLoop = runLoop
        self.mode = mode
    }

    /// Debounces the provided block of code, executing it after a specified time interval elapses.
    /// - Parameters:
    ///   - dueTime: The time interval (in seconds) to wait before executing the block.
    ///   - block: The closure to execute after the due time has passed.
    ///
    /// If `dueTime` is less than or equal to zero, the block is executed immediately.
    public func debounce(for dueTime: TimeInterval, block: @escaping () -> Void) {
        timer?.invalidate()

        guard dueTime > 0 else { return block() }

        let timer = Timer(timeInterval: dueTime, repeats: false, block: { timer in
            guard timer.isValid else { return }
            block()
        })

        runLoop.add(timer, forMode: mode)
        self.timer = timer
    }

    /// Cancels any pending execution of the debounced block.
    public func cancel() {
        timer?.invalidate()
        timer = nil
    }
}
