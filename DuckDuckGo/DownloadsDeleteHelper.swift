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
import Core

private enum Const {
    static let undoTimeoutInterval: TimeInterval = 3.0
}

enum DownloadDeleteError: Error {
    case fileNotFound
    case cantCreateTempDirectory
}

typealias DeleteUndoHandler = () -> Void
typealias DeleteResult = Result<DeleteUndoHandler, DownloadDeleteError>
typealias DeleteHandler = (_ result: DeleteResult) -> Void

class DownloadsDeleteHelper {
    
    func deleteDownloads(atPaths filePaths: [String], completionHandler: DeleteHandler) {
        let fileURLsForRemoval = existingFileURLs(atPaths: filePaths)
        
        guard !fileURLsForRemoval.isEmpty else {
            completionHandler(.failure(.fileNotFound))
            return
        }
        
        guard let undoDirectoryURL = createTemporaryUndoDirectory() else {
            completionHandler(.failure(.cantCreateTempDirectory))
            return
        }
        
        move(fileURLsForRemoval, to: undoDirectoryURL)
        
        let timer = makeTimerForRemovingDirectory(undoDirectoryURL)
        let undoHandler = makeUndoHandlerForMovingBackFiles(in: undoDirectoryURL,
                                                            to: AppDependencyProvider.shared.downloadManager.downloadsDirectory,
                                                            cancelling: timer)
        completionHandler(.success(undoHandler))
    }
    
    private func existingFileURLs(atPaths filePaths: [String]) -> [URL] {
        filePaths.filter { FileManager.default.fileExists(atPath: $0) }.map { URL(fileURLWithPath: $0) }
    }
    
    private func createTemporaryUndoDirectory(with identifier: String = UUID().uuidString) -> URL? {
        let undoDirectoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(identifier, isDirectory: true)
        
        do {
            try FileManager.default.createDirectory(at: undoDirectoryURL, withIntermediateDirectories: false, attributes: nil)
        } catch {
            return nil
        }
        
        return undoDirectoryURL
    }
    
    private func move(_ fileURLs: [URL], to destinationDirectory: URL) {
        for fileURL in fileURLs {
            let destinationURL = destinationDirectory.appendingPathComponent(fileURL.lastPathComponent)
            try? FileManager.default.moveItem(at: fileURL, to: destinationURL)
        }
    }
    
    private func makeTimerForRemovingDirectory(_ directory: URL, withDelay delay: TimeInterval = Const.undoTimeoutInterval) -> Timer {
        Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            try? FileManager.default.removeItem(at: directory)
        }
    }
    
    private func makeUndoHandlerForMovingBackFiles(in directory: URL, to destinationDirectory: URL, cancelling timer: Timer?) -> DeleteUndoHandler {
        {
            timer?.invalidate()
            
            let filesToMoveURLs = (try? FileManager.default.contentsOfDirectory(at: directory,
                                                                                includingPropertiesForKeys: nil,
                                                                                options: .skipsHiddenFiles)) ?? []
            
            for fileURL in filesToMoveURLs {
                let destinationURL = destinationDirectory.appendingPathComponent(fileURL.lastPathComponent)
                try? FileManager.default.moveItem(at: fileURL, to: destinationURL)
            }
            
            try? FileManager.default.removeItem(at: directory)
            
            Pixel.fire(pixel: .downloadsListDeleteUndo)
        }
    }
}
