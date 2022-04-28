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
    let viewModel: AutofillLoginListViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.items) { item in
                Section {
                    NavigationLink(destination: Text(item.title)) {
                        HStack {
                            Image(systemName: "globe")
                            VStack(alignment: .leading) {
                                Text(item.title)
                                Text(item.subtitle)
                            }
                        }
                    }
                } header: {
                    Text("Test")
                }
            }.listStyle(.insetGrouped)
        }.navigationTitle("Autofill Logins")
    }
}

@available(iOS 14.0, *)
struct AutofillLoginListView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = try! AutofillLoginListViewModel()
        AutofillLoginListView(viewModel: viewModel)
    }
}
