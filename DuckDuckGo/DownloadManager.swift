//
//  DownloadManager.swift
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

import Common
import Foundation
import Core
import WebKit
import UniformTypeIdentifiers

class DownloadManager {
    
    struct UserInfoKeys {
        static let download = "com.duckduckgo.com.userInfoKey.download"
        static let error = "com.duckduckgo.com.userInfoKey.error"
    }
    
    private enum Constants {
        static var downloadsDirectoryName = "Downloads"
    }
    
    private(set) var downloadList = Set<Download>()
    private let notificationCenter: NotificationCenter
    private var downloadsDirectoryMonitor: DirectoryMonitor?
    
    @UserDefaultsWrapper(key: .unseenDownloadsAvailable, defaultValue: false)
    private(set) var unseenDownloadsAvailable: Bool
    
    var downloadsDirectory: URL {
        do {
            let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            return documentsDirectory.appendingPathComponent(Constants.downloadsDirectoryName, isDirectory: true)
        } catch {
            os_log("Failed to create downloads directory: %s", type: .debug, error.localizedDescription)
            let temporaryDirectory = FileManager.default.temporaryDirectory
            return temporaryDirectory.appendingPathComponent(Constants.downloadsDirectoryName, isDirectory: true)
        }
    }
    
    var downloadsDirectoryFiles: [URL] {
        let contents = (try? FileManager.default.contentsOfDirectory(at: downloadsDirectory,
                                                                     includingPropertiesForKeys: nil,
                                                                     options: .skipsHiddenFiles)) ?? []
        return contents.filter { !$0.hasDirectoryPath }
    }
    
    init(_ notificationCenter: NotificationCenter = NotificationCenter.default) {
        self.notificationCenter = notificationCenter
        createDownloadsDirectoryIfNeeded()
        os_log("Downloads directory location %s", type: .debug, downloadsDirectory.absoluteString)
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

    func makeDownload(response: URLResponse,
                      suggestedFilename: String? = nil,
                      downloadSession: DownloadSession? = nil,
                      cookieStore: WKHTTPCookieStore? = nil,
                      temporary: Bool? = nil) -> Download? {

        guard let metaData = downloadMetaData(for: response, suggestedFilename: suggestedFilename),
              let url = response.url
        else { return nil }

        let temporaryFile: Bool
        if let temporary = temporary {
            temporaryFile = temporary
        } else {
            temporaryFile = FilePreviewHelper.canAutoPreviewMIMEType(metaData.mimeType)
        }

        let session: DownloadSession
        if let downloadSession = downloadSession {
            session = downloadSession
        } else {
            session = URLDownloadSession(metaData.url, cookieStore: cookieStore)
        }

        let download = Download(url: url,
                                filename: metaData.filename,
                                mimeType: metaData.mimeType,
                                temporary: temporaryFile,
                                downloadSession: session,
                                delegate: self)

        downloadList.insert(download)
        return download
    }

    func makeDownload(navigationResponse: WKNavigationResponse,
                      suggestedFilename: String? = nil,
                      downloadSession: DownloadSession? = nil,
                      cookieStore: WKHTTPCookieStore? = nil,
                      temporary: Bool? = nil) -> Download? {
        makeDownload(response: navigationResponse.response,
                     suggestedFilename: suggestedFilename,
                     downloadSession: downloadSession,
                     cookieStore: cookieStore,
                     temporary: temporary)
    }
    
    func downloadMetaData(for response: URLResponse, suggestedFilename: String? = nil) -> DownloadMetadata? {
        let filename = filename(forSuggestedFilename: suggestedFilename ?? response.suggestedFilename, mimeType: response.mimeType)
        return DownloadMetadata(response, filename: filename)
    }
    
    func startDownload(_ download: Download, completion: Download.Completion? = nil) {
        download.completionBlock = completion
        notificationCenter.post(name: .downloadStarted, object: nil, userInfo: [UserInfoKeys.download: download])
        download.start()
    }
    
    func cancelDownload(_ download: Download) {
        download.cancel()
    }
    
    func cancelAllDownloads() {
        downloadList.forEach { $0.cancel() }
    }
    
    func markAllDownloadsSeen() {
        unseenDownloadsAvailable = false
    }

    private func move(_ download: Download, toPath path: URL) {
        guard let location = download.location else { return }
         do {
             let newPath = path.appendingPathComponent(download.filename)
             try? FileManager.default.removeItem(at: newPath)
             try FileManager.default.moveItem(at: location, to: newPath)
             download.location = newPath
         } catch {
             os_log("Error moving file to downloads directory: %s", type: .debug, error.localizedDescription)
         }
    }
    
    private func moveToDownloadDirectortIfNeeded(_ download: Download) {
        guard !download.temporary else { return }
        move(download, toPath: downloadsDirectory)
    }
}

// MARK: - Filename Methods

extension DownloadManager {
    
