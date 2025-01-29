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
import Combine
@testable import SyncUI_iOS

/// To be fleshed out when UI is settled
class SyncManagementViewModelTests: XCTestCase, SyncManagementViewModelDelegate {

    fileprivate var monitor = Monitor<SyncManagementViewModelDelegate>()
    var syncBookmarksPausedTitle: String? = "syncBookmarksPausedTitle"
    var syncCredentialsPausedTitle: String? = "syncCredentialsPausedTitle"
    var syncPausedTitle: String? = "syncPausedTitle"
    var syncBookmarksPausedDescription: String? = "syncBookmarksPausedDescription"
    var syncCredentialsPausedDescription: String? = "syncCredentialsPausedDescription"
    var syncPausedDescription: String? = "syncPausedDescription"
    var syncBookmarksPausedButtonTitle: String? = "syncBookmarksPausedButtonTitle"
    var syncCredentialsPausedButtonTitle: String? = "syncCredentialsPausedButtonTitle"

    lazy var model: SyncSettingsViewModel = {
        let model = SyncSettingsViewModel(isOnDevEnvironment: { false }, switchToProdEnvironment: {})
        model.delegate = self
        return model
    }()

    var createAccountAndStartSyncingCalled = false
    var capturedOptionModel: SyncSettingsViewModel?

