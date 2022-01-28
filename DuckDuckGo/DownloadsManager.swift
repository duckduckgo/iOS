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
import WebKit

class DownloadsManager {
    
    struct UserInfoKeys {
        static let download = "com.duckduckgo.com.userInfoKey.download"
        static let error = "com.duckduckgo.com.userInfoKey.error"
    }
    
    private(set) var downloadList = Set<Download>()
    private var downloadsFolder: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        } catch {
            return FileManager.default.temporaryDirectory
        }
    }()
    
    func setupDownload(_ navigationResponse: WKNavigationResponse, cookieStore: WKHTTPCookieStore) -> Download? {
        
        guard let mimeType = navigationResponse.response.mimeType,
              let url = navigationResponse.response.url else {
                  return nil
        }
        let fileName = navigationResponse.response.suggestedFilename ?? "unknown"

        let type = MIMEType(rawValue: mimeType) ?? .unknown
        let temporary: Bool
        
        switch type {
        case .reality, .usdz, .passbook:
            temporary = true
        default:
            temporary = false
        }
        
        let session = DownloadSession(url, cookieStore: cookieStore)
        
        return Download(downloadSession: session,
                        mimeType: type,
                        fileName: fileName,
                        temporary: temporary,
                        delegate: self)
    }
    
    func startDownload(_ download: Download) {
        downloadList.insert(download)
        download.start()
        NotificationCenter.default.post(name: .downloadStarted, object: nil, userInfo: [UserInfoKeys.download: download])
    }
    
    private func move(_ download: Download, toPath path: URL) {
        guard let location = download.location else { return }
         do {
             let newPath = path.appendingPathComponent(download.filename)
             try? FileManager.default.removeItem(at: newPath)
             try FileManager.default.moveItem(at: location, to: newPath)
         } catch {
             print("Error \(error)")
         }
    }
    
    private func moveToDownloadFolderIfNecessary(_ download: Download) {
        guard !download.temporary else { return }
        move(download, toPath: downloadsFolder)
    }
}

extension DownloadsManager: DownloadDelegate {
    func downloadDidFinish(_ download: Download, error: Error?) {
        moveToDownloadFolderIfNecessary(download)
        var userInfo: [AnyHashable: Any] = [UserInfoKeys.download: download]
        if let error = error {
            userInfo[UserInfoKeys.error] = error
        }
        NotificationCenter.default.post(name: .downloadFinished, object: nil, userInfo: userInfo)
        downloadList.remove(download)
    }
}

extension NSNotification.Name {
    static let downloadStarted: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.notification.downloadStarted")
    static let downloadFinished: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.notification.downloadFinished")
}
