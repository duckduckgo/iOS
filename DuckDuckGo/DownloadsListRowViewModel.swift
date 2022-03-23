//
//  DownloadsListRowViewModel.swift
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

class DownloadsListRowViewModel: Identifiable, ObservableObject {
    
    var id: String { filename }
    let filename: String
    
    internal init(filename: String) {
        self.filename = filename
    }
}

extension DownloadsListRowViewModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(filename)
    }
    
    public static func == (lhs: DownloadsListRowViewModel, rhs: DownloadsListRowViewModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension DownloadsListRowViewModel {
    static let byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = .useAll
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter
    }()
}
