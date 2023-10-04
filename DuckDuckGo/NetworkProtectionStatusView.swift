//
//  NetworkProtectionStatusView.swift
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

#if NETWORK_PROTECTION

import SwiftUI
import NetworkProtection

struct NetworkProtectionStatusView: View {
    @ObservedObject public var statusModel: NetworkProtectionStatusViewModel

    var body: some View {
        List {
            if let errorItem = statusModel.error {
                NetworkProtectionErrorView(
                    title: errorItem.title,
                    message: errorItem.message
                )
            }
            toggle()
            if statusModel.shouldShowConnectionDetails {
                connectionDetails()
            }
        }
        .animation(.default, value: statusModel.shouldShowError)
        .padding(.top, statusModel.error == nil ? 0 : -20)
        .animation(.default, value: statusModel.shouldShowConnectionDetails)
        .applyListStyle()
        .navigationTitle(UserText.netPNavTitle)
    }

    @ViewBuilder
    private func toggle() -> some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(UserText.netPStatusViewTitle)
                        .font(.system(size: 16))
                        .foregroundColor(.textPrimary)
                    Text(statusModel.statusMessage)
                        .font(.system(size: 13))
                        .foregroundColor(.textSecondary)
                }

                Toggle("", isOn: Binding(
                    get: { statusModel.isNetPEnabled },
                    set: { isOn in
                        Task {
                            await statusModel.didToggleNetP(to: isOn)
                        }
                    }
                ))
                .disabled(statusModel.shouldDisableToggle)
                .toggleStyle(SwitchToggleStyle(tint: .controlColor))
            }
            .listRowBackground(Color.cellBackground)
        } header: {
            header()
        } footer: {
            if !statusModel.shouldShowConnectionDetails {
                inviteOnlyFooter()
            }
        }.increaseHeaderProminence()
    }

    @ViewBuilder
    private func header() -> some View {
        HStack {
            Spacer(minLength: 0)
            VStack(alignment: .center, spacing: 8) {
                Image(statusModel.statusImageID)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 96)
                    .padding(8)
                Text(statusModel.headerTitle)
                    .font(.system(size: 17, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.textPrimary)
                Text(UserText.netPStatusHeaderMessage)
                    .font(.system(size: 13))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.textSecondary)
                    .padding(.bottom, 8)
            }
            .padding(.bottom, 4)
            // Pads beyond the default header inset
            .padding(.horizontal, -16)
            .background(Color.viewBackground)
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func connectionDetails() -> some View {
        Section {
            if let location = statusModel.location {
                NetworkProtectionServerItemView(
                    imageID: "Server-Location-24",
                    title: UserText.netPStatusViewLocation,
                    value: location
                )
            }
            if let ipAddress = statusModel.ipAddress {
                NetworkProtectionServerItemView(
                    imageID: "IP-24",
                    title: UserText.netPStatusViewIPAddress,
                    value: ipAddress
                )
            }
        } header: {
            Text(UserText.netPStatusViewConnectionDetails).foregroundColor(.textPrimary)
        } footer: {
            inviteOnlyFooter()
        }
    }

    @ViewBuilder
    private func inviteOnlyFooter() -> some View {
        // Needs to be inlined like this for the markdown parsing to work
        Text("\(UserText.netPInviteOnlyMessage) [\(UserText.netPStatusViewShareFeedback)](https://form.asana.com/?k=_wNLt6YcT5ILpQjDuW0Mxw&d=137249556945)")
            .foregroundColor(.textSecondary)
            .accentColor(Color.controlColor)
            .font(.system(size: 13))
            .padding(.top, 6)
    }
}

private struct NetworkProtectionErrorView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image("Alert-Color-16")
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .bold()
            }
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(.primary)
        }
        .listRowBackground(Color.cellBackground)
    }
}

private struct NetworkProtectionServerItemView: View {
    let imageID: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 16) {
            Image(imageID)
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.textPrimary)
            Spacer(minLength: 2)
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(.textSecondary)
        }
        .listRowBackground(Color.cellBackground)
    }
}

private extension View {
    @ViewBuilder
    func hideScrollContentBackground() -> some View {
        if #available(iOS 16, *) {
            self.scrollContentBackground(.hidden)
        } else {
            let originalBackgroundColor = UITableView.appearance().backgroundColor
            self.onAppear {
                UITableView.appearance().backgroundColor = .clear
            }.onDisappear {
                UITableView.appearance().backgroundColor = originalBackgroundColor
            }
        }
    }

    @ViewBuilder
    func applyListStyle() -> some View {
        self
            .listStyle(.insetGrouped)
            .hideScrollContentBackground()
            .background(
                Rectangle().ignoresSafeArea().foregroundColor(Color.viewBackground)
            )
    }

    @ViewBuilder
    func increaseHeaderProminence() -> some View {
        if #available(iOS 15, *) {
            self.headerProminence(.increased)
        } else {
            self
        }
    }
}

private extension Color {
    static let textPrimary = Color(designSystemColor: .textPrimary)
    static let textSecondary = Color(designSystemColor: .textSecondary)
    static let cellBackground = Color(designSystemColor: .surface)
    static let viewBackground = Color(designSystemColor: .background)
    static let controlColor = Color(designSystemColor: .accent)
}

struct NetworkProtectionStatusView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkProtectionStatusView(statusModel: NetworkProtectionStatusViewModel())
    }
}

#endif
