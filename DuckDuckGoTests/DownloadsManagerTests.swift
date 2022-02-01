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
import WidgetKit

class DownloadsManagerTests: XCTestCase {
    var mockDependencyProvider: MockDependencyProvider!
    
    override func setUp() {
        mockDependencyProvider = MockDependencyProvider()
        AppDependencyProvider.shared = mockDependencyProvider
    }
    
    override func tearDown() {
        AppDependencyProvider.shared = AppDependencyProvider()
        DownloadTestsHelper.deleteAllFiles()
        // swiftlint:disable notification_center_detachment
        NotificationCenter.default.removeObserver(self)
        // swiftlint:enable notification_center_detachment
    }
    
    func testTemporaryPKPassDownload() {
        let downloadsManager = mockDependencyProvider.downloadsManager
        
        let sessionSetup = MockSessionSetup(mimeType: "application/vnd.apple.pkpass", downloadsManager: downloadsManager)
        
        let download = downloadsManager.setupDownload(sessionSetup.response, downloadSession: sessionSetup.session)!
        XCTAssertTrue(download.temporary, "Download should be temporary")
        
        let expectation = expectation(description: "Download finish")
        
        NotificationCenter.default.addObserver(forName: .downloadFinished, object: nil, queue: nil) { notification in
            if DownloadTestsHelper.downloadForNotification(notification) == download {
                XCTAssertTrue(DownloadTestsHelper.checkIfFileExists(sessionSetup.tmpFinalPath), "File should exist")
                XCTAssertFalse(DownloadTestsHelper.checkIfFileExists(sessionSetup.documentsFinalPath), "File should not exist")
                expectation.fulfill()
            }
        }
        
        downloadsManager.startDownload(download)
        wait(for: [expectation], timeout: 1)
    }
    
    func testTemporaryRealityDownload() {
        let downloadsManager = mockDependencyProvider.downloadsManager
        
        let sessionSetup = MockSessionSetup(mimeType: "model/vnd.reality", downloadsManager: downloadsManager)
        
        let download = downloadsManager.setupDownload(sessionSetup.response, downloadSession: sessionSetup.session)!
        XCTAssertTrue(download.temporary, "Download should be temporary")
        
        let expectation = expectation(description: "Download finish")
        
        NotificationCenter.default.addObserver(forName: .downloadFinished, object: nil, queue: nil) { notification in
            if DownloadTestsHelper.downloadForNotification(notification) == download {
                XCTAssertTrue(DownloadTestsHelper.checkIfFileExists(sessionSetup.tmpFinalPath), "File should exist")
                XCTAssertFalse(DownloadTestsHelper.checkIfFileExists(sessionSetup.documentsFinalPath), "File should not exist")
                expectation.fulfill()
            }
        }
        
        downloadsManager.startDownload(download)
        wait(for: [expectation], timeout: 1)
        
    }
    
    func testTemporaryUSDZDownload() {
        let downloadsManager = mockDependencyProvider.downloadsManager
        
        let sessionSetup = MockSessionSetup(mimeType: "model/vnd.usdz+zip", downloadsManager: downloadsManager)
        
        let download = downloadsManager.setupDownload(sessionSetup.response, downloadSession: sessionSetup.session)!
        XCTAssertTrue(download.temporary, "Download should be temporary")
        
        let expectation = expectation(description: "Download finish")
        
        NotificationCenter.default.addObserver(forName: .downloadFinished, object: nil, queue: nil) { notification in
            if DownloadTestsHelper.downloadForNotification(notification) == download {
                XCTAssertTrue(DownloadTestsHelper.checkIfFileExists(sessionSetup.tmpFinalPath), "File should exist")
                XCTAssertFalse(DownloadTestsHelper.checkIfFileExists(sessionSetup.documentsFinalPath), "File should not exist")
                expectation.fulfill()
            }
        }
        
        downloadsManager.startDownload(download)
        wait(for: [expectation], timeout: 1)
    }
    
    func testPermanentBinaryDownload() {
        let downloadsManager = mockDependencyProvider.downloadsManager
        
        let sessionSetup = MockSessionSetup(mimeType: "application/octet-stream", downloadsManager: downloadsManager)
        
        let download = downloadsManager.setupDownload(sessionSetup.response, downloadSession: sessionSetup.session)!
        XCTAssertFalse(download.temporary, "download should not be temporary")
        
        let expectation = expectation(description: "Download finish")
        
        NotificationCenter.default.addObserver(forName: .downloadFinished, object: nil, queue: nil) { notification in
            if DownloadTestsHelper.downloadForNotification(notification) == download {
                
                XCTAssertFalse(DownloadTestsHelper.checkIfFileExists(sessionSetup.tmpFinalPath), "File should not exist")
                XCTAssertTrue(DownloadTestsHelper.checkIfFileExists(sessionSetup.documentsFinalPath), "File should exist")
                expectation.fulfill()
            }
        }
        
        downloadsManager.startDownload(download)
        wait(for: [expectation], timeout: 1)
    }
    
    func testIfFinishedDownloadIsRemovedFromList() {
        
    }
    
    func downloadForNotification(_ notification: Notification) -> Download {
        if let download = notification.userInfo?[DownloadsManager.UserInfoKeys.download] as? Download {
            return download
        }
        fatalError("Should only be used to test valid downloads")
    }
}
