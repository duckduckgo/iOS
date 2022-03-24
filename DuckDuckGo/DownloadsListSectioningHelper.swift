//
//  DownloadsListSectioningHelper.swift
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

class DownloadsListSectioningHelper {
    
    private struct RelativeDateRange: Hashable, Comparable {
        let date: Date
        let displayName: String
        
        static func < (lhs: RelativeDateRange, rhs: RelativeDateRange) -> Bool {
            lhs.date < rhs.date
        }
    }
    
    private let calendar = Calendar.current
    private let today: Date
    private let yesterday: Date
    private let pastWeek: Date
    private let pastMonth: Date
    private let yearAgo: Date
    
    init(date: Date = Date()) {
        today = calendar.startOfDay(for: date)
        yesterday = today.addingTimeInterval(.days(-1))
        pastWeek = today.addingTimeInterval(.days(-7))
        pastMonth = today.addingTimeInterval(.days(-30))
        yearAgo = calendar.date(byAdding: .year, value: -1, to: today)!
    }
    
    func makeSections(from downloads: [AnyDownloadListRepresentable]) -> [DownloadsListSectionViewModel] {

        let downloadsGroupedByRelativeDateRanges: [RelativeDateRange: [AnyDownloadListRepresentable]] = Dictionary(grouping: downloads, by: {
            
            let fileDate = $0.creationDate
            
            if fileDate > today {
                return RelativeDateRange(date: today, displayName: UserText.dateRangeToday)
            } else if fileDate > yesterday {
                return RelativeDateRange(date: yesterday, displayName: UserText.dateRangeYesterday)
            } else if fileDate > pastWeek {
                return RelativeDateRange(date: pastWeek, displayName: UserText.dateRangePastWeek)
            } else if fileDate > pastMonth {
                return RelativeDateRange(date: pastMonth, displayName: UserText.dateRangePastMonth)
            } else {
                if fileDate > yearAgo {
                    // by month
                    let components = calendar.dateComponents([.month, .year], from: fileDate)
                    let monthDate = calendar.date(from: components)!
                    
                    let monthString = DownloadsListSectionViewModel.monthNameFormatter.string(from: monthDate)
                    
                    return RelativeDateRange(date: monthDate, displayName: monthString)
                } else {
                    // by year
                    let components = calendar.dateComponents([.year], from: fileDate)
                    let yearDate = calendar.date(from: components)!
                    
                    let yearString = DownloadsListSectionViewModel.yearFormatter.string(from: yearDate)
                    
                    return RelativeDateRange(date: yearDate, displayName: yearString)
                }
            }
        })
        
        let sortedRelativeDateRanges = downloadsGroupedByRelativeDateRanges.map({ $0.key }).sorted(by: >)
        return sortedRelativeDateRanges.compactMap { relativeDateRange in
            guard let downloads = downloadsGroupedByRelativeDateRanges[relativeDateRange] else { return nil }

            return DownloadsListSectionViewModel(date: relativeDateRange.date,
                                        header: relativeDateRange.displayName,
                                        rows: downloads.sorted(by: >).map { makeRow(from: $0) })
        }
    }
    
    private func makeRow(from downloadRepresentable: AnyDownloadListRepresentable) -> DownloadsListRowViewModel {
        let row: DownloadsListRowViewModel
        
        switch downloadRepresentable.type {
        case .ongoing:
            guard let download = downloadRepresentable.wrappedRepresentable as? Download else { fatalError("Ongoing download should be Download") }
            row = OngoingDownloadRowViewModel(download: download)
        case .complete:
            guard let url = downloadRepresentable.wrappedRepresentable as? URL else { fatalError("Complete download should be URL") }
            row = CompleteDownloadRowViewModel(fileURL: url)
        }
        
        return row
    }
}
