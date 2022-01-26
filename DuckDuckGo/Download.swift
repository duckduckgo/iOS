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

protocol DownloadDelegate: AnyObject {
    func downloadDidFinish(_ download: Download)
}

class Download: NSObject, Identifiable, ObservableObject {
    weak var delegate: DownloadDelegate?
    
    let id = UUID()
    let filename: String
    let mimeType: MIMEType
    var location: URL?
    let date = Date()
    let temporary: Bool
    
    private var session: URLSession?
    private let cookieStore: WKHTTPCookieStore?
    private var downloadSession: URLSessionDownloadTask?
    
    @Published private(set) var state: URLSessionTask.State = .suspended
    @Published private(set) var bytesWritten: Int64 = 0
    @Published private(set) var totalBytesWritten: Int64 = 0
    @Published private(set) var totalBytesExpectedToWrite: Int64 = 0
    
    required init(_ url: URL, mimeType: MIMEType, fileName: String, cookieStore: WKHTTPCookieStore?, temporary: Bool, delegate: DownloadDelegate) {
      
        self.delegate = delegate
        self.filename = fileName
        self.cookieStore = cookieStore
        self.mimeType = mimeType
        self.temporary = temporary
        super.init()
        self.session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: .main)
        downloadSession = self.session?.downloadTask(with: URLRequest(url: url))
    }
    
    func start() {
        cookieStore?.getAllCookies { cookies in
            cookies.forEach { cookie in
                self.session?.configuration.httpCookieStorage?.setCookie(cookie)
            }
        }
        downloadSession?.resume()
        self.state = downloadSession?.state ?? .completed
    }
    
    deinit {
        print("Download \(id) \(filename) deinit")
    }
    
    private func renameFile(_ oldPath: URL, name: String) -> URL? {
        do {
            let newPath = oldPath.deletingLastPathComponent().appendingPathComponent(name)
            try? FileManager.default.removeItem(at: newPath)
            try FileManager.default.moveItem(at: oldPath, to: newPath)
            
            return newPath
        } catch {
            return nil
        }
    }
}

extension Download: URLSessionDownloadDelegate, URLSessionTaskDelegate {
  
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        self.location = renameFile(location, name: filename)
        self.session?.finishTasksAndInvalidate()
        state = downloadTask.state
        delegate?.downloadDidFinish(self)
    }
    
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
}

extension NSNotification.Name {
    static let downloadStarted: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.notification.downloadStarted")
    static let downloadFinished: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.notification.downloadFinished")
}
