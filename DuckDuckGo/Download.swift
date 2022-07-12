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
    let url: URL
    let filename: String
    let mimeType: MIMEType
    var location: URL?
    let date = Date()
    var temporary: Bool
    let session: DownloadSession
    var completionBlock: Completion?

    var isRunning: Bool {
        session.isRunning
    }

    var link: Link? {
        guard let location = location,
              FileManager.default.fileExists(atPath: location.path) else {
            return nil
        }
        return Link(title: filename, url: url, localPath: location)
    }

    @Published private(set) var bytesWritten: Int64 = 0
    @Published private(set) var totalBytesWritten: Int64 = 0
    @Published private(set) var totalBytesExpectedToWrite: Int64 = 0

    required init(url: URL,
                  filename: String,
                  mimeType: MIMEType,
                  temporary: Bool,
                  downloadSession: DownloadSession,
                  delegate: DownloadDelegate? = nil) {

        self.url = url
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
    }

    func cancel() {
        session.cancel()
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

    func downloadSession(_ session: DownloadSession,
                         didWriteData bytesWritten: Int64,
                         totalBytesWritten: Int64,
                         totalBytesExpectedToWrite: Int64) {

        self.bytesWritten = bytesWritten
        self.totalBytesWritten = totalBytesWritten
        self.totalBytesExpectedToWrite = totalBytesExpectedToWrite
    }

    func downloadSession(_ session: DownloadSession, didFinishWith result: Result<URL, Error>) {
        switch result {
        case .success(let location):
            self.location = renameFile(location, newFilename: filename)
            delegate?.downloadDidFinish(self, error: nil)
            completionBlock?(nil)
        case .failure(let error):
            delegate?.downloadDidFinish(self, error: error)
            completionBlock?(error)
        }
    }

}
