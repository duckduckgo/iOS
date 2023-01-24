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
import AVFoundation
import UIKit

class SyncCodeCollectionViewModel: ObservableObject {

    enum VideoPermission {
        case unknown, authorised, denied
    }

    enum State {
        case showScanner, manualEntry, showQRCode
    }

    @Published var scannedCode: String?
    @Published var showCamera = true
    @Published var videoPermission: VideoPermission = .unknown
    @Published var state = State.showScanner
    @Published var manuallyEnteredCode: String?

    var showQRCodeModel: ShowQRCodeViewModel?

    let finished: (SyncCodeCollectionViewModel) -> Void

    init(finished: @escaping (SyncCodeCollectionViewModel) -> Void) {
        self.finished = finished
    }

    func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined {
            Task { @MainActor in
                _ = await AVCaptureDevice.requestAccess(for: .video)
                self.checkCameraPermission()
            }
            return
        }

        switch status {
        case .denied: videoPermission = .denied
        case .authorized: videoPermission = .authorised
        default: assertionFailure("Unexpected status \(status)")
        }
    }

    func codeScanned(_ code: String) {
        print(#function, code)
        scannedCode = code
    }

    func cameraUnavailable() {
        print(#function)
        showCamera = false
    }

    func pasteCode() {
        guard let string = UIPasteboard.general.string else { return }
        self.manuallyEnteredCode = string
    }

    func cancel() {
        print(#function)
        finished(self)
    }

    func createShowQRCodeViewModel() -> ShowQRCodeViewModel {
        #warning("should connect to backend and to use the connect mode for generating a QR Code then update this model")
        let model = ShowQRCodeViewModel()
        showQRCodeModel = model

        Task { @MainActor in
            try await Task.sleep(nanoseconds: 1_000_000_000)
            showQRCodeModel?.codeToDisplay = "display code"
            showQRCodeModel?.codeToShare = "code to share"
        }

        return model
    }

}
