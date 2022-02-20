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

    @Published private var model: DownloadsListModel
    private var sectionedModel: [DownloadsListSection] = []
    private var subscribers: Set<AnyCancellable> = []

    init(model: DownloadsListModel) {
        print("VM: init")
        
        self.model = model
        
        $model.sink { [weak self] _ in
            self?.resetCachedSectionedModel()
        }.store(in: &subscribers)
        
        startListening()
    }
    
    deinit {
        print("VM: deinit")
        stopListening()
    }
    
    private func resetCachedSectionedModel() {
        sectionedModel = []
    }

    var sections: [DownloadsListSection] {
        if sectionedModel.isEmpty {
            sectionedModel = makeSections(from: model.ongoingDownloads + model.completeDownloads)
        }
        
        return sectionedModel
    }
    
    private func makeSections(from downloads: [AnyDownloadListRepresentable]) -> [DownloadsListSection] {
        print("VM: makeSections(from:)")
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
        print("ongoingDownoloadsChanged")
        model.refetchOngoingDownloads()
    }
    
    @objc func completeDownloadsChanged(notification: Notification) {
        print("completeDownoloadsChanged")
        model.refetchAllDownloads()
    }
    
    // MARK: - Intents
    
    func deleteDownload(at offsets: IndexSet, in sectionIndex: Int) {
        print("VM: deleteItem(at:in:)")
        guard let index = offsets.first else { return }
        
        let item = sections[sectionIndex].rows[index]
        model.deleteDownloadWithIdentifier(item.id)
        
        // present the toast
    }

}

extension DownloadsListViewModel {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        
        return formatter
    }()
    
    fileprivate static let byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = .useAll
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true
        
        return formatter
    }()
}

struct DownloadsListSection: Identifiable, Hashable, Comparable {
    var id: String { header }
    var date: Date
    var header: String
    var rows: [DownloadsListRow]

    static func < (lhs: DownloadsListSection, rhs: DownloadsListSection) -> Bool {
        lhs.date < rhs.date
    }
}

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
        download.$totalBytesWritten
            .throttle(for: .milliseconds(150), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] in
                self?.fileSize = DownloadsListViewModel.byteCountFormatter.string(fromByteCount: $0)
                print("\(self?.fileSize ?? "")")
                self?.progress = Float($0)/Float(download.totalBytesExpectedToWrite)
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
