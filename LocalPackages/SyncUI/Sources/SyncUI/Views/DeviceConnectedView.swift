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

    @ViewBuilder
    func deviceSyncedView() -> some View {
        UnderflowContainer {
            VStack(spacing: 0) {
                Image("SyncSuccess")
                    .padding(.bottom, 20)

                Text(UserText.deviceSyncedTitle)
                    .font(.system(size: 28, weight: .bold))
                    .padding(.bottom, 24)

                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.black.opacity(0.14))

                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(devices.indices, id: \.self) { deviceIndex in

                                HStack(spacing: 0) {
                                    Image(systemName: "checkmark.circle")
                                        .padding(.horizontal, 18)
                                    Text(devices[deviceIndex].name)
                                    Spacer()
                                }
                                .frame(height: 44)

                                if deviceIndex + 1 < devices.count {
                                    Divider()
                                        .padding(.leading, 52)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 20)

                Text(UserText.deviceSyncedMessage)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)

            }
            .padding(.horizontal, 20)
        } foreground: {
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
