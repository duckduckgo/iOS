//
//  DownloadsManager.swift
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
import WebKit

class DownloadsManager {
    
    struct UserInfoKeys {
        static let download = "com.duckduckgo.com.userInfoKey.download"
        static let error = "com.duckduckgo.com.userInfoKey.error"
    }
    
    private enum Constants {
        static var downloadsDirectoryName = "Downloads"
    }
    
    private(set) var downloadList = Set<Download>()
    private let notificationCenter: NotificationCenter
    private var downloadsDirectory: URL {
        do {
            let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            return documentsDirectory.appendingPathComponent(Constants.downloadsDirectoryName, isDirectory: true)
        } catch {
            return FileManager.default.temporaryDirectory
        }
    }
    
    var downloadsFolderFiles: [URL]? {
        try? FileManager.default.contentsOfDirectory(at: downloadsDirectory, includingPropertiesForKeys: nil)
    }
    
    init(_ notificationCenter: NotificationCenter = NotificationCenter.default) {
        self.notificationCenter = notificationCenter
        createDownloadsDirectoryIfNeeded()
        print("Downloads: \(downloadsDirectory)")
    }
    
    private func createDownloadsDirectoryIfNeeded() {
        if !downloadsDirectoryExists() {
            createDownloadsDirectory()
        }
    }
    
    private func downloadsDirectoryExists() -> Bool {
        FileManager.default.fileExists(atPath: downloadsDirectory.absoluteString)
    }
    
    private func createDownloadsDirectory() {
        try? FileManager.default.createDirectory(at: downloadsDirectory, withIntermediateDirectories: true, attributes: nil)
    }
    
    func makeDownload(navigationResponse: WKNavigationResponse,
                      downloadSession: DownloadSession? = nil,
                      cookieStore: WKHTTPCookieStore? = nil,
                      temporary: Bool? = nil) -> Download? {
        
        guard let metaData = downloadMetaData(for: navigationResponse) else { return nil }
        
        let temporaryFile: Bool
        if let temporary = temporary {
            temporaryFile = temporary
        } else {
            switch metaData.mimeType {
            case .reality, .usdz, .passbook:
                temporaryFile = true
            default:
                temporaryFile = false
            }
        }
        
        let session: DownloadSession
        if let downloadSession = downloadSession {
            session = downloadSession
        } else {
            session = DownloadSession(metaData.url, cookieStore: cookieStore)
        }
        
        let download = Download(filename: metaData.filename,
                                mimeType: metaData.mimeType,
                                temporary: temporaryFile,
                                downloadSession: session,
                                delegate: self)

        downloadList.insert(download)
        return download
    }
    
    func downloadMetaData(for navigationResponse: WKNavigationResponse) -> DownloadMetadata? {
        let filename = filename(for: navigationResponse)
        return DownloadMetadata(navigationResponse.response, filename: filename)
    }
    
    func startDownload(_ download: Download, completion: Download.Completion? = nil) {
        download.completionBlock = completion
        download.start()
        notificationCenter.post(name: .downloadStarted, object: nil, userInfo: [UserInfoKeys.download: download])
    }
    
    func cancelDownload(_ download: Download) {
        download.cancel()
    }
    
    func cancelAllDownloads() {
        downloadList.forEach { $0.cancel() }
    }

    private func move(_ download: Download, toPath path: URL) {
        guard let location = download.location else { return }
         do {
             let newPath = path.appendingPathComponent(download.filename)
             try? FileManager.default.removeItem(at: newPath)
             try FileManager.default.moveItem(at: location, to: newPath)
             download.location = newPath
         } catch {
             print("Error \(error)")
         }
    }
    
    private func moveToDownloadFolderIfNecessary(_ download: Download) {
        guard !download.temporary else { return }
        move(download, toPath: downloadsDirectory)
    }
}

// MARK: - Filename Methods

extension DownloadsManager {
    
    private func convertToUniqueFilename(_ filename: String, counter: Int = 0) -> String {
        let downloadingFilenames = Set(downloadList.map { $0.filename })
        let downloadedFilenames = Set(downloadsFolderFiles?.compactMap { $0.lastPathComponent } ?? [] )
        let list = downloadingFilenames.union(downloadedFilenames)
        
        var fileExtension = downloadsDirectory.appendingPathComponent(filename).pathExtension
        fileExtension = fileExtension.count > 0 ? ".\(fileExtension)" : ""
        
        let filePrefix = filename.drop(suffix: fileExtension)

        let newFilename = counter > 0 ? "\(filePrefix) \(counter)\(fileExtension)" : filename
        
        if list.contains(newFilename) {
            let newSuffix = counter + 1
            return convertToUniqueFilename(filename, counter: newSuffix)
        } else {
            return newFilename
        }
    }
    
    private func filename(for navigationResponse: WKNavigationResponse) -> String {
        let filename = sanitizeFilename(navigationResponse.response.suggestedFilename)
        return convertToUniqueFilename(filename)
    }
    
    //https://app.asana.com/0/0/1201734618649839/f
    private func sanitizeFilename(_ originalFilename: String?) -> String {
        let filename = originalFilename ?? "unknown"
        let allowedCharacterSet = CharacterSet.alphanumerics.union(CharacterSet.punctuationCharacters)
        return filename.components(separatedBy: allowedCharacterSet.inverted).joined()
    }
}

extension DownloadsManager: DownloadDelegate {
    func downloadDidFinish(_ download: Download, error: Error?) {
        moveToDownloadFolderIfNecessary(download)
        var userInfo: [AnyHashable: Any] = [UserInfoKeys.download: download]
        if let error = error {
            userInfo[UserInfoKeys.error] = error
        }
        downloadList.remove(download)
        notificationCenter.post(name: .downloadFinished, object: nil, userInfo: userInfo)
    }
}

extension NSNotification.Name {
    static let downloadStarted: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.notification.downloadStarted")
    static let downloadFinished: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.notification.downloadFinished")
}
