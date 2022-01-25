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

protocol DownloadManagerDelegate: AnyObject {
    func downloadManager(_ downloadManager: DownloadsManager, didFinish download: Download)
}

class DownloadsManager {
    weak var delegate: DownloadManagerDelegate?
    private(set) var downloadList = Set<Download>()
    
    func download(_ navigationResponse: WKNavigationResponse, cookieStore: WKHTTPCookieStore) -> WKNavigationResponsePolicy {
        guard let mimeType = navigationResponse.response.mimeType else {
            return .cancel
        }

        let download = Download(navigationResponse.response.url!,
                                mimeType: mimeType,
                                fileName: navigationResponse.response.suggestedFilename!,
                                cookieStore: cookieStore ,
                                delegate: self)
        
        downloadList.insert(download)
        download.start()
        
        return .cancel
    }
}

extension DownloadsManager: DownloadDelegate {
    func downloadDidFinish(_ download: Download) {
        delegate?.downloadManager(self, didFinish: download)
        downloadList.remove(download)
    }
}
