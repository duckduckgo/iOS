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
    let mockURL = URL(string: "https://duck.com")!
    let tmpDirectory = FileManager.default.temporaryDirectory
    let downloadsDirectory: URL
        
    internal init(downloadsDirectory: URL) {
        self.downloadsDirectory = downloadsDirectory
    }
    
    func createMockFile(on path: URL) {
        try? Data("FakeFileData".utf8).write(to: path)
    }
    
    func checkIfFileExists(_ filePath: URL) -> Bool {
        return FileManager.default.fileExists(atPath: filePath.path)
    }
    
    func deleteFilesOnPath(_ url: URL) {
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
    
     func deleteAllFiles() {
        deleteFilesOnPath(downloadsDirectory)
        deleteFilesOnPath(tmpDirectory)
    }
    
    func downloadForNotification(_ notification: Notification) -> Download {
        if let download = notification.userInfo?[DownloadManager.UserInfoKeys.download] as? Download {
            return download
        }
        fatalError("Should only be used to test valid downloads")
    }
    
    func temporaryAndFinalPathForDownload(_ download: Download) -> (URL, URL) {
        let tmpPath = tmpDirectory.appendingPathComponent(download.filename)
        let finalPath = downloadsDirectory.appendingPathComponent(download.filename)

        return (tmpPath, finalPath)
    }
}
