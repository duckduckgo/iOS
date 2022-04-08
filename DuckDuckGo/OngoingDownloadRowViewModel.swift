//
//  OngoingDownloadRowViewModel.swift
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

class OngoingDownloadRowViewModel: DownloadsListRowViewModel {
    @Published var fileSize: String = ""
    @Published var progress: Float = 0.0
    var isTotalSizeKnown: Bool
    
    private var subscribers: Set<AnyCancellable> = []
    
    init(download: Download) {
        isTotalSizeKnown = download.totalBytesExpectedToWrite > 0
        super.init(filename: download.filename)
        subscribeToUpdates(from: download)
    }
    
    private func subscribeToUpdates(from download: Download) {
        let totalSize = download.totalBytesExpectedToWrite
        
        download.$totalBytesWritten
            .throttle(for: .milliseconds(1000), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] currentSize in
                let currentSizeString = DownloadsListRowViewModel.byteCountFormatter.string(fromByteCount: currentSize)
                
                if totalSize > 0 {
                    let totalSizeString = DownloadsListRowViewModel.byteCountFormatter.string(fromByteCount: totalSize)
                    self?.fileSize = UserText.downloadProgressMessage(currentSize: currentSizeString, totalSize: totalSizeString)
                } else {
                    self?.fileSize = UserText.downloadProgressMessageForUnknownTotalSize(currentSize: currentSizeString)
                }
            }.store(in: &subscribers)
        
        download.$totalBytesWritten
            .sink { [weak self] currentSize in
                self?.progress = Float(currentSize)/Float(totalSize)
            }.store(in: &subscribers)
    }
}
