//
//  TimerInterface.swift
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

public protocol TimerInterface: AnyObject {
    var isValid: Bool { get }
    func invalidate()
    func fire()
}

extension Timer: TimerInterface {}

public protocol TimerCreating: AnyObject {
    func makeTimer(withTimeInterval interval: TimeInterval, repeats: Bool, on runLoop: RunLoop, block: @escaping @Sendable (TimerInterface) -> Void) -> TimerInterface
}

public extension TimerCreating {

    func makeTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping @Sendable (TimerInterface) -> Void) -> TimerInterface {
        makeTimer(withTimeInterval: interval, repeats: repeats, on: .main, block: block)
    }

}

public final class TimerFactory: TimerCreating {

    public init() {}

    public func makeTimer(withTimeInterval interval: TimeInterval, repeats: Bool, on runLoop: RunLoop, block: @escaping @Sendable (TimerInterface) -> Void) -> TimerInterface {
        let timer = Timer(timeInterval: interval, repeats: repeats, block: block)
        runLoop.add(timer, forMode: .common)
        return timer
    }

}
