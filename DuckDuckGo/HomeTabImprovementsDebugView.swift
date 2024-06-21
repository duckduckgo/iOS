//
//  HomeTabImprovementsDebugView.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

struct HomeTabImprovementsDebugView: View {
    
    private var homeTabDebugging: HomeTabDebugging
    @State private var isFeatureEnabled: Bool
    private var localFlagEnabled: Binding<Bool> {
        Binding {
            homeTabDebugging.isLocalFlagEnabled
        } set: {
            homeTabDebugging.isLocalFlagEnabled = $0
            isFeatureEnabled = homeTabDebugging.isImprovedHomeTabEnabled
        }

    }

    init() {
        let manager = HomeTabManager()
        homeTabDebugging = manager
        isFeatureEnabled = manager.isImprovedHomeTabEnabled
    }

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Home tab improvements enabled")
                    Spacer()
                    if isFeatureEnabled {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(designSystemColor: .accent))
                    } else {
                        Image(systemName: "xmark")
                            .foregroundColor(Color.red40)
                    }
                }
            }

            Section {
                HStack {
                    Text("Feature flag enabled")
                    Spacer()
                    if homeTabDebugging.isFeatureFlagEnabled {
                        Image(systemName: "checkmark")
                            .renderingMode(.template)
                            .foregroundColor(Color(designSystemColor: .accent))
                    } else {
                        Image(systemName: "xmark")
                            .renderingMode(.template)
                            .foregroundColor(Color.red40)
                    }
                }
            } footer: {
                Text("Requires internal user")
            }

            Section {
                Toggle(isOn: localFlagEnabled,
                       label: {
                    Text("Local setting enabled")
                })
            }
        }
    }
}

#Preview {
    HomeTabImprovementsDebugView()
}
