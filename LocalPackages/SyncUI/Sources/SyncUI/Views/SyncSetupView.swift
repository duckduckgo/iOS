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

public struct SyncSetupView: View {

    @Environment(\.verticalSizeClass) var verticalSizeClass

    @State var turnOnSyncNavigation = false

    @ObservedObject var model: SyncSetupViewModel

    public init(model: SyncSetupViewModel) {
        self.model = model
    }

    @ViewBuilder
    func turnOnSyncView() -> some View {
        ZStack {
            NavigationLink(isActive: $turnOnSyncNavigation) {
                syncWithAnotherDeviceView()
                    .padding(.top, verticalSizeClass == .compact ? 8 : 56)
            } label: {
                EmptyView()
            }

            SheetView(imageName: "SyncTurnOnSyncHero",
                      title: "Turn on Sync?",
                      message: UserText.syncTurnOnMessage,
                      primaryButton: "Turn on Sync",
                      secondaryButton: "Recover Data") {

                model.turnOnSyncAction()
                turnOnSyncNavigation = true

            } secondaryAction: {
                model.recoverDataAction()
            }
        }
    }

    @ViewBuilder
    func syncWithAnotherDeviceView() -> some View {
        SheetView(imageName: "SyncWithAnotherDeviceHero",
                  title: "Sync with Another Device?",
                  message: UserText.syncWithAnotherDeviceMessage,
                  primaryButton: "Sync with Another Device",
                  secondaryButton: "Not Now") {
            model.syncWithAnotherDeviceAction()
        } secondaryAction: {
            model.notNowAction()
        }
        .navigationBarBackButtonHidden(true)
    }

    public var body: some View {
        NavigationView {
            turnOnSyncView()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            model.cancelAction()
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
        }
            .navigationViewStyle(.stack)
    }

}

private struct SheetView: View {

    @Environment(\.verticalSizeClass) var verticalSizeClass

    let imageName: String
    let title: String
    let message: String
    let primaryButton: String
    let secondaryButton: String
    let primaryAction: () -> Void
    let secondaryAction: () -> Void

    @ViewBuilder
    func hero(imageName: String, title: String, text: String) -> some View {
        VStack(spacing: verticalSizeClass == .compact ? 12 : 24) {
            Image(imageName)
                .resizable()
                .frame(width: verticalSizeClass == .compact ? 96 : 128,
                       height: verticalSizeClass == .compact ? 72 : 96)

            Text(title)
                .font(.system(size: 28, weight: .bold))

            Text(text)
        }
        .multilineTextAlignment(.center)
        .padding(.top, verticalSizeClass == .compact ? 0 : 20)
        .padding(.horizontal, 30)
    }

    @ViewBuilder
    func buttons(primaryText: String,
                 secondaryText: String,
                 primaryAction: @escaping () -> Void,
                 secondaryAction: @escaping () -> Void) -> some View {
        VStack(spacing: verticalSizeClass == .compact ? 4 : 8) {
            Button(primaryText, action: primaryAction)
                .buttonStyle(DuckUI.PrimaryButtonStyle())

            Button(secondaryText, action: secondaryAction)
                .buttonStyle(DuckUI.SecondaryButtonStyle())
        }
        .frame(maxWidth: 360)
    }

    var body: some View {

        ZStack {
            ScrollView {
                VStack {
                    hero(imageName: imageName,
                         title: title,
                         text: message)

                    Spacer()
                }
            }

            VStack {
                Spacer()

                VStack(spacing: verticalSizeClass == .compact ? 4 : 8) {
                    buttons(primaryText: primaryButton,
                            secondaryText: secondaryButton,
                            primaryAction: primaryAction,
                            secondaryAction: secondaryAction)
                }
                .ignoresSafeArea(.container)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                .applyBackgroundOnPhone(isCompact: verticalSizeClass == .compact)
            }
        }

    }

}

private extension View {

    @ViewBuilder
    func applyBackgroundOnPhone(isCompact: Bool) -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone && isCompact {
            self.regularMaterialBackground()
        } else {
            self
        }
    }

}
