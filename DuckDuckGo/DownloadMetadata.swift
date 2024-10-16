//
//  DownloadMetadata.swift
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

struct DownloadMetadata {
    let filename: String
    let expectedContentLength: Int64
    let mimeTypeSource: String
    let mimeType: MIMEType
    let url: URL
    
    init?(_ response: URLResponse, filename: String) {
        guard let url = response.url else { return nil }

        self.filename = filename
        self.expectedContentLength = response.expectedContentLength
        self.mimeTypeSource = response.mimeType ?? ""
        self.mimeType = MIMEType(from: response.mimeType, fileExtension: filename.pathExtension)
        self.url = url
    }
}
