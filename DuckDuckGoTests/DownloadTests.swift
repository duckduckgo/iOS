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

    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
        DownloadTestsHelper.deleteAllFiles()
    }

    func testTemporaryDownload() {
        let mockSession = MockDownloadSession(DownloadTestsHelper.mockURL)
        
        let tmpName = "MOCK_\(UUID().uuidString).tmp"
        let filename = "\(UUID().uuidString).zip"
        
        let path = DownloadTestsHelper.tmpDirectory.appendingPathComponent(tmpName)
        DownloadTestsHelper.createMockFile(on: path)
        
        let finalFilePath = DownloadTestsHelper.tmpDirectory.appendingPathComponent(filename)
        
        mockSession.temporaryFilePath = path
        
        let temporaryDownload = Download(downloadSession: mockSession, mimeType: .passbook, fileName: filename, temporary: true)
        
        let expectation = expectation(description: "Download finish")
        temporaryDownload.start()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(temporaryDownload.temporary, "File should be temporary")
            XCTAssertTrue(DownloadTestsHelper.checkIfFileExists(finalFilePath), "File should exist")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testPermanentDownload() {
        let mockSession = MockDownloadSession(DownloadTestsHelper.mockURL)
        
        let tmpName = "MOCK_\(UUID().uuidString).tmp"
        let filename = "\(UUID().uuidString).zip"
        
        let path = DownloadTestsHelper.tmpDirectory.appendingPathComponent(tmpName)
        DownloadTestsHelper.createMockFile(on: path)
        
        let finalFilePath = DownloadTestsHelper.tmpDirectory.appendingPathComponent(filename)
        
        mockSession.temporaryFilePath = path
        
        let temporaryDownload = Download(downloadSession: mockSession, mimeType: .passbook, fileName: filename, temporary: false)
        
        let expectation = expectation(description: "Download finish")
        temporaryDownload.start()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(temporaryDownload.temporary, "File should not be temporary")
            XCTAssertTrue(DownloadTestsHelper.checkIfFileExists(finalFilePath), "File should exist")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
}
