//
//  DownloadItem.swift
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

struct DownloadItem: Hashable, Identifiable, Comparable {
    
    var id: String { filename }
    let filename: String
    let creationDate: Date
    let fileSize: Int
    
    var hidden: Bool = false
    
    internal init(filename: String, creationDate: Date = Date(), fileSize: Int = 0) {
        self.filename = filename
        self.creationDate = creationDate
        self.fileSize = fileSize
    }
    
    internal init(url: URL) {
        self.filename = url.lastPathComponent
        self.creationDate = url.creation ?? Date()
        self.fileSize = url.fileSize ?? 0
    }
    
    static func < (lhs: DownloadItem, rhs: DownloadItem) -> Bool {
        lhs.creationDate < rhs.creationDate
    }
    
}
