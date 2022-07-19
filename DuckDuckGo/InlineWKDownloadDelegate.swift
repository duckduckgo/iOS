//
//  InlineWKDownloadDelegate.swift
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

@available(iOS 14.5, *)
final class InlineWKDownloadDelegate: NSObject, WKDownloadDelegate {

    var decideDestinationCallback: ((WKDownload, URLResponse, String, @escaping (URL?) -> Void) -> Void)?
    var downloadDidFinishCallback: ((WKDownload) -> Void)?
    var downloadDidFailCallback: ((WKDownload, Error, Data?) -> Void)?

    func download(_ download: WKDownload,
                  decideDestinationUsing response: URLResponse,
                  suggestedFilename: String,
                  completionHandler: @escaping (URL?) -> Void) {
        self.decideDestinationCallback?(download, response, suggestedFilename, completionHandler)
    }

    func downloadDidFinish(_ download: WKDownload) {
        downloadDidFinishCallback?(download)
    }

    func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        downloadDidFailCallback?(download, error, resumeData)
    }

}
