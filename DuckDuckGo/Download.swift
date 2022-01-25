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

public struct DownloadNotification {
    static let started: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.notification.downloadStarted")
    static let finished: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.notification.downloadFinished")

    public static let downloadItemKey = "com.duckduckgo.userInfoKey.downloadItem"
}

protocol DownloadDelegate: AnyObject {
    func downloadDidFinish(_ download: Download)
}

class Download: NSObject, Identifiable, ObservableObject {
    weak var delegate: DownloadDelegate?
    
    let id = UUID()
    let filename: String
    let mimeType: MIMEType
    var filePath: URL?
    private var session: URLSession?
    private let cookieStore: WKHTTPCookieStore
    private var downloadSession: URLSessionDownloadTask?
    
    @Published private(set) var state: URLSessionTask.State = .suspended
    @Published private(set) var bytesWritten: Int64 = 0
    @Published private(set) var totalBytesWritten: Int64 = 0
    @Published private(set) var totalBytesExpectedToWrite: Int64 = 0
    
    required init(_ url: URL, mimeType: String, fileName: String, cookieStore: WKHTTPCookieStore, delegate: DownloadDelegate) {
        self.delegate = delegate
        self.filename = fileName
        self.cookieStore = cookieStore
        self.mimeType = MIMEType(rawValue: mimeType) ?? .unknown
        super.init()
        self.session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: .main)
        downloadSession = self.session?.downloadTask(with: URLRequest(url: url))
    }
    
    func cancel() {
        downloadSession?.cancel()
        self.state = downloadSession?.state ?? .completed
    }
    
    func suspend() {
        downloadSession?.suspend()
        self.state = downloadSession?.state ?? .completed
    }
    
    func start() {
        cookieStore.getAllCookies { cookies in
            cookies.forEach { cookie in
                self.session?.configuration.httpCookieStorage?.setCookie(cookie)
            }
        }
        downloadSession?.resume()
        self.state = downloadSession?.state ?? .completed
        NotificationCenter.default.post(name: DownloadNotification.started,
                                        object: self,
                                        userInfo: [DownloadNotification.downloadItemKey: self])
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
    
    deinit {
        print("Download \(id) \(filename) deinit")
    }
}

extension Download: URLSessionDownloadDelegate, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let file = self.renameFile(location, name: filename) {
            self.filePath = file
            delegate?.downloadDidFinish(self)
        }
        self.session?.finishTasksAndInvalidate()
        self.state = downloadTask.state
        
        NotificationCenter.default.post(name: DownloadNotification.finished,
                                        object: self,
                                        userInfo: [DownloadNotification.downloadItemKey: self])
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
