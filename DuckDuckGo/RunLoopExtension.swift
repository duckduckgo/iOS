//
//  RunLoopExtension.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

public extension RunLoop {

    final class ResumeCondition {

        private let lock = NSLock()
        private var receivePorts = [Port]()

        private var _isResolved = false
        var isResolved: Bool {
            lock.lock()
            defer { lock.unlock() }
            return _isResolved
        }

        public init() {
        }

        convenience init(dispatchGroup: DispatchGroup) {
            self.init()
            dispatchGroup.notify(queue: .main) {
                self.resolve()
            }
        }

        func addPort(to runLoop: RunLoop, forMode mode: RunLoop.Mode) -> Port? {
            lock.lock()
            defer { lock.unlock() }
            guard !_isResolved else { return nil }

            let port = Port()
            receivePorts.append(port)
            runLoop.add(port, forMode: mode)

            return port
        }

        public func resolve(mode: RunLoop.Mode = .default) {
            lock.lock()

            assert(!_isResolved)
            _isResolved = true

            let ports = receivePorts

            lock.unlock()

            let sendPort = Port()
            RunLoop.current.add(sendPort, forMode: mode)

            // Send Wake message from current RunLoop port to each running RunLoop
            // Called in reversed order to correctly wake nested RunLoops
            for receivePort in ports.reversed() {
                receivePort.send(before: Date(), components: nil, from: sendPort, reserved: 0)
            }

            RunLoop.current.remove(sendPort, forMode: mode)
        }

    }

    func run(mode: RunLoop.Mode = .default, until condition: ResumeCondition) {
        // Add port to current RunLoop to receive Wake message
        guard let port = condition.addPort(to: self, forMode: mode) else {
            // already resolved
            return
        }

        while !condition.isResolved {
            self.run(mode: mode, before: Date(timeIntervalSinceNow: 1.0))
        }
        self.remove(port, forMode: mode)
    }

}
