//
//  WKDownloadSession.swift
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
import WebKit

final class WKDownloadSession: NSObject, DownloadSession {
    weak var download: WKDownload?
    weak var delegate: DownloadSessionDelegate?
    let localURL: URL

    private enum State {
        case initial
        case started
        case finished
        case failed(Error)
    }
    private var state: State = .initial

    var isRunning: Bool {
        switch state {
        case .initial, .started:
            return true
        case .finished, .failed:
            return false
        }
    }

    internal init(_ download: WKDownload) {
        self.download = download
        self.localURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        super.init()

        download.delegate = self
    }

    func start() {
        switch state {
        case .initial:
            state = .started
        case .started:
            break
        case .finished:
            delegate?.downloadSession(self, didFinishWith: .success(localURL))
        case .failed(let error):
            delegate?.downloadSession(self, didFinishWith: .failure(error))
        }
    }

    func cancel() {
        download?.cancel()
    }
    
}

extension WKDownloadSession: WKDownloadDelegate {

    func download(_ download: WKDownload,
                  decideDestinationUsing response: URLResponse,
                  suggestedFilename: String,
                  completionHandler: @escaping (URL?) -> Void) {
        completionHandler(nil)
    }


    func downloadDidFinish(_ download: WKDownload) {
        if case .started = state {
            delegate?.downloadSession(self, didFinishWith: .success(localURL))
        }
        self.state = .finished
    }

    func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        if case .started = state {
            delegate?.downloadSession(self, didFinishWith: .failure(error))
        }
        self.state = .failed(error)
    }

}
