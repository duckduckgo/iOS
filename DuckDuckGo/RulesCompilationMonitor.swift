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
    
    static let shared = RulesCompilationMonitor()
    
    private var didReport = false
    private var waitStart: TimeInterval?
    private var waiters: [AnyHashable: Bool] = [:]
    
    private init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillTerminate(_:)),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)
    }
    
    /// Called when a Tab is going  to wait for Content Blocking Rules compilation
    func tabWillWaitForRulesCompilation(_ tabIdentifier: AnyHashable) {
        guard !didReport else { return }

        waiters[tabIdentifier] = true
        if waitStart == nil {
            waitStart = CACurrentMediaTime()
        }
    }
    
    /// Called when Rules compilation finishes
    func reportTabFinishedWaitingForRules(_ tabIdentifier: AnyHashable) {
        defer { waiters[tabIdentifier] = nil }
        guard waiters[tabIdentifier] != nil,
              !didReport,
              let waitStart = waitStart
        else { return }

        reportWaitTime(CACurrentMediaTime() - waitStart, result: .success)
    }
    
    func reportNavigationDidNotWaitForRules() {
        guard !didReport else { return }
        reportWaitTime(0, result: .success)
    }
    
    /// If Tab is going to close while the rules are still being compiled: report wait time with Tab .closed argument
    func tabWillClose(_ tabIdentifier: AnyHashable) {
        defer { waiters[tabIdentifier] = nil }
        guard waiters[tabIdentifier] != nil,
              !didReport,
              let waitStart = waitStart
        else { return }

        reportWaitTime(CACurrentMediaTime() - waitStart, result: .tabClosed)
    }
    
    /// If App is going to close while the rules are still being compiled: report wait time with .quit argument
    @objc func applicationWillTerminate(_: Notification) {
        guard !didReport,
              waiters.count > 0,
              let waitStart = waitStart
        else { return }

        reportWaitTime(CACurrentMediaTime() - waitStart, result: .appQuit)
    }
    
    private func reportWaitTime(_ waitTime: TimeInterval, result: Pixel.Event.CompileRulesResult) {
        didReport = true
        Pixel.fire(pixel: .compilationResult(result: result,
                                             waitTime: Pixel.Event.CompileRulesWaitTime(waitTime: waitTime),
                                             appState: .regular),
                   withAdditionalParameters: ["waitTime": String(waitTime)])
    }
    
}
