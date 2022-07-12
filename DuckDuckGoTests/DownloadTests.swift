//
//  DownloadTests.swift
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
@testable import DuckDuckGo

class DownloadTests: XCTestCase {
    private let downloadManagerTestsHelper = DownloadTestsHelper(downloadsDirectory: DownloadManager().downloadsDirectory)
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        downloadManagerTestsHelper.deleteAllFiles()
    }
    
    func testTemporaryDownload() {
        let mockSession = MockDownloadSession(downloadManagerTestsHelper.mockURL)
        
        let tmpName = "MOCK_\(UUID().uuidString).tmp"
        let filename = "\(UUID().uuidString).zip"
        
        let path = downloadManagerTestsHelper.tmpDirectory.appendingPathComponent(tmpName)
        downloadManagerTestsHelper.createMockFile(on: path)
        
        let finalFilePath = downloadManagerTestsHelper.tmpDirectory.appendingPathComponent(filename)
        
        mockSession.temporaryFilePath = path
        
        let temporaryDownload = Download(url: downloadManagerTestsHelper.mockURL,
                                         filename: filename,
                                         mimeType: .passbook,
                                         temporary: true,
                                         downloadSession: mockSession)
        
        let expectation = expectation(description: "Download finish")
        temporaryDownload.start()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(temporaryDownload.temporary, "File should be temporary")
            XCTAssertTrue(self.downloadManagerTestsHelper.checkIfFileExists(finalFilePath), "File should exist")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testPermanentDownload() {
        let mockSession = MockDownloadSession(downloadManagerTestsHelper.mockURL)
        
        let tmpName = "MOCK_\(UUID().uuidString).tmp"
        let filename = "\(UUID().uuidString).zip"
        
        let path = downloadManagerTestsHelper.tmpDirectory.appendingPathComponent(tmpName)
        downloadManagerTestsHelper.createMockFile(on: path)
        
        let finalFilePath = downloadManagerTestsHelper.tmpDirectory.appendingPathComponent(filename)
        
        mockSession.temporaryFilePath = path
        
        let temporaryDownload = Download(url: downloadManagerTestsHelper.mockURL,
                                         filename: filename,
                                         mimeType: .passbook,
                                         temporary: false,
                                         downloadSession: mockSession)
        
        let expectation = expectation(description: "Download finish")
        temporaryDownload.start()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(temporaryDownload.temporary, "File should not be temporary")
             XCTAssertTrue(self.downloadManagerTestsHelper.checkIfFileExists(finalFilePath), "File should exist")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
}
