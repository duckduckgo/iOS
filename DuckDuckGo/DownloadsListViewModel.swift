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

class DownloadsListViewModel: ObservableObject {

    @Published private var model: DownloadsListModel = DownloadsListModel()
    private var sectionedModel: [DownloadsListSection] = []
    private var subscribers: Set<AnyCancellable> = []
        
    init() {
        $model.sink { _ in
            self.resetCachedSectionedModel()
        }.store(in: &subscribers)
    }
    
    private func resetCachedSectionedModel() {
        sectionedModel = []
    }

    var sections: [DownloadsListSection] {
        if sectionedModel.isEmpty {
            sectionedModel = makeSections(from: model.downloads)
        }
        
        return sectionedModel
    }
    
    private func makeSections(from downloads: [DownloadItem]) -> [DownloadsListSection] {
        print("VM: makeSections(from:)")
        let downloadsGroupedByDate: [Date: [DownloadItem]] = Dictionary(grouping: downloads, by: {
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
    
    private func makeRow(from download: DownloadItem) -> DownloadsListRow {
        DownloadsListRow(filename: download.filename,
                         fileSize: Self.byteCountFormatter.string(fromByteCount: Int64(download.fileSize)))
    }
    
    // MARK: - Intents
    
    func deleteItem(at offsets: IndexSet, in sectionIndex: Int) {
        print("VM: deleteItem(at:in:)")
        guard let index = offsets.first else { return }
        
        let item = sections[sectionIndex].rows[index]
        model.deleteItemWithIdentifier(item.id)
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
    
    private static let byteCountFormatter: ByteCountFormatter = {
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

struct DownloadsListRow: Identifiable, Hashable {
    var id: String { filename }
    let filename: String
    let fileSize: String
}
