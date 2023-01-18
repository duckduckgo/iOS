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

class SyncCodeCollectionViewModel: ObservableObject {

    enum VideoPermission {
        case unknown, authorised, denied
    }

    @Published var scannedCode: String?

    var videoPermission: VideoPermission {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined {
            Task { @MainActor in
                _ = await AVCaptureDevice.requestAccess(for: .video)
                self.objectWillChange.send()
            }
            return .unknown
        }

        switch status {
        case .denied: return .denied
        case .authorized: return .authorised
        default: assertionFailure("Unexpected status \(status)")
        }

        // Should never hit here
        return .denied
    }

    func codeScanned(_ code: String) {
        scannedCode = code
    }

}
