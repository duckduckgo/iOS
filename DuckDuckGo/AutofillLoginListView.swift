//
//  AutofillLoginListView.swift
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

@available(iOS 14.0, *)
struct AutofillLoginListView: View {
    @ObservedObject var viewModel: AutofillLoginListViewModel
    var itemSelected: ((AutofillLoginListItemViewModel) -> Void)?
    
    var body: some View {
        List(viewModel.sections) { section in
            Section {
                ForEach(section.items) { item in
                    ImageTitleSubtitleListItemView(viewModel: item)
                        .onTapGesture {
                            self.selectItem(item)
                        }
                }
            } header: {
                Text(section.title)
            }
        }
        .listStyle(.insetGrouped)
    }
    
    func destinationView(with item: AutofillLoginListItemViewModel) -> some View {
        AutofillLoginDetailsView(viewModel: AutofillLoginDetailsViewModel(account: item.account))
    }
    
    private func selectItem(_ item: AutofillLoginListItemViewModel) {
        if let itemSelected = itemSelected {
            itemSelected(item)
        }
    }
}

@available(iOS 14.0, *)
struct AutofillLoginListView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = try! AutofillLoginListViewModel()
        AutofillLoginListView(viewModel: viewModel)
    }
}
