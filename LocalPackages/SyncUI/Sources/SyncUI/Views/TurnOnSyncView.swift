//
//  TurnOnSyncView.swift
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

public struct TurnOnSyncView: View {

    @Environment(\.verticalSizeClass) var verticalSizeClass

    @State var turnOnSyncNavigation = false

    @ObservedObject var model: TurnOnSyncViewModel

    public init(model: TurnOnSyncViewModel) {
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

            CTAView(imageName: "SyncTurnOnSyncHero",
                      title: "Turn on Sync?",
                      message: UserText.syncTurnOnMessage,
                      primaryButtonLabel: "Turn on Sync",
                      secondaryButtonLabel: "Recover Your Synced Data") {

                model.turnOnSyncAction()
                turnOnSyncNavigation = true

            } secondaryAction: {
                model.recoverDataAction()
            }
        }
    }

    @ViewBuilder
    func syncWithAnotherDeviceView() -> some View {
        CTAView(imageName: "SyncWithAnotherDeviceHero",
                  title: "Sync Another Device?",
                  message: UserText.syncWithAnotherDeviceMessage,
                  primaryButtonLabel: "Sync Another Device",
                  secondaryButtonLabel: "Not Now") {
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

private struct CTAView: View {

    @Environment(\.verticalSizeClass) var verticalSizeClass

    let imageName: String
    let title: String
    let message: String
    let primaryButtonLabel: String
    let secondaryButtonLabel: String
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
                .padding(.horizontal, 55)

            Text(text)
                .font(.system(size: 16, weight: .light))
                .lineSpacing(3)
                .padding(.horizontal, 30)
        }
        .multilineTextAlignment(.center)
        .padding(.top, verticalSizeClass == .compact ? 0 : 20)
    }

    @ViewBuilder
    func buttons(primaryLabel: String,
                 secondaryLabel: String,
                 primaryAction: @escaping () -> Void,
                 secondaryAction: @escaping () -> Void) -> some View {
        VStack(spacing: verticalSizeClass == .compact ? 4 : 8) {
            Button(primaryLabel, action: primaryAction)
                .buttonStyle(DuckUI.PrimaryButtonStyle())

            Button(secondaryLabel, action: secondaryAction)
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
                    buttons(primaryLabel: primaryButtonLabel,
                            secondaryLabel: secondaryButtonLabel,
                            primaryAction: primaryAction,
                            secondaryAction: secondaryAction)
                }
                .ignoresSafeArea(.container)
                .frame(maxWidth: .infinity)
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
