//
//  RulesCompilationMonitor.swift
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

import Foundation
import Core

final class RulesCompilationMonitor {
    
    private var didReport = false
    private var waitStart: TimeInterval?
    private var waiters = NSMapTable<TabViewController, NSNumber>.init(keyOptions: .weakMemory, valueOptions: .strongMemory)
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillTerminate(_:)),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)
    }
    
    /// Called when a Tab is going  to wait for Content Blocking Rules compilation
    func tabWillWaitForRulesCompilation(_ tab: TabViewController) {
        guard !didReport else { return }

        waiters.setObject(NSNumber(value: true), forKey: tab)
        if waitStart == nil {
            waitStart = CACurrentMediaTime()
        }
    }
    
    /// Called when Rules compilation finishes
    func reportWaitTimeForTabFinishedWaitingForRules(_ tab: TabViewController) async {
        defer { waiters.removeObject(forKey: tab) }
        guard waiters.object(forKey: tab) != nil,
              !didReport,
              let waitStart = waitStart
        else { return }

        await reportWaitTime(CACurrentMediaTime() - waitStart, result: .waitResultSuccess)
    }
    
    /// If Tab is going to close while the rules are still being compiled: report wait time with Tab .closed argument
    func tabWillClose(_ tab: TabViewController) async {
        defer { waiters.removeObject(forKey: tab) }
        guard waiters.object(forKey: tab) != nil,
              !didReport,
              let waitStart = waitStart
        else { return }

        await reportWaitTime(CACurrentMediaTime() - waitStart, result: .waitResultTabClosed)
    }
    
    /// If App is going to close while the rules are still being compiled: report wait time with .quit argument
    @objc func applicationWillTerminate(_: Notification) async {
        guard !didReport,
              waiters.count > 0,
              let waitStart = waitStart
        else { return }

        await reportWaitTime(CACurrentMediaTime() - waitStart, result: .waitResultAppQuit)
    }
    
    private func reportWaitTime(_ waitTime: TimeInterval, result: PixelName) async {
        didReport = true
        await Pixel.fire(pixel: result, withAdditionalParameters: ["waitTime": String(waitTime)])
    }
    
}

private extension Pixel {
    
    static func fire(pixel: PixelName, withAdditionalParameters params: [String: String] = [:]) async {
        return await withCheckedContinuation { continuation in
            fire(pixel: pixel, withAdditionalParameters: params) { _ in
                continuation.resume()
            }
        }
    }
    
    enum CompileRulesWaitTime: String, CustomStringConvertible {
        var description: String { rawValue }

        case noWait = "0"
        case lessThan1s = "1"
        case lessThan5s = "5"
        case lessThan10s = "10"
        case lessThan20s = "20"
        case lessThan40s = "40"
        case more
        
        init(waitTime: TimeInterval) {
            switch waitTime {
            case 0:
                self = .noWait
            case ...1:
                self = .lessThan1s
            case ...5:
                self = .lessThan5s
            case ...10:
                self = .lessThan10s
            case ...20:
                self = .lessThan20s
            case ...40:
                self = .lessThan40s
            default:
                self = .more
            }
        }
    }
    
    enum AppState: String, CustomStringConvertible {
        var description: String { rawValue }

        case onboarding
        case regular
    }
    
}
