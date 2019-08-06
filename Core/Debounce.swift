//
//  Debounce.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

public class Debounce {
    
    private let queue: DispatchQueue
    private let interval: TimeInterval
    
    private var currentWorkItem = DispatchWorkItem(block: {})
    
    public init(queue: DispatchQueue, seconds: TimeInterval) {
        self.queue = queue
        self.interval = seconds
    }
    
    public func schedule(_ block: @escaping (() -> Void)) {
        currentWorkItem.cancel()
        currentWorkItem = DispatchWorkItem(block: { block() })
        queue.asyncAfter(deadline: .now() + interval, execute: currentWorkItem)
    }
}