    private func convertToUniqueFilename(_ filename: String) -> String {
        let downloadingFilenames = Set(downloadList.map { $0.filename })
        let downloadedFilenames = Set(downloadsDirectoryFiles.map { $0.lastPathComponent })
        let list = downloadingFilenames.union(downloadedFilenames)
        
        var fileExtension = downloadsDirectory.appendingPathComponent(filename).pathExtension
        fileExtension = fileExtension.count > 0 ? ".\(fileExtension)" : ""
        
        let filePrefix = filename.dropping(suffix: fileExtension)

        var counter: Int = 0
        var newFilename: String

        repeat {
            newFilename = counter > 0 ? "\(filePrefix) \(counter)\(fileExtension)" : filename
            counter += 1
        } while list.contains(newFilename)

        return newFilename
    }
    
    private func filename(forSuggestedFilename suggestedFilename: String?, mimeType: String?) -> String {
        let filename = sanitizeFilename(suggestedFilename, mimeType: mimeType)
        return convertToUniqueFilename(filename)
    }
    
    // https://app.asana.com/0/0/1201734618649839/f
    private func sanitizeFilename(_ originalFilename: String?, mimeType: String?) -> String {
        var filename = originalFilename ?? "unknown"

        if let mimeType = mimeType,
           let utType = UTType(mimeType: mimeType),
           UTType(filenameExtension: (filename as NSString).pathExtension) != utType,
           let pathExtension = utType.preferredFilenameExtension {
            filename.append("." + pathExtension)
        }

        let allowedCharacterSet = CharacterSet.alphanumerics.union(CharacterSet.punctuationCharacters)
        return filename.components(separatedBy: allowedCharacterSet.inverted).joined()
    }
}

// MARK: - Directory monitoring

extension DownloadManager {
    
    func startMonitoringDownloadsDirectoryChanges() {
        stopMonitoringDownloadsDirectoryChanges()
        
        downloadsDirectoryMonitor = DirectoryMonitor(directory: downloadsDirectory)
        downloadsDirectoryMonitor?.delegate = self
        try? downloadsDirectoryMonitor?.start()
    }
    
    func stopMonitoringDownloadsDirectoryChanges() {
        downloadsDirectoryMonitor?.stop()
        downloadsDirectoryMonitor = nil
    }
}

extension DownloadManager: DownloadDelegate {
    func downloadDidFinish(_ download: Download, error: Error?) {
        moveToDownloadDirectortIfNeeded(download)
        var userInfo: [AnyHashable: Any] = [UserInfoKeys.download: download]
        if let error = error {
            userInfo[UserInfoKeys.error] = error
        } else if !download.temporary {
            unseenDownloadsAvailable = true
        }
        
        downloadList.remove(download)
        
        notificationCenter.post(name: .downloadFinished, object: nil, userInfo: userInfo)
    }
}

extension DownloadManager: DirectoryMonitorDelegate {
    func didChange(directoryMonitor: DirectoryMonitor, added: Set<URL>, removed: Set<URL>) {
        notificationCenter.post(name: .downloadsDirectoryChanged, object: nil, userInfo: nil)
    }
}

extension NSNotification.Name {
    static let downloadStarted: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.notification.downloadStarted")
    static let downloadFinished: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.notification.downloadFinished")
    static let downloadsDirectoryChanged: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.notification.downloadsDirectoryChanged")
}
