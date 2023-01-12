//
//  SyncManagementView.swift
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

// https://www.figma.com/proto/mpFLwzGJFlbsmyD1JkAwt2/Sync-6?page-id=3744%3A50448&node-id=4101%3A70169&viewport=546%2C933%2C0.11&scaling=scale-down

struct SyncManagementView: View {

    @ObservedObject var model: SyncManagementViewModel

    @ViewBuilder
    func syncSetupView() -> some View {
        if let model = model.syncSetupViewModel {
            SyncSetupView(model: model)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    func syncToggle() -> some View {
        Section {
            HStack {
                Text("Sync")
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
            Text("Sync your bookmarks across your devices and save an encrypted backup on DuckDuckGo’s servers.")
        }.sheet(isPresented: $model.showSyncSetup) {
            syncSetupView()
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
                            Text("This Device")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        } header: {
            Text("Synced Devices")
        }
    }

    var body: some View {
        List {
            syncToggle()

            if !model.devices.isEmpty {
                devices()
            }
        }
        .navigationTitle("Sync")
        .environmentObject(model)
    }

}
