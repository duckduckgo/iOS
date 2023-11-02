//
//  SyncTabsHomeView.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

struct SyncTabsHomeView: View {

    @ObservedObject var viewModel: SyncTabsHomeViewModel

    var body: some View {
        List {
            ForEach(viewModel.deviceTabs) { deviceTabs in
                Section(header: Text(deviceTabs.deviceId)) {
                    ForEach(deviceTabs.deviceTabs) { tabInfo in
                        Button {
                            viewModel.open(tabInfo.url)
                        } label: {
                            Text(tabInfo.title.isEmpty ? tabInfo.url.absoluteString : tabInfo.title)
                                .lineLimit(1)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, 0)
        .frame(minHeight: 200, maxHeight: .infinity)
    }
}
