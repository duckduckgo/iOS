//
//  DeviceConnectedView.swift
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
import DuckUI

public struct DeviceConnectedView: View {

    @Environment(\.verticalSizeClass) var verticalSizeClass

    var isCompact: Bool {
        verticalSizeClass == .compact
    }
    let isSingleSetUp: Bool
    let shouldShowOptions: Bool
    @State var showRecoveryPDF = false

    let saveRecoveryKeyViewModel: SaveRecoveryKeyViewModel
    @ObservedObject var optionsViewModel: SyncSettingsViewModel
    let devices: [SyncSettingsViewModel.Device]

    public init(_ saveRecoveryKeyViewModel: SaveRecoveryKeyViewModel, optionsViewModel: SyncSettingsViewModel, devices: [SyncSettingsViewModel.Device], isSingleSetUp: Bool, shouldShowOptions: Bool) {
        self.saveRecoveryKeyViewModel = saveRecoveryKeyViewModel
        self.devices = devices
        self.optionsViewModel = optionsViewModel
        self.isSingleSetUp = isSingleSetUp
        self.shouldShowOptions = shouldShowOptions
    }

    var title: String {
        if isSingleSetUp {
            return UserText.syngleDeviceConnectedTitle
        }
        return UserText.deviceSyncedTitle
    }

    var message: String {
        if isSingleSetUp {
            return UserText.firstDeviceSyncedMessage
        }
        if devices.count == 1 {
            return UserText.deviceSyncedMessage
        }
        return UserText.multipleDevicesSyncedMessage
    }

    var devicesOnMessageText: String {
        if devices.isEmpty {
            return ""
        }
        if devices.count == 1 {
            return devices[0].name
        }
        return "\(devices.count + 1) " + UserText.wordDevices
    }

    @ViewBuilder
    func deviceSyncedView() -> some View {
        UnderflowContainer {
            VStack(spacing: 0) {
                Image("Sync-Start-128")
                    .padding(.bottom, 20)

                Text(title)
                    .daxTitle1()
                    .padding(.bottom, 24)

                Text("\(message) \(Text(devicesOnMessageText).bold())")
                    .multilineTextAlignment(.center)
                
                if shouldShowOptions {
                    options()
                }
            }
            .padding(.horizontal, 20)
        } foregroundContent: {
            Button {
                withAnimation {
                    self.showRecoveryPDF = true
                }
            } label: {
                Text(UserText.nextButton)
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(maxWidth: 360)
            .padding(.horizontal, 30)
        }
        .padding(.top, isCompact ? 0 : 56)
        .padding(.bottom)
    }

    @ViewBuilder
    func options() -> some View {
        VStack {
            Spacer(minLength: 71)
            Text(UserText.options.uppercased())
                .daxFootnoteRegular()
            Toggle(isOn: $optionsViewModel.isUnifiedFavoritesEnabled) {
                HStack(spacing: 16) {
                    Image("SyncAllDevices")
                    VStack(alignment: .leading) {
                        Text(UserText.unifiedFavoritesTitle)
                            .foregroundColor(.primary)
                            .daxBodyRegular()
                        Text(UserText.unifiedFavoritesInstruction)
                            .daxCaption()
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.black.opacity(0.01))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.black.opacity(0.2), lineWidth: 0.2)
            )
        }
    }

    public var body: some View {
        if showRecoveryPDF {
            SaveRecoveryKeyView(model: saveRecoveryKeyViewModel)
                .transition(.move(edge: .trailing))
        } else {
            deviceSyncedView()
                .transition(.move(edge: .leading))
        }
    }

}
