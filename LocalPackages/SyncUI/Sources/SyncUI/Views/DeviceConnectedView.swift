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
    @State var showRecoveryPDF = false

    let saveRecoveryKeyViewModel: SaveRecoveryKeyViewModel
    let devices: [SyncSettingsViewModel.Device]

    public init(_ saveRecoveryKeyViewModel: SaveRecoveryKeyViewModel, devices: [SyncSettingsViewModel.Device]) {
        self.saveRecoveryKeyViewModel = saveRecoveryKeyViewModel
        self.devices = devices
    }

    var title: String {
        if devices.isEmpty {
            return "All Set!"
        }
        return UserText.deviceSyncedTitle
    }

    var message: String {
        if devices.isEmpty {
            return "You can sync this device’s bookmarks and Logins with additional devices at any time from the Sync & Back Up menu in Settings."
        }
        if devices.count == 1 {
            return UserText.deviceSyncedMessage + devices[0].name
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
                    .font(.system(size: 28, weight: .bold))
                    .padding(.bottom, 24)

                Text("\(message) \(Text(devicesOnMessageText).bold())")
                    .multilineTextAlignment(.center)

//                OptionsView(isUnifiedFavoritesEnabled: isUnifiedFavoritesEnabled)
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
