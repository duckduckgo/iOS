//
//  SyncDeviceConnectedView.swift
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

struct SyncDeviceConnectedView: View {

    @State var showDeviceSynced: Bool

    @ViewBuilder
    func deviceSyncedView() -> some View {
        VStack(spacing: 0) {
            Image("SyncSuccess")
                .padding(.bottom, 20)

            Text("Device Synced!")
                .font(.system(size: 28, weight: .bold))
                .padding(.bottom, 24)

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.black.opacity(0.14))

                HStack(spacing: 0) {
                    Image(systemName: "checkmark.circle")
                        .padding(.horizontal, 18)
                    Text("Another Device")
                    Spacer()
                }
            }
            .frame(height: 44)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            Text("Your bookmarks are now syncing with this device.")
                .lineLimit(nil)
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                withAnimation {
                    showDeviceSynced = false
                }
            } label: {
                Text("Next")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }

    @ViewBuilder
    func recoveryPDFView() -> some View {
        VStack {
            Image("SyncDownloadRecoveryCode")
                .padding(.bottom, 20)

            Text("Save Recovery PDF?")
                .font(.system(size: 28, weight: .bold))
                .padding(.bottom, 24)

            Text(UserText.syncRecoveryPDFMessage)
                .lineLimit(nil)
                .multilineTextAlignment(.center)

            Spacer()

            Button {

            } label: {
                Text("Save Recovery PDF")
            }
            .buttonStyle(PrimaryButtonStyle())

            Button {

            } label: {
                Text("Now Now")
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }

    var body: some View {
        Group {
            if showDeviceSynced {
                deviceSyncedView()
                    .transition(.move(edge: .leading))
            } else {
                recoveryPDFView()
                    .transition(.move(edge: .trailing))
            }
        }
        /// Should use no-title navigation view instead?
        .padding(.top, 56)
        .padding(.horizontal)
        .padding(.bottom)
    }

}
