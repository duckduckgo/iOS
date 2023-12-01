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
import DesignResourcesKit

public struct SyncSettingsView: View {

    @ObservedObject public var model: SyncSettingsViewModel

    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    @State var isSyncWithSetUpSheetVisible = false
    @State var isRecoverSyncedDataSheetVisible = false

    public init(model: SyncSettingsViewModel) {
        self.model = model
    }

    public var body: some View {
        if model.isSyncingDevices {
            SwiftUI.ProgressView()
                .onReceive(timer) { _ in
                    if selectedDevice == nil {
                        model.delegate?.refreshDevices(clearDevices: false)
                    }
                }
        } else {
            List {

                if model.isSyncEnabled {
                    
                    turnOffSync()
                    
                    // Sync Paused Errors
                    if $model.isSyncBookmarksPaused.wrappedValue {
                        syncPaused(for: .bookmarks)
                    }
                    if $model.isSyncCredentialsPaused.wrappedValue {
                        syncPaused(for: .credentials)
                    }

                    devices()

                    options()

                    saveRecoveryPDF()
                    
                    deleteAllData()
                    
                } else {

                    syncWithAnotherDeviceView()

                    otherOptions()

                }
            }
            .navigationTitle(UserText.syncTitle)
            .applyListStyle()
            .environmentObject(model)
        }

    }

    @ViewBuilder
    func deviceTypeImage(_ device: SyncSettingsViewModel.Device) -> some View {
        let image = UIImage(named: "SyncDeviceType_\(device.type)") ?? UIImage(named: "SyncDeviceType_phone")!
        Image(uiImage: image)
            .foregroundColor(.primary)
    }

    @State var selectedDevice: SyncSettingsViewModel.Device?
}

// Sync Set up Views
extension SyncSettingsView {

    @ViewBuilder
    func syncWithAnotherDeviceView() -> some View {
        Section {
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 8) {
                    Image("Sync-Pair-96")
                    Text(UserText.syncWithAnotherDeviceTitle)
                        .daxTitle3()
                    Text(UserText.syncWithAnotherDeviceMessage)
                        .daxBodyRegular()
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(designSystemColor: .textPrimary))
                    Button(action: {
                        model.scanQRCode()
                    }, label: {
                        Text(UserText.syncWithAnotherDeviceButton)
                            .daxButton()
                            .foregroundColor(.white)
                            .frame(maxWidth: 310)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(designSystemColor: .accent))
                            )
                    })
                    .padding(.vertical, 16)
                }
                Spacer()
            }
        } footer: {
            HStack {
                Spacer()
                Text(UserText.syncWithAnotherDeviceFooter)
                    .daxFootnoteRegular()
                    .multilineTextAlignment(.center)
                Spacer()
            }
        }
    }

    @ViewBuilder
    func otherOptions() -> some View {
        Section {
            Text(UserText.syncAndBackUpThisDeviceLink)
                .daxBodyRegular()
                .foregroundColor(Color(designSystemColor: .accent))
                .onTapGesture {
                    isSyncWithSetUpSheetVisible = true
                }
                .sheet(isPresented: $isSyncWithSetUpSheetVisible, content: {
                    SyncWithServerView(model: model, onCancel: {
                        isSyncWithSetUpSheetVisible = false
                    })
                })
            Text(UserText.recoverSyncedDataLink)
                .daxBodyRegular()
                .foregroundColor(Color(designSystemColor: .accent))
                .onTapGesture {
                    isRecoverSyncedDataSheetVisible = true
                }
                .sheet(isPresented: $isRecoverSyncedDataSheetVisible, content: {
                    RecoverSyncedDataView(model: model, onCancel: {
                        isRecoverSyncedDataSheetVisible = false
                    })
                })
        } header: {
            Text(UserText.otherOptionsSectionHeader)
        }
    }
}


// Sync Enabled Views
extension SyncSettingsView {
    @ViewBuilder
    func deleteAllData() -> some View {
        Section {
            Button(UserText.deleteServerData) {
                model.deleteAllData()
            }
        }
    }

    @ViewBuilder
    func saveRecoveryPDF() -> some View {
        Section {
            Button(UserText.saveRecoveryPDFButton) {
                model.saveRecoveryPDF()
            }
        } footer: {
            Text(UserText.saveRecoveryPDFFooter)
        }
    }


    @ViewBuilder
    func devicesList() -> some View {
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
                        Text(UserText.syncedDevicesThisDeviceLabel)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    func devices() -> some View {
        Section {
            if model.devices.isEmpty {
                ProgressView()
                    .padding()
            }
            devicesList()
            Button(action: {
                model.scanQRCode()
            }, label: {
                Text(UserText.syncedDevicesSyncWithAnotherDeviceLabel)
                    .padding(.leading, 32)
            })
        } header: {
            Text(UserText.syncedDevicesSectionHeader)
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
    func turnOffSync() -> some View {
        Section {
            if model.isBusy {
                SwiftUI.ProgressView()
            } else {
                Button(UserText.turnSyncOff) {
                    model.disableSync()
                }
            }
        } header: {
            HStack(alignment: .center) {
                Text(UserText.turnSyncOffSectionHeader)
                Circle()
                    .fill(.green)
                    .frame(width: 8)
                    .padding(.bottom, 1)
            }
        } footer: {
            Text(UserText.turnSyncOffSectionFooter)
                .multilineTextAlignment(.leading)
        }
    }

    @ViewBuilder
    func options() -> some View {
        Section {
            Toggle(isOn: $model.isFaviconsFetchingEnabled) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(UserText.fetchFaviconsOptionTitle)
                        .daxBodyRegular()
                        .foregroundColor(.primary)
                    Text(UserText.fetchFaviconsOptionCaption)
                        .daxFootnoteRegular()
                        .foregroundColor(.secondary)
                }
            }
            Toggle(isOn: $model.isUnifiedFavoritesEnabled) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(UserText.unifiedFavoritesTitle)
                        .daxBodyRegular()
                        .foregroundColor(.primary)
                    Text(UserText.unifiedFavoritesInstruction)
                        .daxFootnoteRegular()
                        .foregroundColor(.secondary)
                }
            }
        } header: {
            Text(UserText.optionsSectionHeader)
        }
        .onAppear(perform: {
            model.delegate?.updateOptions()
        })
    }

    @ViewBuilder
    func syncPaused(for itemType: LimitedItemType) -> some View {
        var explanation: String {
            switch itemType {
            case .bookmarks:
                return UserText.bookmarksLimitExceededDescription
            case .credentials:
                return UserText.credentialsLimitExceededDescription
            }
        }
        var buttonTitle: String {
            switch itemType {
            case .bookmarks:
                return UserText.bookmarksLimitExceededAction
            case .credentials:
                return UserText.credentialsLimitExceededAction
            }
        }

        Section {
            VStack(alignment: .leading, spacing: 4) {
                Text(UserText.syncLimitExceededTitle)
                    .daxBodyBold()
                Text(explanation)
                    .daxBodyRegular()
            }
            Button(buttonTitle) {
                switch itemType {
                case .bookmarks:
                    model.manageBookmarks()
                case .credentials:
                    model.manageLogins()
                }
            }
        }
    }

    enum LimitedItemType {
        case bookmarks
        case credentials
    }
}

// Extension to apply custom view modifier
extension View {
    @ViewBuilder func modifier(@ViewBuilder _ closure: (Self) -> some View) -> some View {
        closure(self)
    }
}
