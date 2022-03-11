//
//  DownloadsListSectionViewModel.swift
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

struct DownloadsListSectionViewModel: Identifiable, Hashable, Comparable {
    var id: String { header }
    var date: Date
    var header: String
    var rows: [DownloadsListRowViewModel]

    static func < (lhs: DownloadsListSectionViewModel, rhs: DownloadsListSectionViewModel) -> Bool {
        lhs.date < rhs.date
    }
}

extension DownloadsListSectionViewModel {
    static let monthNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter
    }()

    static let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "y"
        return formatter
    }()
}
