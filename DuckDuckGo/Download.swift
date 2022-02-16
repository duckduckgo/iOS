//
//  Download.swift
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
import WebKit
import Core

protocol DownloadDelegate: AnyObject {
    func downloadDidFinish(_ download: Download, error: Error?)
}

class Download: NSObject, Identifiable, ObservableObject {
    weak var delegate: DownloadDelegate?
    typealias Completion = ((Error?) -> Void)
    
    let id = UUID()
    let filename: String
    let mimeType: MIMEType
    var location: URL?
    let date = Date()
    let temporary: Bool
    let session: DownloadSession
    var completionBlock: Completion?

    var link: Link? {
        guard let location = location,
              FileManager.default.fileExists(atPath: location.path) else {
            return nil
        }
        return Link(title: filename, url: location)
    }
    
    @Published private(set) var state: URLSessionTask.State = .suspended
    @Published private(set) var bytesWritten: Int64 = 0
    @Published private(set) var totalBytesWritten: Int64 = 0
    @Published private(set) var totalBytesExpectedToWrite: Int64 = 0
    
    required init(filename: String,
                  mimeType: MIMEType,
                  temporary: Bool,
                  downloadSession: DownloadSession,
                  delegate: DownloadDelegate? = nil) {
        
        self.filename = filename
        self.mimeType = mimeType
        self.temporary = temporary
        self.session = downloadSession
        self.delegate = delegate
        
        super.init()
        self.session.delegate = self
    }
    
    func start() {
        session.start()
        updateState()
    }
    
    func cancel() {
        session.cancel()
        updateState()
    }
    
    private func updateState() {
        self.state = self.session.task?.state ?? .completed
    }
    
    deinit {
        print("Download \(id) \(filename) deinit")
    }
    
    private func renameFile(_ oldPath: URL, newFilename: String) -> URL? {
        do {
            let newPath = oldPath.deletingLastPathComponent().appendingPathComponent(newFilename)
            try? FileManager.default.removeItem(at: newPath)
            try FileManager.default.moveItem(at: oldPath, to: newPath)
            
            return newPath
        } catch {
            return nil
        }
    }
}

extension Download: DownloadSessionDelegate {
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        
        self.bytesWritten = bytesWritten
        self.totalBytesWritten = totalBytesWritten
        self.totalBytesExpectedToWrite = totalBytesExpectedToWrite
        
        self.state = downloadTask.state
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        self.location = renameFile(location, newFilename: filename)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        session.finishTasksAndInvalidate()
        state = task.state
        delegate?.downloadDidFinish(self, error: error)
        completionBlock?(error)
    }
}
