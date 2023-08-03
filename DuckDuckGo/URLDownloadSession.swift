//
//  URLDownloadSession.swift
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

import Core
import Foundation
import WebKit

class URLDownloadSession: NSObject, DownloadSession {
    private var session: URLSession?
    private var cookieStore: WKHTTPCookieStore?
    private(set) var task: URLSessionDownloadTask?
    private var location: URL?
    weak var delegate: DownloadSessionDelegate?

    var isRunning: Bool {
        task?.state == .running
    }

    internal init(_ url: URL, session: URLSession? = nil, cookieStore: WKHTTPCookieStore? = nil) {
        self.cookieStore = cookieStore
        super.init()
        if let session = session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.ephemeral
            let userAgent = DefaultUserAgentManager.shared.userAgent(isDesktop: false)
            configuration.httpAdditionalHeaders = ["user-agent": userAgent]
            self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
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

    private func finishTasksAndInvalidate() {
        self.session?.finishTasksAndInvalidate()
    }
}

extension URLDownloadSession: URLSessionTaskDelegate, URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            try FileManager.default.moveItem(at: location, to: tmpURL)
            self.location = tmpURL
        } catch {
            Pixel.fire(pixel: .missingDownloadedFile, error: error)
            assertionFailure("Failed to rename file in temp dir - downloaded file is missing")
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.finishTasksAndInvalidate()
        if error == nil, let location = location {
            delegate?.downloadSession(self, didFinishWith: .success(location))
        } else {
            delegate?.downloadSession(self, didFinishWith: .failure(error ?? CancellationError()))
        }
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {

        delegate?.downloadSession(self,
                                  didWriteData: bytesWritten,
                                  totalBytesWritten: totalBytesWritten,
                                  totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }

}
