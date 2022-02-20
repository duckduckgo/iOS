//
//  DownloadsListViewModel.swift
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

import SwiftUI
import Combine
import Core

class DownloadsListViewModel: ObservableObject {

    @Published var sections: [DownloadsListSection] = []
    
    private let dataSource: DownloadsListDataSource
    private var subscribers: Set<AnyCancellable> = []
    
    init(dataSource: DownloadsListDataSource) {
        print("VM: init")
        
        self.dataSource = dataSource
        
        dataSource.$model
            .throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] in
                print("VM: model changed")
                print("    ongoing:\($0.ongoingDownloads.count) complete:\($0.completeDownloads.count)")
                
                self?.sections = (self?.makeSections(from: $0.ongoingDownloads + $0.completeDownloads))!
            }
            .store(in: &subscribers)
        
        startListening()
    }
    
    deinit {
        print("VM: deinit")
        stopListening()
    }
    
    private func makeSections(from downloads: [AnyDownloadListRepresentable]) -> [DownloadsListSection] {
        let downloadsGroupedByDate: [Date: [AnyDownloadListRepresentable]] = Dictionary(grouping: downloads, by: {
            Calendar.current.startOfDay(for: $0.creationDate)
        })
        
        let sortedDates = downloadsGroupedByDate.map({ $0.key }).sorted(by: >)
        
        return sortedDates.compactMap { date in
            guard let downloadsByDate = downloadsGroupedByDate[date] else { return nil }
                
            return DownloadsListSection(date: date,
                                        header: Self.dateFormatter.string(from: date),
                                        rows: downloadsByDate.sorted(by: >).map { makeRow(from: $0) })
        }
    }
    
    private func makeRow(from download: AnyDownloadListRepresentable) -> DownloadsListRow {
        let row = DownloadsListRow(filename: download.filename,
                                   fileSize: Self.byteCountFormatter.string(fromByteCount: Int64(download.fileSize)),
                                   type: download.type)
        
        if let d = download.wrappedRepresentable as? Download {
            row.subscribeToUpdates(from: d)
        }
        
        return row
    }
    
    private func startListening() {
        NotificationCenter.default.addObserver(self, selector: #selector(ongoingDownloadsChanged(notification:)),
                                               name: .downloadStarted, object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(ongoingDownloadsChanged(notification:)),
//                                               name: .downloadFinished, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(completeDownloadsChanged(notification:)),
                                               name: .downloadsDirectoryChanged, object: nil)
        
        let downloadManager = AppDependencyProvider.shared.downloadsManager
        downloadManager.startMonitoringDownloadsDirectoryChanges()
    }
    
    private func stopListening() {
        let downloadManager = AppDependencyProvider.shared.downloadsManager
        downloadManager.stopMonitoringDownloadsDirectoryChanges()
    }
    
    @objc func ongoingDownloadsChanged(notification: Notification) {
        print("- ongoingDownoloadsChanged")
        dataSource.refetchOngoingDownloads()
    }
    
    @objc func completeDownloadsChanged(notification: Notification) {
        print("- completeDownoloadsChanged")
        dataSource.refetchAllDownloads()
    }
    
    // MARK: - Intents
    
    func deleteDownload(at offsets: IndexSet, in sectionIndex: Int) {
        print("VM: deleteItem(at:in:)")
        guard let index = offsets.first else { return }
        
        let item = sections[sectionIndex].rows[index]
        dataSource.deleteDownloadWithIdentifier(item.id)
        
        // present the toast
    }

}

extension DownloadsListViewModel {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        
        return formatter
    }()
    
    static let byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = .useAll
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true
        
        return formatter
    }()
}
