//
//  SyncSetupView.swift
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

struct SyncSetupView: View {
    @ObservedObject var model: SyncSetupViewModel

    @ViewBuilder
    func header() -> some View {
        HStack {
            Button("Cancel", action: model.cancel)
                .foregroundColor(.primary.opacity(0.9))
            Spacer()
        }
        .frame(height: 56)
        .padding(.horizontal)
    }

    @ViewBuilder
    func hero(imageName: String, title: String, text: String) -> some View {
        VStack(spacing: 24) {
            Image(imageName)

            Text(title)
                .font(.system(size: 28, weight: .bold))

            Text(text)
        }
        .multilineTextAlignment(.center)
        .padding(.top, 20)
        .padding(.horizontal, 30)
    }

    @ViewBuilder
    func buttons(primaryText: String,
                 secondaryText: String,
                 primaryAction: @escaping () -> Void,
                 secondaryAction: @escaping () -> Void) -> some View {
        VStack {
            Button(primaryText, action: primaryAction)
                .buttonStyle(DuckUI.PrimaryButtonStyle())

            Button(secondaryText, action: secondaryAction)
                .buttonStyle(DuckUI.SecondaryButtonStyle())
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    func turnOnSyncView() -> some View {
        VStack {
            header()
            hero(imageName: "SyncTurnOnSyncHero",
                 title: "Turn on Sync?",
                 text: UserText.syncTurnOnMessage)
            Spacer()
            buttons(primaryText: "Turn on Sync", secondaryText: "Recover your synced data") {
                withAnimation {
                    self.model.turnOnSyncAction()
                }
            } secondaryAction: {
                // Show the camera to scan another logged in device
                model.recoverDataAction()
            }
        }
    }

    @ViewBuilder
    func syncWithAnotherDeviceView() -> some View {
        VStack {
            header()
            hero(imageName: "SyncWithAnotherDeviceHero",
                 title: "Sync with another device?",
                 text: UserText.syncWithAnotherDeviceMessage)
            Spacer()
            buttons(primaryText: "Sync Another Device", secondaryText: "Not Now") {
                // Show the camera to scan a device that isn't logged in yet
                model.syncWithAnotherDeviceAction()
            } secondaryAction: {
                // User wants to create an account and enable sync on this device
                model.turnOnSyncNowAction()
            }
        }
    }

    var body: some View {
        Group {
            switch model.state {
            case .turnOnPrompt, .showRecoverData:
                turnOnSyncView()
                    .transition(.move(edge: .leading))

            case .syncWithAnotherDevicePrompt, .showSyncWithAnotherDevice:
                syncWithAnotherDeviceView()
                    .transition(.move(edge: .trailing))

            default: EmptyView()
            }
        }
    }

}
