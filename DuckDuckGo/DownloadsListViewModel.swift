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
            .sink { [weak self] in
                print("VM: model changed")
                print("       ongoing:\($0.ongoingDownloads.count) complete:\($0.completeDownloads.count)")
                
                self?.sections = DownloadsListSectioningHelper().makeSections(from: $0.ongoingDownloads + $0.completeDownloads)
            }
            .store(in: &subscribers)
    }
    
    deinit {
        print("VM: deinit")
    }
    
    // MARK: - Intents
    
    func cancelDownload(for rowModel: DownloadsListRow) {
        dataSource.cancelDownloadWithIdentifier(rowModel.id)
    }
    
    func deleteDownload(at offsets: IndexSet, in sectionIndex: Int) {
        print("VM: deleteItem(at:in:)")
        guard let rowIndex = offsets.first else { return }
        
        let item = sections[sectionIndex].rows[rowIndex]
        
        print("      (section:\(sectionIndex) row:\(rowIndex)")
        
        dataSource.deleteDownloadWithIdentifier(item.id)
        
        // warning present the toast
    }
    
    func deleteAllDownloads() {
        dataSource.deleteAllDownloads()
    }
}
