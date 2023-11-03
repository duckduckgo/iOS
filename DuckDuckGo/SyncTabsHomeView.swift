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
        VStack(alignment: .leading, spacing: 0) {
            ForEach(viewModel.deviceTabs) { deviceTabs in
                Text(deviceTabs.deviceId)
                    .font(.system(size: 15).bold())
                    .foregroundColor(Color(designSystemColor: .textSecondary))
                Spacer(minLength: 8)
                Rectangle()
                    .foregroundColor(Color(designSystemColor: .lines))
                    .frame(maxWidth: .infinity, idealHeight: 1)
                Spacer(minLength: 12)
                ForEach(deviceTabs.deviceTabs) { tabInfo in
                    Button {
                        viewModel.open(tabInfo.url)
                    } label: {
                        Text(tabInfo.title.isEmpty ? tabInfo.url.absoluteString : tabInfo.title)
                            .lineLimit(1)
                            .padding(.leading, 12)
                            .font(.system(size: 15))
                    }
                    .buttonStyle(.plain)
                    .frame(height: 44)
                    Rectangle()
                        .foregroundColor(Color(designSystemColor: .container))
                        .frame(maxWidth: .infinity, idealHeight: 1)
                        .padding(.leading, 12)
                }
            }
        }
//        List {
//            ForEach(viewModel.deviceTabs) { deviceTabs in
//                Section(header: Text(deviceTabs.deviceId)) {
//                    ForEach(deviceTabs.deviceTabs) { tabInfo in
//                        Button {
//                            viewModel.open(tabInfo.url)
//                        } label: {
//                            Text(tabInfo.title.isEmpty ? tabInfo.url.absoluteString : tabInfo.title)
//                                .lineLimit(1)
//                        }
//                        .buttonStyle(.plain)
//                    }
//                }
//            }
//        }
//        .listStyle(.plain)
//        .padding(.horizontal, 0)
//        .frame(minHeight: 200, maxHeight: .infinity)
    }
}
