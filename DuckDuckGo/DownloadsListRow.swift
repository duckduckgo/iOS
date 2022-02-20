//
//  DownloadsListRow.swift
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
import Combine

class DownloadsListRow: Identifiable, ObservableObject {
    
    var id: String { filename }
    let filename: String
    let type: DownloadItemType
    
    @Published var fileSize: String
    @Published var progress: Float = 0.0
    
    private var subscribers: Set<AnyCancellable> = []
    
    internal init(filename: String, fileSize: String, type: DownloadItemType) {
        self.filename = filename
        self.fileSize = fileSize
        self.type = type
    }
    
    func subscribeToUpdates(from download: Download) {
        let total = download.totalBytesExpectedToWrite
        download.$totalBytesWritten
            .throttle(for: .milliseconds(150), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] in
                self?.fileSize = DownloadsListViewModel.byteCountFormatter.string(fromByteCount: $0)
                print("\(self?.fileSize ?? "")")
                self?.progress = Float($0)/Float(total)
        }.store(in: &subscribers)
    }
}

extension DownloadsListRow: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(filename)
        hasher.combine(type)
    }
    
    public static func == (lhs: DownloadsListRow, rhs: DownloadsListRow) -> Bool {
        lhs.id == rhs.id
    }
}
