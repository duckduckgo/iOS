//
//  DownloadSession.swift
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

protocol DownloadSessionDelegate: AnyObject {
    func urlSession(_ session: URLSession,
   
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64)
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
}

class DownloadSession: NSObject {
    private var session: URLSession?
    private var cookieStore: WKHTTPCookieStore?
    private(set) var task: URLSessionDownloadTask?
    weak var delegate: DownloadSessionDelegate?
    
    internal init(_ url: URL, session: URLSession? = nil, cookieStore: WKHTTPCookieStore? = nil) {
        self.cookieStore = cookieStore
        super.init()
        if let session = session {
            self.session = session
        } else {
            self.session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: .main)
        }
        self.task = self.session?.downloadTask(with: url)
    }
    
    func start() {
        cookieStore?.getAllCookies { [weak self] cookies in
            cookies.forEach { cookie in
                self?.session?.configuration.httpCookieStorage?.setCookie(cookie)
            }
            self?.task?.resume()
        }
    }
    
    func cancel() {
        task?.cancel()
    }
    
    func finishTasksAndInvalidate() {
        self.session?.finishTasksAndInvalidate()
    }
}

extension DownloadSession: URLSessionTaskDelegate, URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        delegate?.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        delegate?.urlSession(session, task: task, didCompleteWithError: error)
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        
        delegate?.urlSession(session,
                             downloadTask: downloadTask,
                             didWriteData: bytesWritten,
                             totalBytesWritten: totalBytesWritten,
                             totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
}
