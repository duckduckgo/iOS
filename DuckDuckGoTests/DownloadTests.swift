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

private class MockDownloadSession: DownloadSession {
    var temporaryFilePath: URL?
    
    override func start() {
        let session = URLSession.shared
        let task = session.downloadTask(with: URL(string: "https://duck.com")!)

        delegate?.urlSession(session, downloadTask: task, didFinishDownloadingTo: temporaryFilePath!)
        delegate?.urlSession(URLSession.shared, task: task, didCompleteWithError: nil)
    }
}

class DownloadTests: XCTestCase {
    private let mockURL = URL(string: "https://duck.com")!
    private let tmpDirectory = FileManager.default.temporaryDirectory
    // swiftlint:disable force_try
    private let documentsDirectory = try! FileManager.default.url(for: .documentDirectory,
                                                                     in: .userDomainMask,
                                                                     appropriateFor: nil,
                                                                     create: false)
    // swiftlint:enable force_try
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
        deleteAllFiles()
    }
    
    private func deleteAllFiles() {
        deleteFilesOnPath(documentsDirectory)
        deleteFilesOnPath(tmpDirectory)
    }
    
    private func createMockFile(on path: URL) {
        try? Data("FakeFileData".utf8).write(to: path)
    }
    
    private func deleteFilesOnPath(_ url: URL) {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: url,
                                                                    includingPropertiesForKeys: nil,
                                                                    options: .skipsHiddenFiles)
            
            files.forEach {
                try? FileManager.default.removeItem(at: $0)
            }
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    private func checkIfFileExists(_ filePath: URL) -> Bool {
        return FileManager.default.fileExists(atPath: filePath.path)
    }

    func testTemporaryDownload() {
        let mockSession = MockDownloadSession(mockURL)
        
        let tmpName = "MOCK_\(UUID().uuidString).tmp"
        let filename = "\(UUID().uuidString).zip"

        let path = tmpDirectory.appendingPathComponent(tmpName)
        createMockFile(on: path)
        
        let finalFilePath = tmpDirectory.appendingPathComponent(filename)
        
        mockSession.temporaryFilePath = path
        
        let temporaryDownload = Download(mockURL, downloadSession: mockSession, mimeType: .passbook, fileName: filename, temporary: true)
        temporaryDownload.start()

        XCTAssertTrue(temporaryDownload.temporary, "File should be temporary")
        XCTAssertTrue(checkIfFileExists(finalFilePath), "File should exist")
    }
    
    func testPermanentDownload() {
        let mockSession = MockDownloadSession(mockURL)
        
        let tmpName = "MOCK_\(UUID().uuidString).tmp"
        let filename = "\(UUID().uuidString).zip"
        
        let path = tmpDirectory.appendingPathComponent(tmpName)
        createMockFile(on: path)
        
        let finalFilePath = tmpDirectory.appendingPathComponent(filename)
        
        mockSession.temporaryFilePath = path
        
        let temporaryDownload = Download(mockURL, downloadSession: mockSession, mimeType: .passbook, fileName: filename, temporary: false)
        temporaryDownload.start()

        XCTAssertFalse(temporaryDownload.temporary, "File should not temporary")
        XCTAssertTrue(checkIfFileExists(finalFilePath), "File should exist")
    }

}
