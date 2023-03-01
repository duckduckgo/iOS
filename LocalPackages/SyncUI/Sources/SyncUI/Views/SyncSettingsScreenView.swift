//
//  SyncSettingsScreenView.swift
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

public struct SyncSettingsScreenView: View {

    @ObservedObject public var model: SyncSettingsScreenViewModel

    public init(model: SyncSettingsScreenViewModel) {
        self.model = model
    }

    @ViewBuilder
    func syncToggle() -> some View {
        Section {
            HStack {
                Text(UserText.syncTitle)
                Spacer()

                if model.isBusy {
                    SwiftUI.ProgressView()
                } else {
                    Toggle("", isOn: Binding(get: {
                        return model.isSyncEnabled
                    }, set: { enabled in
                        if enabled {
                            model.enableSync()
                        } else {
                            model.disableSync()
                        }
                    }))
                }
            }
        } footer: {
            Text(UserText.syncSettingsInfo)
        }
    }

    @ViewBuilder
    func devices() -> some View {
        Section {
            ForEach(model.devices) { device in
                NavigationLink(destination: Text("WIP: \(device.name)")) {
                    HStack {
                        Text(device.name)
                        Spacer()
                        if device.isThisDevice {
                            Text(UserText.thisDevice)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        } header: {
            Text(UserText.connectedDevicesTitle)
        }
    }

    public var body: some View {
        List {
            syncToggle()

            if !model.devices.isEmpty {
                devices()
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Sync")
        .hideScrollContentBackground()
        .environmentObject(model)
    }

}
