//
//  NewTabPageSectionsDebugView.swift
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

struct NewTabPageSectionsDebugView: View {
    
    private var newTabPageDebugging: NewTabPageDebugging
    private var appSettings: AppSettings
    
    @State private var isFeatureEnabled: Bool
    @State private var introMessageCount: Int
    
    private var localFlagEnabled: Binding<Bool> {
        Binding {
            newTabPageDebugging.isLocalFlagEnabled
        } set: {
            newTabPageDebugging.isLocalFlagEnabled = $0
            isFeatureEnabled = newTabPageDebugging.isNewTabPageSectionsEnabled
        }
    }
    
    private var introMessageEnabled: Binding<Bool> {
        Binding {
            appSettings.newTabPageIntroMessageEnabled ?? false
        } set: {
            appSettings.newTabPageIntroMessageEnabled = $0
        }
    }
    
    private var introMessageCountBinding: Binding<Int> {
        Binding {
            appSettings.newTabPageIntroMessageSeenCount
        } set: {
            appSettings.newTabPageIntroMessageSeenCount = $0
            introMessageCount = $0
        }
    }
    
    init() {
        let manager = NewTabPageManager()
        newTabPageDebugging = manager
        isFeatureEnabled = manager.isNewTabPageSectionsEnabled
        
        appSettings = AppDependencyProvider.shared.appSettings
        introMessageCount = appSettings.newTabPageIntroMessageSeenCount
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("New tab page sections enabled")
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
                    if newTabPageDebugging.isFeatureFlagEnabled {
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
            
            Section {
                Toggle(isOn: introMessageEnabled) {
                    Text("Intro message")
                }
                HStack {
                    Text("Message seen count")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(introMessageCount)")
                        .frame(alignment: .trailing)
                        .foregroundStyle(.secondary)
                }
                Button("Reset message seen count", action: {
                    introMessageCountBinding.wrappedValue = 0
                })
            } header: {
                Text("Other Settings")
            }
        }
        .applyInsetGroupedListStyle()
        .navigationTitle("New Tab Page Improvements")
    }
}

#Preview {
    NewTabPageSectionsDebugView()
}
