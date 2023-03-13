//
//  SyncSettingsView.swift
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

public struct SyncSettingsView: View {

    @ObservedObject public var model: SyncSettingsViewModel

    public init(model: SyncSettingsViewModel) {
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
    func deviceTypeImage(_ device: SyncSettingsViewModel.Device) -> Image {
        let image = UIImage(named: "SyncDeviceType_\(device.type)") ?? UIImage(named: "SyncDeviceType_phone")!
        Image(uiImage: image)
    }

    @ViewBuilder
    func devices() -> some View {
        Section {
            ForEach(model.devices) { device in
                NavigationLink(destination: Text("WIP: \(device.name)")) {
                    HStack {
                        deviceTypeImage(device)
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

    @ViewBuilder
    func syncNewDevice() -> some View {
        Section {
            VStack(spacing: 0) {
                QRCodeView(string: UUID().uuidString, size: 192, style: .dark)
                    .padding(.bottom, 32)

                Text("Go to Settings > Sync in the DuckDuckGo App on a different device and scan to connect instantly")
                    .font(.system(size: 15))
                    .lineLimit(nil)
                    .lineSpacing(1.2)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16)

                HStack {
                    Button("Show Text Code") {
                        print("***")
                    }
                    Spacer()
                }
            }

            Button("Scan QR Code") {
                print("***")
            }
        } header: {
            Text("Sync New Device")
        }
    }

    @ViewBuilder
    func saveRecoveryPDF() -> some View {
        Section {
            Button("Save Recovery PDF") {
                print("***")
            }
        } footer: {
            Text("If you lose your device, you will need this recovery code to restore your synced data.")
        }
    }

    @ViewBuilder
    func disconnect() -> some View {
        Section {
            Button("Turn Off and Delete Server Data...") {
                print("***")
            }
        }
    }

    public var body: some View {
        List {
            syncToggle()

            if model.isSyncEnabled {
                devices()

                syncNewDevice()

                saveRecoveryPDF()

                disconnect()
            }
            
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Sync")
        .hideScrollContentBackground()
        .environmentObject(model)
    }

}