    func waitForInvocation() {
        let expectation = expectation(description: "Inv")
        let cancellable = monitor.didChange.dropFirst().sink { val in
            print(val)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testViewModelReturnsExpectedStrings() {
        XCTAssertEqual(model.syncBookmarksPausedTitle, syncBookmarksPausedTitle)
        XCTAssertEqual(model.syncCredentialsPausedTitle, syncCredentialsPausedTitle)
        XCTAssertEqual(model.syncPausedTitle, syncPausedTitle)
        XCTAssertEqual(model.syncBookmarksPausedDescription, syncBookmarksPausedDescription)
        XCTAssertEqual(model.syncCredentialsPausedDescription, syncCredentialsPausedDescription)
        XCTAssertEqual(model.syncPausedDescription, syncPausedDescription)
        XCTAssertEqual(model.syncBookmarksPausedButtonTitle, syncBookmarksPausedButtonTitle)
        XCTAssertEqual(model.syncCredentialsPausedButtonTitle, syncCredentialsPausedButtonTitle)
    }

    func testWhenSingleDeviceSetUpPressed_ThenManagerBecomesBusy_AndAccounCreationRequested() {
        model.startSyncPressed()
        XCTAssertTrue(model.isBusy)

        XCTAssertTrue(createAccountAndStartSyncingCalled)
        XCTAssertNotNil(capturedOptionModel)
    }

    func testWhenShowRecoveryPDFPressed_ShowRecoveryPDFIsShown() {
        model.delegate?.showRecoveryPDF()

        // You can either test one individual call was made x number of times or check for a whole number of calls
        monitor.assert(#selector(showRecoveryPDF).description, calls: 1)
        monitor.assertCalls([
            #selector(showRecoveryPDF).description: 1
        ])
    }

    func testWhenScanQRCodePressed_ThenSyncWithAnotherDeviceViewIsShown() {
        model.scanQRCode()
        waitForInvocation()

        // You can either test one individual call was made x number of times or check for a whole number of calls
        // async functions selector description apparently contain 'WithCompletionHandler'
        monitor.assert(#selector(authenticateUser).description.dropping(suffix: "WithCompletionHandler:"), calls: 1)
        monitor.assertCalls([
            #selector(authenticateUser).description.dropping(suffix: "WithCompletionHandler:"): 1,
            #selector(showSyncWithAnotherDevice).description: 1
        ])
    }

    func testWhenCopyCodePressed_CodeIsCopied() {
        model.copyCode()

        // You can either test one individual call was made x number of times or check for a whole number of calls
        monitor.assert(#selector(copyCode).description, calls: 1)
        monitor.assertCalls([
            #selector(copyCode).description: 1
        ])
    }


    func testWhenManageBookmarkPressed_BookmarkVCIsLaunched() {
        model.manageBookmarks()

        // You can either test one individual call was made x number of times or check for a whole number of calls
        monitor.assert(#selector(launchBookmarksViewController).description, calls: 1)
        monitor.assertCalls([
            #selector(launchBookmarksViewController).description: 1
        ])
    }

    func testWhenManageLoginsPressed_LoginsVCIsLaunched() {
        model.manageLogins()

        // You can either test one individual call was made x number of times or check for a whole number of calls
        monitor.assert(#selector(launchAutofillViewController).description, calls: 1)
        monitor.assertCalls([
            #selector(launchAutofillViewController).description: 1
        ])
    }

    func testWhenSaveRecoveryPDFPressed_recoveryMethodShown() {
        model.saveRecoveryPDF()
        waitForInvocation()

        // You can either test one individual call was made x number of times or check for a whole number of calls
        // async functions selector description apparently contain 'WithCompletionHandler'
        monitor.assert(#selector(authenticateUser).description.dropping(suffix: "WithCompletionHandler:"), calls: 1)
        monitor.assertCalls([
            #selector(authenticateUser).description.dropping(suffix: "WithCompletionHandler:"): 1,
            #selector(shareRecoveryPDF).description: 1
        ])
    }

    func testWhenManageBookmarksCalled_BookmarksVCIsLaunched() {
        model.manageBookmarks()

        // You can either test one individual call was made x number of times or check for a whole number of calls
        monitor.assert(#selector(launchBookmarksViewController).description, calls: 1)
        monitor.assertCalls([
            #selector(launchBookmarksViewController).description: 1
        ])
    }

    func testWhenManageLogindCalled_AutofillVCIsLaunched() {
        model.manageLogins()

        // You can either test one individual call was made x number of times or check for a whole number of calls
        monitor.assert(#selector(launchAutofillViewController).description, calls: 1)
        monitor.assertCalls([
            #selector(launchAutofillViewController).description: 1
        ])
    }


    func testWhenRecoverSyncDataPressed_RecoverDataViewShown() {
        model.recoverSyncDataPressed()
        waitForInvocation()

        // You can either test one individual call was made x number of times or check for a whole number of calls
        // async functions selector description apparently contain 'WithCompletionHandler'
        monitor.assert(#selector(authenticateUser).description.dropping(suffix: "WithCompletionHandler:"), calls: 1)
        monitor.assertCalls([
            #selector(authenticateUser).description.dropping(suffix: "WithCompletionHandler:"): 1,
            #selector(showRecoverData).description: 1
        ])
    }
    // MARK: Delegate functions

    func authenticateUser() async throws {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
    }

    func showSyncWithAnotherDeviceEnterText() {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
    }

   func createAccountAndStartSyncing(optionsViewModel: SyncSettingsViewModel) {
        createAccountAndStartSyncingCalled = true
        capturedOptionModel = optionsViewModel
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

    func confirmRemoveDevice(_ device: SyncUI_iOS.SyncSettingsViewModel.Device) async -> Bool {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
        return true
    }

    func shareRecoveryPDF() {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
    }

    func updateDeviceName(_ name: String) {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
    }

    func removeDevice(_ device: SyncSettingsViewModel.Device) {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
    }

    func refreshDevices(clearDevices: Bool) {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
    }

    func updateOptions() {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
    }

    func launchBookmarksViewController() {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
    }

    func launchAutofillViewController() {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
    }

    func showOtherPlatformLinks() {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
    }

    func fireOtherPlatformLinksPixel(event: SyncUI_iOS.SyncSettingsViewModel.PlatformLinksPixelEvent, with source: SyncUI_iOS.SyncSettingsViewModel.PlatformLinksPixelSource) {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
    }

    func shareLink(for url: URL, with message: String, from rect: CGRect) {
        monitor.incrementCalls(function: #function.cleaningFunctionName())
    }


}

// MARK: An idea... can be made more public if works out

private class Monitor<T> {

    public var didChange = PassthroughSubject<Void, Never>()
    var functionCalls = [String: Int]() {
        didSet {
            didChange.send()
        }
    }

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
