//
//  AppTPActivityView.swift
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
import Core

struct AppTPActivityView: View {
    @ObservedObject var viewModel: AppTrackingProtectionListModel
    
    var body: some View {
        ScrollView {
            LazyVStack {
                // TODO: VPN toggle
                
                ForEach(viewModel.sections, id: \.name) { section in
                    Section(header: Text(section.name)) {
                        ForEach(section.objects as? [AppTrackerEntity] ?? []) { tracker in
                            Text(tracker.domain)
                        }
                    }
                }
            }
        }
    }
}
