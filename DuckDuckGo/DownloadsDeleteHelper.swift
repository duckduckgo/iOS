//
//  DownloadsDeleteHelper.swift
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

private enum Const {
    static let undoTimeoutInterval: TimeInterval = 3.0
}

enum DownloadDeleteError: Error {
    case fileNotFound
}

typealias DeleteUndoHandler = () -> Void
typealias DeleteResult = Result<DeleteUndoHandler, DownloadDeleteError>
typealias DeleteHandler = (_ result: DeleteResult) -> Void

class DownloadsDeleteHelper {
       
    func deleteDownloads(atPaths filePaths: [String], completionHandler: DeleteHandler) {
        
        var result: DeleteResult
        let undoHandler = { print("UNDO delete all!") }
        
        result = .success(undoHandler)
        
        do {
            let fileManager = FileManager.default
            
            for filePath in filePaths {
                if fileManager.fileExists(atPath: filePath) {
                    try fileManager.removeItem(atPath: filePath)
                } else {
                    result = .failure(.fileNotFound)
                    break
                }
            }

        } catch let error as NSError {
            print("An error took place: \(error)")
            result = .failure(.fileNotFound)
        }
        
        completionHandler(result)
    }
    
    // 1. make unique identifier
    private func makeIdentifier() -> String {
        UUID().uuidString
    }
    
    
    // 2. make matching folder in tmp
    
    // 3. move file(s) to tmp folder
    
    // 4. setup timer for delete tmpfolder
    
    // 5. retrn undo closure that cancels timer and moves from tmp
    
}
