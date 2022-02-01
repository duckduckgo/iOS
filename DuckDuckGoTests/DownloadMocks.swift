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
    var temporaryFilePath: URL?
    var error: Error?
    var delaySeconds: TimeInterval = 0
    
    override func start() {
        let session = URLSession.shared
        let task = session.downloadTask(with: URL(string: "https://duck.com")!)

        DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) { [self] in
            delegate?.urlSession(session, downloadTask: task, didFinishDownloadingTo: temporaryFilePath!)
            delegate?.urlSession(URLSession.shared, task: task, didCompleteWithError: error)
        }

    }
}

class MockNavigationResponse: WKNavigationResponse {
    var suggestedFileName: String?
    var mimeType: String?
    
    override var response: URLResponse {
        let response = MockURLResponse(url: URL(string: "https://www.duck.com")!,
                        mimeType: mimeType!,
                        expectedContentLength: 1234,
                        textEncodingName: "")
        response.mockFileName = suggestedFileName
        return response
    }
}

struct MockSessionSetup {
    let tmpFinalPath: URL
    let documentsFinalPath: URL
    let session: MockDownloadSession
    let response: MockNavigationResponse
    
    init(mimeType: String, downloadsManager: DownloadsManager, completionDelay: TimeInterval = 0) {
        let tmpName = "MOCK_\(UUID().uuidString).tmp"
        let filename = "\(UUID().uuidString).zip"
        
        response = MockNavigationResponse()
        response.suggestedFileName = filename
        response.mimeType = mimeType
        
        session = MockDownloadSession(DownloadTestsHelper.mockURL)
        session.delaySeconds = completionDelay

        let tmpPath = DownloadTestsHelper.tmpDirectory.appendingPathComponent(tmpName)
        
        tmpFinalPath = DownloadTestsHelper.tmpDirectory.appendingPathComponent(filename)
        documentsFinalPath = DownloadTestsHelper.documentsDirectory.appendingPathComponent(filename)
        
        session.temporaryFilePath = tmpPath
        
        DownloadTestsHelper.createMockFile(on: tmpPath)
    }
}

class MockURLResponse: URLResponse {
    var mockFileName: String?
    
    override var suggestedFilename: String? {
        mockFileName
    }
}
