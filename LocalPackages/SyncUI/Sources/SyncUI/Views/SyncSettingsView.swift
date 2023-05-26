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

    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

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
    func deviceTypeImage(_ device: SyncSettingsViewModel.Device) -> some View {
        let image = UIImage(named: "SyncDeviceType_\(device.type)") ?? UIImage(named: "SyncDeviceType_phone")!
        Image(uiImage: image)
            .foregroundColor(.primary)
    }

    @State var selectedDevice: SyncSettingsViewModel.Device?

    @ViewBuilder
    func devices() -> some View {
        Section {
            if model.devices.isEmpty {
                ProgressView()
                    .padding()
            }

            ForEach(model.devices) { device in
                Button {
                    selectedDevice = device
                } label: {
                    HStack {
                        deviceTypeImage(device)
                        Text(device.name)
                            .foregroundColor(.primary)
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
        .sheet(item: $selectedDevice) { device in
            Group {
                if device.isThisDevice {
                    EditDeviceView(model: model.createEditDeviceModel(device))
                } else {
                    RemoveDeviceView(model: model.createRemoveDeviceModel(device))
                }
            }
            .modifier {
                if #available(iOS 16.0, *) {
                    $0.presentationDetents([.medium])
                } else {
                    $0
                }
            }
        }
        .onReceive(timer) { _ in
            if selectedDevice == nil {
                model.delegate?.refreshDevices(clearDevices: false)
            }
        }

    }

    @ViewBuilder
    func syncNewDevice() -> some View {
        Section {

            // Appears off center because the list is padding the trailing to make space for the accessory
            VStack(spacing: 0) {
                QRCodeView(string: model.recoveryCode, size: 192, style: .dark)
                    .padding(.bottom, 32)
                    .padding(.top, 16)

                Text(UserText.settingsNewDeviceInstructions)
                    .font(.system(size: 15))
                    .lineLimit(nil)
                    .lineSpacing(1.2)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16)
            }

            NavigationLink(UserText.settingsShowCodeButton) {
                ShowCodeView(code: model.recoveryCode, copyCode: model.copyCode)
            }

            Button(UserText.settingsScanQRCodeButton) {
                model.scanQRCode()
            }
        } header: {
            Text("Sync New Device")
        }
    }

    @ViewBuilder
    func saveRecoveryPDF() -> some View {
        Section {
            Button(UserText.settingsSaveRecoveryPDFButton) {
                model.saveRecoveryPDF()
            }
        } footer: {
            Text(UserText.settingsRecoveryPDFWarning)
        }
    }

    @ViewBuilder
    func deleteAllData() -> some View {
        Section {
            Button(UserText.settingsDeleteAllButton) {
                model.deleteAllData()
            }
        }
    }

    @ViewBuilder
    func workInProgress() -> some View {
        Section {
            EmptyView()
        } footer: {
            VStack(alignment: .leading, spacing: 4) {
                Text("Work in Progress")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.black)

                // swiftlint:disable line_length
                Text("This feature is viewable to internal users only and is still being developed and tested. Currently you can create accounts, connect and manage devices, and sync bookmarks and favorites. **[More Info](https://app.asana.com/0/1201493110486074/1203756800930481/f)**")
                    .foregroundColor(.black)
                    .font(.system(size: 11, weight: .regular))
                // swiftlint:enable line_length
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).foregroundColor(.yellow))
            .padding(.bottom, 10)
        }

    }

    public var body: some View {
        List {
            workInProgress()

            syncToggle()

            if model.isSyncEnabled {
                devices()

                syncNewDevice()

                saveRecoveryPDF()

                deleteAllData()
            }
            
        }
        .navigationTitle(UserText.syncTitle)
        .applyListStyle()
        .environmentObject(model)

    }

}

// Extension to apply custom view modifier
extension View {
    @ViewBuilder func modifier(@ViewBuilder _ closure: (Self) -> some View) -> some View {
        closure(self)
    }
}
