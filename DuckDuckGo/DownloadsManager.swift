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
    //private let downloadsFolder
    
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
        
        return Download(url,
                        mimeType: type,
                        fileName: fileName,
                        cookieStore: cookieStore,
                        temporary: temporary,
                        delegate: self)
    }
    
    func startDownload(_ download: Download) {
        downloadList.insert(download)
        download.start()
        NotificationCenter.default.post(name: .downloadStarted, object: nil, userInfo: [UserInfoKeys.download: download])
    }
    
    private func move(_ download: Download, toPath path: URL) {
        /*
         do {
             let newPath = oldPath.deletingLastPathComponent().appendingPathComponent(name)
             try? FileManager.default.removeItem(at: newPath)
             try FileManager.default.moveItem(at: oldPath, to: newPath)
             
             return newPath
         } catch {
             return nil
         }
         */
    }
    
    private func moveDownloadIfNecessary(_ download: Download) {
        guard !download.temporary else { return }
        
    }
}

extension DownloadsManager: DownloadDelegate {
    func downloadDidFinish(_ download: Download, error: Error?) {
        moveDownloadIfNecessary(download)
        var userInfo:[AnyHashable: Any] = [UserInfoKeys.download: download]
        if let error = error {
            userInfo[UserInfoKeys.error] = error
        }
        NotificationCenter.default.post(name: .downloadFinished, object: nil, userInfo: userInfo)
        downloadList.remove(download)
    }
}
