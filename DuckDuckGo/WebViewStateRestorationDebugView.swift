//
//  WebViewStateRestorationDebugView.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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
import AIChat

struct WebViewStateRestorationDebugView: View {
    @StateObject private var viewModel = WebViewStateRestorationDebugViewModel()

    private var localFlagEnabled: Binding<Bool> {
        Binding {
            viewModel.isLocalFlagEnabled
        } set: {
            viewModel.setLocalFlagEnabled($0)
        }
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
                Text(verbatim: "Requires internal user flag set to have an effect. Restart is required after modifying the flag.")
            }

            Section {
                HStack {
                    Text(verbatim: "WebView state restoration enabled")
                    Spacer()
                    if viewModel.isFeatureEnabled {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(designSystemColor: .accent))
                    } else {
                        Image(systemName: "xmark")
                            .foregroundColor(Color.red40)
                    }
                }
            }

            Section {
                ForEach(viewModel.allFiles, id: \.self) { file in
                    Text(verbatim: file.lastPathComponent)
                }
            } header: {
                Text(verbatim: "All cache files")
            } footer: {
                if !viewModel.allFiles.isEmpty {
                    Button {
                        viewModel.clearCache()
                    } label: {
                        Text(verbatim: "Delete all cache files")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .navigationTitle(Text(verbatim: "WebView State Restoration"))
    }
}

private final class WebViewStateRestorationDebugViewModel: ObservableObject {
    private var debugSettings = AIChatDebugSettings()
    private let interactionStateSource = TabInteractionStateDiskSource()
    private var featureManager = WebViewStateRestorationManager()

    @Published private(set) var isFeatureEnabled: Bool
    @Published private(set) var allFiles: [URL]
    @Published private(set) var isLocalFlagEnabled: Bool

    init() {
        isFeatureEnabled = featureManager.isFeatureEnabled
        isLocalFlagEnabled = featureManager.isLocalOverrideEnabled
        allFiles = (try? interactionStateSource?.allCacheFiles()) ?? []
    }

    func clearCache() {
        interactionStateSource?.removeAll(excluding: [])
        allFiles = (try? interactionStateSource?.allCacheFiles()) ?? []
    }

    func setLocalFlagEnabled(_ enabled: Bool) {
        featureManager.isLocalOverrideEnabled = enabled

        isFeatureEnabled = featureManager.isFeatureEnabled
        isLocalFlagEnabled = featureManager.isLocalOverrideEnabled
    }
}
