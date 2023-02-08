//
//  SyncCodeCollectionViewModel.swift
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

public protocol SyncCodeCollectionViewModelDelegate: AnyObject {

    var pasteboardString: String? { get }

    func startConnectMode(_ model: SyncCodeCollectionViewModel) async -> String?

    /// Returns true if the code is valid format and should stop scanning
    func handleCode(_ model: SyncCodeCollectionViewModel, code: String) -> Bool
    func cancelled(_ model: SyncCodeCollectionViewModel)
    func gotoSettings(_ model: SyncCodeCollectionViewModel)

}

public class SyncCodeCollectionViewModel: ObservableObject {

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
    @Published var codeError: String?

    var canSubmitManualCode: Bool {
        manuallyEnteredCode?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    public weak var delegate: SyncCodeCollectionViewModelDelegate?

    var showQRCodeModel: ShowQRCodeViewModel?

    let canShowQRCode: Bool

    public init(canShowQRCode: Bool) {
        self.canShowQRCode = canShowQRCode
    }

    func codeScanned(_ code: String) -> Bool {
        return delegate?.handleCode(self, code: code) ?? false
    }

    func cameraUnavailable() {
        showCamera = false
    }

    func pasteCode() {
        guard let string = delegate?.pasteboardString else { return }
        self.manuallyEnteredCode = string
        isValidating = true

        Task { @MainActor in

            if #available(iOS 16.0, *) {
                try await Task.sleep(for: .seconds(4))
            }

            // Tidy this up when wiring up to the backend
            if manuallyEnteredCode == "wrong" {
                isValidating = false
                codeError = "Invalid code"
            } else if let code = manuallyEnteredCode {
                isValidating = false
                _ = delegate?.handleCode(self, code: code)
            }
        }

    }

    func cancel() {
        delegate?.cancelled(self)
    }

    func submitAction() {
        // what to do here??
        _ = delegate?.handleCode(self, code: manuallyEnteredCode ?? "")
    }

    func startConnectMode() -> ShowQRCodeViewModel {
        let model = ShowQRCodeViewModel()
        showQRCodeModel = model
        Task { @MainActor in
            showQRCodeModel?.code = await delegate?.startConnectMode(self)
        }
        return model
    }

    func gotoSettings() {
        delegate?.gotoSettings(self)
    }

}
