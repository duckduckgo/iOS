//
//  DownloadManagerTests.swift
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

class DownloadManagerTests: XCTestCase {
    private let downloadManagerTestsHelper = DownloadTestsHelper(downloadsDirectory: DownloadManager().downloadsDirectory)
    
    override func tearDown() {
        super.tearDown()
        downloadManagerTestsHelper.deleteAllFiles()
    }
    
    func testWhenIPadThenPKPassThenDownloadIsNotTemporary() {
        guard UIDevice.current.userInterfaceIdiom == .pad else { return }
        
        let notificationCenter = NotificationCenter()
        let downloadManager = DownloadManager(notificationCenter)
        
        let sessionSetup = MockSessionSetup(mimeType: "application/vnd.apple.pkpass", downloadManager: downloadManager)
        
        let download = downloadManager.makeDownload(navigationResponse: sessionSetup.response, downloadSession: sessionSetup.session)!
        XCTAssertFalse(download.temporary, "Download should be not temporary")
    }
    
    func testNotificationTemporaryPKPassDownloadOnPhone() {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }
        
        let notificationCenter = NotificationCenter()
        let downloadManager = DownloadManager(notificationCenter)
        
        let sessionSetup = MockSessionSetup(mimeType: "application/vnd.apple.pkpass", downloadManager: downloadManager)
        
        let download = downloadManager.makeDownload(navigationResponse: sessionSetup.response, downloadSession: sessionSetup.session)!
        XCTAssertTrue(download.temporary, "Download should be temporary")
        
        let expectation = expectation(description: "Download finish")
        
        notificationCenter.addObserver(forName: .downloadFinished, object: nil, queue: nil) { [self] notification in
          
            if downloadManagerTestsHelper.downloadForNotification(notification) == download {
                let (tmpPath, finalPath) = downloadManagerTestsHelper.temporaryAndFinalPathForDownload(download)

                XCTAssertTrue(downloadManagerTestsHelper.checkIfFileExists(tmpPath), "File should exist")
                XCTAssertFalse(downloadManagerTestsHelper.checkIfFileExists(finalPath), "File should not exist")
                expectation.fulfill()
            }
        }
        
