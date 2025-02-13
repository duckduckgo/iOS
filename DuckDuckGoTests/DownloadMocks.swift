//
//  DownloadMocks.swift
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

@testable import DuckDuckGo

class MockDownloadSession: DownloadSession {
    // swiftlint:disable:next weak_delegate
    var delegate: DuckDuckGo.DownloadSessionDelegate?

    var temporaryFilePath: URL?
    var error: Error?
    var delaySeconds: TimeInterval = 0
    var isRunning: Bool = false

    init(_ url: URL? = nil) {}

    func start() {
        self.isRunning = true
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) { [self] in
            if let error = error {
                delegate?.downloadSession(self, didFinishWith: .failure(error))
            } else {
                delegate?.downloadSession(self, didFinishWith: .success(temporaryFilePath!))
            }
            self.isRunning = false
        }
    }

    func cancel() {
        fatalError("not implemented")
    }
}

class MockNavigationResponse: WKNavigationResponse {
    var url = URL(string: "https://www.duck.com")!
    var suggestedFileName: String?
    var mimeType: String?
    
    override var response: URLResponse {
        let response = MockURLResponse(url: url,
                        mimeType: mimeType!,
                        expectedContentLength: 1234,
                        textEncodingName: "")
        response.mockFileName = suggestedFileName
        return response
    }
}

struct MockSessionSetup {
    let session: MockDownloadSession
    let response: MockNavigationResponse
    
    init(mimeType: String, downloadManager: DownloadManager, completionDelay: TimeInterval = 0, filename: String? = nil) {
        let tmpName = "MOCK_\(UUID().uuidString).tmp"
        
        let file: String
        if let filename = filename {
            file = filename
        } else {
            file = "\(UUID().uuidString).zip"
        }
        
        response = MockNavigationResponse()
        response.suggestedFileName = file
        response.mimeType = mimeType
        
        let downloadTestsHelper = DownloadTestsHelper(downloadsDirectory: downloadManager.downloadsDirectory)
        
        session = MockDownloadSession(downloadTestsHelper.mockURL)
        session.delaySeconds = completionDelay

        let tmpPath = downloadTestsHelper.tmpDirectory.appendingPathComponent(tmpName)
    
        session.temporaryFilePath = tmpPath
        
        downloadTestsHelper.createMockFile(on: tmpPath)
    }
}

class MockURLResponse: URLResponse {
    var mockFileName: String?
    
    override var suggestedFilename: String? {
        mockFileName
    }
}
