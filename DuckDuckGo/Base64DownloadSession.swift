//
//  Base64DownloadSession.swift
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

final class Base64DownloadSession: DownloadSession {
    private var base64: String?
    weak var delegate: DownloadSessionDelegate?
    private(set) var isRunning: Bool = false

    init(base64: String) {
        self.base64 = base64
    }

    func start() {
        guard let base64 = base64 else {
            self.delegate?.downloadSession(self, didFinishWith: .failure(CancellationError()))
            return
        }
        self.isRunning = true
        self.base64 = nil

        DispatchQueue.global().async { [self] in
            do {
                guard let data = Data(base64Encoded: base64) else { throw CocoaError(.fileReadCorruptFile) }
                let localURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

                try data.write(to: localURL)

                DispatchQueue.main.async {
                    self.delegate?.downloadSession(self, didFinishWith: .success(localURL))
                    self.isRunning = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.downloadSession(self, didFinishWith: .failure(error))
                    self.isRunning = false
                }
            }
        }
    }

    func cancel() {
        self.base64 = nil
    }

}
