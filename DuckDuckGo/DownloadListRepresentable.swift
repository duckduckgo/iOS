//
//  DownloadListRepresentable.swift
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

enum DownloadListRepresentableType {
    case ongoing
    case complete
}

protocol DownloadListRepresentable {
    var filename: String { get }
    var creationDate: Date { get }
    var fileSize: Int { get }
    var type: DownloadListRepresentableType { get }
    var filePath: String { get }
}

struct AnyDownloadListRepresentable: DownloadListRepresentable, Comparable {
    var wrappedRepresentable: DownloadListRepresentable

    init(_ representable: DownloadListRepresentable) {
      self.wrappedRepresentable = representable
    }
    
    public var id: String { filename }
    var filename: String { wrappedRepresentable.filename }
    var creationDate: Date { wrappedRepresentable.creationDate }
    var fileSize: Int { wrappedRepresentable.fileSize }
    var type: DownloadListRepresentableType { wrappedRepresentable.type }
    var filePath: String { wrappedRepresentable.filePath }
        
    static func < (lhs: AnyDownloadListRepresentable, rhs: AnyDownloadListRepresentable) -> Bool {
        lhs.creationDate < rhs.creationDate
    }
    
    static func == (lhs: AnyDownloadListRepresentable, rhs: AnyDownloadListRepresentable) -> Bool {
        lhs.filename == rhs.filename
    }
}

extension URL: DownloadListRepresentable {
    var filename: String { lastPathComponent }
    var creationDate: Date { creation ?? Date() }
    var fileSize: Int { (try? resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0 }
    var type: DownloadListRepresentableType { .complete }
    var filePath: String { self.path }
}

extension Download: DownloadListRepresentable {
    var creationDate: Date { date }
    var fileSize: Int { Int(totalBytesWritten) }
    var type: DownloadListRepresentableType { .ongoing }
    var filePath: String { location?.path ?? "" }
}
