//
//  SyncManagementViewModelTests.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
@testable import SyncUI

/// To be fleshed out when UI is settled
class SyncManagementViewModelTests: XCTestCase, SyncManagementViewModelDelegate {

    fileprivate var monitor = Monitor<SyncManagementViewModelDelegate>()

    lazy var model: SyncSettingsViewModel = {
        let model = SyncSettingsViewModel()
        model.delegate = self
        return model
    }()

    func test_WhenSyncIsNotSetup_AndEnableSyncIsTriggered_ThenManagerBecomesBusy_AndSetupIsShown() {
        model.enableSync()
        XCTAssertTrue(model.isBusy)

        // You can either test one individual call was made x number of times or check for a whole number of calls
        monitor.assert(#selector(showSyncSetup).description, calls: 1)
        monitor.assertCalls([
            #selector(showSyncSetup).description: 1
        ])
    }

    // MARK: Delegate functions

    func showSyncSetup() {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
    }

    func showRecoverData() {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
    }

    func showSyncWithAnotherDevice() {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
    }

    func showDeviceConnected() {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
    }

    func showRecoveryPDF() {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
    }

    func createAccountAndStartSyncing() {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
    }

    func confirmAndDisableSync() async -> Bool {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
        return true
    }

    func confirmAndDeleteAllData() async -> Bool {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
        return true
    }

    func copyCode() {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
    }

    func confirmRemoveDevice(_ device: SyncUI.SyncSettingsViewModel.Device) async -> Bool {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
        return true
    }

}

// MARK: An idea... can be made more public if works out

private class Monitor<T> {

    var functionCalls = [String: Int]()

    /// Whatever is passed as function is used as the key, the same key should be used for assertions.
    ///  Use `String.cleaningFunctionName()` with `#function` but be aware that overloaded function names will not be tracked accurately.
    func incrementCalls(function: String) {
        print(#function, function)
        let calls = functionCalls[function, default: 0] + 1
        functionCalls[function] = calls
    }

    func assert(_ function: String, calls expected: Int, _ file: StaticString = #file, _ line: UInt = #line) {
        print(#function, function)
        let actual = functionCalls[function, default: 0]
        XCTAssertEqual(actual, expected, file: file, line: line)
    }

    func assertCalls(_ calls: [String: Int], _ file: StaticString = #file, _ line: UInt = #line) {
        XCTAssertEqual(calls.count, functionCalls.count, "Different number of function calls", file: file, line: line)
        calls.forEach { entry in
            XCTAssertEqual(calls[entry.key], functionCalls[entry.key],
                           "Unexpected number of calls \(entry.value) for \(entry.key)", file: file, line: line)
        }
    }

}

private extension String {

    func cleaningFunctionName() -> String {
        return self.components(separatedBy: "(")[0]
    }

}
