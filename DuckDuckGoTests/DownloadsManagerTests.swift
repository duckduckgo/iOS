//
//  DownloadsManagerTests.swift
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

import XCTest
import WebKit

@testable import DuckDuckGo

private struct MockSessionSetup {
    let tmpFinalPath: URL
    let documentsFinalPath: URL
    let session: MockDownloadSession
    let response: MockNavigationResponse
    
    init(mimeType: String, downloadsManager: DownloadsManager) {
        let tmpName = "MOCK_\(UUID().uuidString).tmp"
        let filename = "\(UUID().uuidString).zip"
        
        response = MockNavigationResponse()
        response.suggestedFileName = filename
        response.mimeType = mimeType
        
        session = MockDownloadSession(DownloadTestsHelper.mockURL)

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

class DownloadsManagerTests: XCTestCase {
    var mockDependencyProvider: MockDependencyProvider!
    
    override func setUp() {
        mockDependencyProvider = MockDependencyProvider()
        AppDependencyProvider.shared = mockDependencyProvider
    }
    
    override func tearDown() {
        AppDependencyProvider.shared = AppDependencyProvider()
        DownloadTestsHelper.deleteAllFiles()
    }

    func testTemporaryPKPassDownload() {
        let downloadsManager = mockDependencyProvider.downloadsManager

        let sessionSetup = MockSessionSetup(mimeType: "application/vnd.apple.pkpass", downloadsManager: downloadsManager)
    
        let download = downloadsManager.setupDownload(sessionSetup.response, downloadSession: sessionSetup.session)!
        XCTAssertTrue(download.temporary, "Download should be temporary")
        
        downloadsManager.startDownload(download)
        
        XCTAssertTrue(DownloadTestsHelper.checkIfFileExists(sessionSetup.tmpFinalPath), "File should exist")
        XCTAssertFalse(DownloadTestsHelper.checkIfFileExists(sessionSetup.documentsFinalPath), "File should not exist")
    }
    
    func testTemporaryRealityDownload() {
        let downloadsManager = mockDependencyProvider.downloadsManager

        let sessionSetup = MockSessionSetup(mimeType: "model/vnd.reality", downloadsManager: downloadsManager)
    
        let download = downloadsManager.setupDownload(sessionSetup.response, downloadSession: sessionSetup.session)!
        XCTAssertTrue(download.temporary, "Download should be temporary")
        
        downloadsManager.startDownload(download)
        
        XCTAssertTrue(DownloadTestsHelper.checkIfFileExists(sessionSetup.tmpFinalPath), "File should exist")
        XCTAssertFalse(DownloadTestsHelper.checkIfFileExists(sessionSetup.documentsFinalPath), "File should not exist")
    }
    
    func testTemporaryUSDZDownload() {
        let downloadsManager = mockDependencyProvider.downloadsManager

        let sessionSetup = MockSessionSetup(mimeType: "model/vnd.usdz+zip", downloadsManager: downloadsManager)
    
        let download = downloadsManager.setupDownload(sessionSetup.response, downloadSession: sessionSetup.session)!
        XCTAssertTrue(download.temporary, "Download should be temporary")
        
        downloadsManager.startDownload(download)
        
        XCTAssertTrue(DownloadTestsHelper.checkIfFileExists(sessionSetup.tmpFinalPath), "File should exist")
        XCTAssertFalse(DownloadTestsHelper.checkIfFileExists(sessionSetup.documentsFinalPath), "File should not exist")
    }

    func testPermanentBinaryDownload() {
        let downloadsManager = mockDependencyProvider.downloadsManager

        let sessionSetup = MockSessionSetup(mimeType: "application/octet-stream", downloadsManager: downloadsManager)
    
        let download = downloadsManager.setupDownload(sessionSetup.response, downloadSession: sessionSetup.session)!
        XCTAssertFalse(download.temporary, "download should not be temporary")
        
        downloadsManager.startDownload(download)
        
        XCTAssertFalse(DownloadTestsHelper.checkIfFileExists(sessionSetup.tmpFinalPath), "File should not exist")
        XCTAssertTrue(DownloadTestsHelper.checkIfFileExists(sessionSetup.documentsFinalPath), "File should exist")
    }
}
