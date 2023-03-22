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

    var isCompact: Bool {
        verticalSizeClass == .compact
    }

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
                    title: UserText.turnOnTitle,
                    message: UserText.turnOnMessage,
                    primaryButtonLabel: UserText.turnOnButton,
                    secondaryButtonLabel: UserText.recoverDataButton) {

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
                title: UserText.syncWithAnotherDeviceTitle,
                message: UserText.syncWithAnotherDeviceMessage,
                primaryButtonLabel: UserText.syncWithAnotherDeviceButton,
                secondaryButtonLabel: UserText.notNowButton) {
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
                            Text(UserText.cancelButton)
                        }
                    }
                }
        }
            .navigationViewStyle(.stack)
    }

}

private struct CTAView: View {

    @Environment(\.verticalSizeClass) var verticalSizeClass

    var isCompact: Bool {
        verticalSizeClass == .compact
    }

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
                .font(.system(size: 16, weight: .regular))
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
        VStack(spacing: isCompact ? 4 : 8) {
            Button(primaryLabel, action: primaryAction)
                .buttonStyle(PrimaryButtonStyle(compact: isCompact))

            Button(secondaryLabel, action: secondaryAction)
                .buttonStyle(SecondaryButtonStyle(compact: isCompact))
        }
        .frame(maxWidth: 360)
    }

    var body: some View {
        UnderflowContainer {
            hero(imageName: imageName,
                 title: title,
                 text: message)
        } foreground: {
            buttons(primaryLabel: primaryButtonLabel,
                    secondaryLabel: secondaryButtonLabel,
                    primaryAction: primaryAction,
                    secondaryAction: secondaryAction)
        }
    }

}
