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
    private let introDataStorage: NewTabPageIntroDataStoring

    @State private var isFeatureEnabled: Bool
    @State private var introMessageCount: Int
    @State private var isIntroMessageInitialized: Bool

    private var localFlagEnabled: Binding<Bool> {
        Binding {
            newTabPageDebugging.isLocalFlagEnabled
        } set: {
            newTabPageDebugging.isLocalFlagEnabled = $0
            isFeatureEnabled = newTabPageDebugging.isNewTabPageSectionsEnabled
            isIntroMessageInitialized = introDataStorage.newTabPageIntroMessageEnabled != nil
        }
    }
    
    private var introMessageEnabled: Binding<Bool> {
        Binding {
            introDataStorage.newTabPageIntroMessageEnabled ?? false
        } set: {
            introDataStorage.newTabPageIntroMessageEnabled = $0
            isIntroMessageInitialized = introDataStorage.newTabPageIntroMessageEnabled != nil
        }
    }
    
    private var introMessageCountBinding: Binding<Int> {
        Binding {
            introDataStorage.newTabPageIntroMessageSeenCount
        } set: {
            introDataStorage.newTabPageIntroMessageSeenCount = $0
            introMessageCount = $0
        }
    }
    
    init() {
        let manager = NewTabPageManager()
        newTabPageDebugging = manager
        isFeatureEnabled = manager.isNewTabPageSectionsEnabled

        introDataStorage = NewTabPageIntroDataUserDefaultsStorage()
        introMessageCount = introDataStorage.newTabPageIntroMessageSeenCount
        isIntroMessageInitialized = introDataStorage.newTabPageIntroMessageEnabled != nil
    }
    
    var body: some View {
        List {
            Section {
                Toggle(isOn: localFlagEnabled,
                       label: {
                    Text(verbatim: "Local setting enabled")
                })
            } header: {
                Text(verbatim: "Feature settings")
            } footer: {
                Text(verbatim: "Requires internal user flag set to have an effect.")
            }

            Section {
                HStack {
                    Text(verbatim: "New tab page sections enabled")
                    Spacer()
                    if isFeatureEnabled {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(designSystemColor: .accent))
                    } else {
                        Image(systemName: "xmark")
                            .foregroundColor(Color.red40)
                    }
                }

                HStack {
                    VStack {
                        Text(verbatim: "Remote feature flag enabled")
                    }
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
            }

            Section {
                HStack {
                    Text(verbatim: "Intro message initialized")
                    Spacer()
                    Text(verbatim: isIntroMessageInitialized.description.localizedCapitalized)
                        .frame(alignment: .trailing)
                        .foregroundStyle(.secondary)
                }
                
                Toggle(isOn: introMessageEnabled) {
                    Text(verbatim: "Intro message")
                }
                
                HStack {
                    Text(verbatim: "Message seen count")
                    Spacer()
                    Text(verbatim: "\(introMessageCount)")
                        .frame(alignment: .trailing)
                        .foregroundStyle(.secondary)
                }
                Button("Reset message seen count", action: {
                    introMessageCountBinding.wrappedValue = 0
                })

                Button("Reset intro message", action: {
                    introDataStorage.newTabPageIntroMessageEnabled = nil
                    introMessageCountBinding.wrappedValue = 0
                    isIntroMessageInitialized = false
                })
            } header: {
                Text(verbatim: "Intro message")
            }
        }
        .applyInsetGroupedListStyle()
        .navigationTitle("New Tab Page Improvements")
    }
}

#Preview {
    NewTabPageSectionsDebugView()
}