        downloadManager.startDownload(download)
        wait(for: [expectation], timeout: 1)
    }
    
    func testNotificationTemporaryRealityDownload() {
        
        let notificationCenter = NotificationCenter()
        let downloadManager = DownloadManager(notificationCenter)

        let sessionSetup = MockSessionSetup(mimeType: "model/vnd.reality", downloadManager: downloadManager)
        
        let download = downloadManager.makeDownload(navigationResponse: sessionSetup.response, downloadSession: sessionSetup.session)!
        XCTAssertTrue(download.temporary, "Download should be temporary")
        
        let expectation = expectation(description: "Download finish")
        
        notificationCenter.addObserver(forName: .downloadFinished, object: nil, queue: nil) { [self] notification in
           
            if downloadManagerTestsHelper.downloadForNotification(notification) == download {
                let (tmpPath, finalPath) = downloadManagerTestsHelper.temporaryAndFinalPathForDownload(download)

                XCTAssertTrue(downloadManagerTestsHelper.checkIfFileExists(tmpPath), "File should exist")
                XCTAssertFalse(downloadManagerTestsHelper.checkIfFileExists(finalPath), "File should not exist")
                expectation.fulfill()
            }
        }
        
        downloadManager.startDownload(download)
        wait(for: [expectation], timeout: 1)
        
    }
    
    func testNotificationTemporaryUSDZDownload() {
        let notificationCenter = NotificationCenter()
        let downloadManager = DownloadManager(notificationCenter)

        let sessionSetup = MockSessionSetup(mimeType: "model/vnd.usdz+zip", downloadManager: downloadManager)
        
        let download = downloadManager.makeDownload(navigationResponse: sessionSetup.response, downloadSession: sessionSetup.session)!
        XCTAssertTrue(download.temporary, "Download should be temporary")
        
        let expectation = expectation(description: "Download finish")
        
        notificationCenter.addObserver(forName: .downloadFinished, object: nil, queue: nil) { [self] notification in
            
            if downloadManagerTestsHelper.downloadForNotification(notification) == download {
                let (tmpPath, finalPath) = downloadManagerTestsHelper.temporaryAndFinalPathForDownload(download)

                XCTAssertTrue(downloadManagerTestsHelper.checkIfFileExists(tmpPath), "File should exist")
                XCTAssertFalse(downloadManagerTestsHelper.checkIfFileExists(finalPath), "File should not exist")
                expectation.fulfill()
            }
        }
        
        downloadManager.startDownload(download)
        wait(for: [expectation], timeout: 1)
    }
    
    func testNotificationPermanentBinaryDownload() {
        let notificationCenter = NotificationCenter()
        let downloadManager = DownloadManager(notificationCenter)

        let sessionSetup = MockSessionSetup(mimeType: "application/octet-stream", downloadManager: downloadManager)
        
        let download = downloadManager.makeDownload(navigationResponse: sessionSetup.response, downloadSession: sessionSetup.session)!
        XCTAssertFalse(download.temporary, "download should not be temporary")
        
        let expectation = expectation(description: "Download finish")
        
        notificationCenter.addObserver(forName: .downloadFinished, object: nil, queue: nil) { [self] notification in
           
            if downloadManagerTestsHelper.downloadForNotification(notification) == download {
                let (tmpPath, finalPath) = downloadManagerTestsHelper.temporaryAndFinalPathForDownload(download)

                XCTAssertFalse(downloadManagerTestsHelper.checkIfFileExists(tmpPath), "File should not exist")
                XCTAssertTrue(downloadManagerTestsHelper.checkIfFileExists(finalPath), "File should exist")
                expectation.fulfill()
            }
        }
        
        downloadManager.startDownload(download)
        wait(for: [expectation], timeout: 1)
    }
    
    func testClosurePermanentBinaryDownload() {
        let downloadManager = DownloadManager(NotificationCenter())
        let sessionSetup = MockSessionSetup(mimeType: "application/octet-stream", downloadManager: downloadManager)
        
        let download = downloadManager.makeDownload(navigationResponse: sessionSetup.response, downloadSession: sessionSetup.session)!
        XCTAssertFalse(download.temporary, "download should not be temporary")
        
        let expectation = expectation(description: "Download finish")

        downloadManager.startDownload(download) { [self] error in
            let (tmpPath, finalPath) = downloadManagerTestsHelper.temporaryAndFinalPathForDownload(download)

            XCTAssertNil(error)
            XCTAssertFalse(downloadManagerTestsHelper.checkIfFileExists(tmpPath), "File should not exist")
            XCTAssertTrue(downloadManagerTestsHelper.checkIfFileExists(finalPath), "File should exist")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testIfFinishedDownloadIsRemovedFromList() {
        let notificationCenter = NotificationCenter()
        let downloadManager = DownloadManager(notificationCenter)

        let sessionSetup = MockSessionSetup(mimeType: "application/octet-stream", downloadManager: downloadManager, completionDelay: 1)
        let download = downloadManager.makeDownload(navigationResponse: sessionSetup.response, downloadSession: sessionSetup.session)!
        let expectation = expectation(description: "Download finish")
        
        notificationCenter.addObserver(forName: .downloadFinished, object: nil, queue: nil) { [self] notification in
           
            if downloadManagerTestsHelper.downloadForNotification(notification) == download {
                XCTAssertEqual(downloadManager.downloadList.count, 0)
                expectation.fulfill()
            }
        }
        
        downloadManager.startDownload(download)
        XCTAssertEqual(downloadManager.downloadList.count, 1)

        wait(for: [expectation], timeout: 2)
    }
    
    func downloadForNotification(_ notification: Notification) -> Download {
        if let download = notification.userInfo?[DownloadManager.UserInfoKeys.download] as? Download {
            return download
        }
        fatalError("Should only be used to test valid downloads")
    }
    
    func testRTLSanitizing() {
        let spoofedName = "test.‮gpj‬" // U+202E + U+202C character
        let expectedName = "test.gpj"
        let notificationCenter = NotificationCenter()
        let downloadManager = DownloadManager(notificationCenter)

        let sessionSetup = MockSessionSetup(mimeType: "application/octet-stream", downloadManager: downloadManager, filename: spoofedName)
        
        let download = downloadManager.makeDownload(navigationResponse: sessionSetup.response, downloadSession: sessionSetup.session)!
        
        let expectation = expectation(description: "Download finish")
        
        notificationCenter.addObserver(forName: .downloadFinished, object: nil, queue: nil) { [self] notification in
           
            if downloadManagerTestsHelper.downloadForNotification(notification) == download {
                let (tmpPath, finalPath) = downloadManagerTestsHelper.temporaryAndFinalPathForDownload(download)
                
                XCTAssertFalse(downloadManagerTestsHelper.checkIfFileExists(tmpPath), "File should not exist")
                XCTAssertTrue(downloadManagerTestsHelper.checkIfFileExists(finalPath), "File should exist")
                XCTAssertEqual(expectedName, download.filename, "Names should be equal")
                expectation.fulfill()
            }
        }
        
        downloadManager.startDownload(download)
        wait(for: [expectation], timeout: 1)
    }
    
    func testDownloadListUniqueFilenames() {
        let numberOfFiles = 3
        var files = [String](repeating: "duck.txt", count: numberOfFiles)
        files.append(contentsOf: [String](repeating: "duck", count: numberOfFiles))
        
        let expectedList = ["duck", "duck 1", "duck 2", "duck.txt", "duck 1.txt", "duck 2.txt"]
        let downloadManager = DownloadManager()

        files.forEach {
            let sessionSetup = MockSessionSetup(mimeType: "application/octet-stream", downloadManager: downloadManager, filename: $0)
             _ = downloadManager.makeDownload(navigationResponse: sessionSetup.response, downloadSession: sessionSetup.session)!
        }
        
        let downloadListNames = downloadManager.downloadList.map { $0.filename }.sorted()
        
        XCTAssertEqual(downloadListNames, expectedList.sorted(), "Lists should be the same")
    }
    
    func testFileSystemUniqueFilenames() {
        let fileWithExtension = "duck.txt"
        let fileWithoutExtension = "duck"
        
        downloadManagerTestsHelper.createMockFile(on: downloadManagerTestsHelper.downloadsDirectory.appendingPathComponent(fileWithExtension))
        downloadManagerTestsHelper.createMockFile(on: downloadManagerTestsHelper.downloadsDirectory.appendingPathComponent(fileWithoutExtension))
        
        let numberOfFiles = 3
        var files = [String](repeating: fileWithExtension, count: numberOfFiles)
        files.append(contentsOf: [String](repeating: fileWithoutExtension, count: numberOfFiles))
        
        let expectedList = ["duck 1", "duck 2", "duck 3", "duck 1.txt", "duck 2.txt", "duck 3.txt"]
        let downloadManager = DownloadManager()

        files.forEach {
            let sessionSetup = MockSessionSetup(mimeType: "application/octet-stream", downloadManager: downloadManager, filename: $0)
             _ = downloadManager.makeDownload(navigationResponse: sessionSetup.response, downloadSession: sessionSetup.session)!
        }
        
        let downloadListNames = downloadManager.downloadList.map { $0.filename }.sorted()
        
        XCTAssertEqual(downloadListNames, expectedList.sorted(), "Lists should be the same")

    }
}
