//
//  ScanOrPasteCodeViewModel.swift
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

import Foundation

public protocol ScanOrPasteCodeViewModelDelegate: AnyObject {

    var pasteboardString: String? { get }

    func startConnectMode() async -> String?
    func endConnectMode()

    /// Returns true if we were able to use the code. Either way, stop validating.
    func syncCodeEntered(code: String) async -> Bool

    func codeCollectionCancelled()
    func gotoSettings()

}

public class ScanOrPasteCodeViewModel: ObservableObject {

    public enum VideoPermission {
        case unknown, authorised, denied
    }

    public enum State {
        case showScanner, manualEntry, showQRCode
    }

    public enum StartConnectModeResult {
        case authorised(code: String), denied, failed
    }

    @Published public var videoPermission: VideoPermission = .unknown

    @Published var showCamera = true
    @Published var state = State.showScanner
    @Published var manuallyEnteredCode: String?
    @Published var isValidating = false
    @Published var invalidCode = false

    var canSubmitManualCode: Bool {
        manuallyEnteredCode?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    public weak var delegate: ScanOrPasteCodeViewModelDelegate?

    var showQRCodeModel: ShowQRCodeViewModel?

    let isInRecoveryMode: Bool

    public init(isInRecoveryMode: Bool) {
        self.isInRecoveryMode = isInRecoveryMode
    }

    func codeScanned(_ code: String) async -> Bool {
        return await delegate?.syncCodeEntered(code: code) == true
    }

    func cameraUnavailable() {
        showCamera = false
    }

    func pasteCode() {
        guard let string = delegate?
            .pasteboardString?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "") else { return }
        
        self.manuallyEnteredCode = string
        invalidCode = false
        isValidating = true

        Task { @MainActor in
            let codeUsed = await delegate?.syncCodeEntered(code: string) == true
            isValidating = false
            if !codeUsed {
                invalidCode = true
            }
        }

    }

    func cancel() {
        delegate?.codeCollectionCancelled()
    }

    func startConnectMode() -> ShowQRCodeViewModel {
        let model = ShowQRCodeViewModel()
        showQRCodeModel = model
        Task { @MainActor in
            showQRCodeModel?.code = await delegate?.startConnectMode()
        }
        return model
    }

    func endConnectMode() {
        self.delegate?.endConnectMode()
    }

    func gotoSettings() {
        delegate?.gotoSettings()
    }

}
