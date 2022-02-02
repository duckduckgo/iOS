//
//  DownloadTestsHelper.swift
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
@testable import DuckDuckGo

struct DownloadTestsHelper {
    static let mockURL = URL(string: "https://duck.com")!
    static let tmpDirectory = FileManager.default.temporaryDirectory
    // swiftlint:disable force_try
    static let documentsDirectory = try! FileManager.default.url(for: .documentDirectory,
                                                                     in: .userDomainMask,
                                                                     appropriateFor: nil,
                                                                     create: false)
    // swiftlint:enable force_try

    static func createMockFile(on path: URL) {
        try? Data("FakeFileData".utf8).write(to: path)
    }
    
    static func checkIfFileExists(_ filePath: URL) -> Bool {
        return FileManager.default.fileExists(atPath: filePath.path)
    }
    
    static func deleteFilesOnPath(_ url: URL) {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: url,
                                                                    includingPropertiesForKeys: nil,
                                                                    options: .skipsHiddenFiles)
            
            files.forEach {
                try? FileManager.default.removeItem(at: $0)
            }
            
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func deleteAllFiles() {
        DownloadTestsHelper.deleteFilesOnPath(DownloadTestsHelper.documentsDirectory)
        DownloadTestsHelper.deleteFilesOnPath(DownloadTestsHelper.tmpDirectory)
    }
    
    static func downloadForNotification(_ notification: Notification) -> Download {
        if let download = notification.userInfo?[DownloadsManager.UserInfoKeys.download] as? Download {
            return download
        }
        fatalError("Should only be used to test valid downloads")
    }
    
    static func temporaryAndFinalPathForDownload(_ download: Download) -> (URL, URL) {
        let tmpPath = DownloadTestsHelper.tmpDirectory.appendingPathComponent(download.filename)
        let finalPath = DownloadTestsHelper.documentsDirectory.appendingPathComponent(download.filename)

        return (tmpPath, finalPath)
    }
}
