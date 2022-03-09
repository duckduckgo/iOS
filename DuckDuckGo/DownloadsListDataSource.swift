//
//  DownloadsListDataSource.swift
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

class DownloadsListDataSource {
    
    @Published var model: DownloadsListModel
    
    private var downloadManager = AppDependencyProvider.shared.downloadManager
    private var deleteDownloadsHelper = DownloadsDeleteHelper()
    
    private var bag: Set<AnyCancellable> = []
    
    init() {
        model = DownloadsListModel(ongoingDownloads: downloadManager.downloadList.filter { !$0.temporary }.map { AnyDownloadListRepresentable($0) },
                                   completeDownloads: downloadManager.downloadsDirectoryFiles.map { AnyDownloadListRepresentable($0) })
        downloadManager.startMonitoringDownloadsDirectoryChanges()
        setupChangeListeners()
    }
    
    deinit {
        downloadManager.stopMonitoringDownloadsDirectoryChanges()
        downloadManager.markAllDownloadsSeen()
    }
    
    private func setupChangeListeners() {
        let downloadStartedPublisher = NotificationCenter.default.publisher(for: .downloadStarted)
        let downloadFinishedPublisher = NotificationCenter.default.publisher(for: .downloadFinished)
        let downloadsDirectoryChangedPublisher = NotificationCenter.default.publisher(for: .downloadsDirectoryChanged)
        
        downloadsDirectoryChangedPublisher.merge(with: downloadStartedPublisher, downloadFinishedPublisher)
            .sink { [weak self] _ in
                self?.updateModel()
            }
            .store(in: &bag)
    }
    
    private func updateModel() {
        let ongoingDownloads = downloadManager.downloadList.filter { !$0.temporary }.map { AnyDownloadListRepresentable($0) }
        let completeDownloads = downloadManager.downloadsDirectoryFiles.map { AnyDownloadListRepresentable($0) }
        
        model.update(ongoingDownloads: ongoingDownloads,
                     completeDownloads: completeDownloads)
    }
    
    func cancelDownloadWithIdentifier(_ identifier: String) {
        guard let download = downloadManager.downloadList.first(where: { $0.filename == identifier }) else { return }
        
        downloadManager.cancelDownload(download)
    }
    
    func deleteDownloadWithIdentifier(_ identifier: String, completionHandler: DeleteHandler) {
        guard let downloadToDelete = model.completeDownloads.first(where: { $0.id == identifier }) else { return }

        deleteDownloadsHelper.deleteDownloads(atPaths: [downloadToDelete.filePath],
                                              completionHandler: completionHandler)
    }
    
    func deleteAllDownloads(completionHandler: DeleteHandler) {
        let completeDownloadsFilePaths = model.completeDownloads.map { $0.filePath }
        
        deleteDownloadsHelper.deleteDownloads(atPaths: completeDownloadsFilePaths,
                                              completionHandler: completionHandler)
    }
}
