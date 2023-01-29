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

protocol SyncCodeCollectionViewModelDelegate: AnyObject {

    var pasteboardString: String? { get }

    func startConnectMode(_ model: SyncCodeCollectionViewModel) async -> String
    func handleCode(_ model: SyncCodeCollectionViewModel, code: String)
    func cancelled(_ model: SyncCodeCollectionViewModel)

}

class SyncCodeCollectionViewModel: ObservableObject {

    enum VideoPermission {
        case unknown, authorised, denied
    }

    enum State {
        case showScanner, manualEntry, showQRCode
    }

    @Published var showCamera = true
    @Published var videoPermission: VideoPermission = .unknown
    @Published var state = State.showScanner
    @Published var manuallyEnteredCode: String?

    var canSubmitManualCode: Bool {
        manuallyEnteredCode?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    weak var delegate: SyncCodeCollectionViewModelDelegate?

    var showQRCodeModel: ShowQRCodeViewModel?

    let canShowQRCode: Bool

    init(canShowQRCode: Bool) {
        self.canShowQRCode = canShowQRCode
    }

    func codeScanned(_ code: String) {
        print(#function, code)
        delegate?.handleCode(self, code: code)
    }

    func cameraUnavailable() {
        print(#function)
        showCamera = false
    }

    func pasteCode() {
        guard let string = delegate?.pasteboardString else { return }
        self.manuallyEnteredCode = string
    }

    func cancel() {
        print(#function)
        delegate?.cancelled(self)
    }

    func submitAction() {
        print(#function)
        delegate?.handleCode(self, code: manuallyEnteredCode ?? "")
    }

    func startConnectMode() -> ShowQRCodeViewModel {
        let model = ShowQRCodeViewModel()
        showQRCodeModel = model
        Task { @MainActor in
            showQRCodeModel?.code = await delegate?.startConnectMode(self)
        }
        return model
    }

}
