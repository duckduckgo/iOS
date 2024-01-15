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

@available(iOS 15, *)
struct NetworkProtectionStatusView: View {
    @StateObject public var statusModel: NetworkProtectionStatusViewModel

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
            settings()
            feedback()
        }
        .padding(.top, statusModel.error == nil ? 0 : -20)
        .if(statusModel.animationsOn, transform: {
            $0
                .animation(.default, value: statusModel.shouldShowConnectionDetails)
                .animation(.default, value: statusModel.shouldShowError)
        })
        .applyInsetGroupedListStyle()
        .navigationTitle(UserText.netPNavTitle)
    }

    @ViewBuilder
    private func toggle() -> some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(UserText.netPStatusViewTitle)
                        .daxBodyRegular()
                        .foregroundColor(.init(designSystemColor: .textPrimary))
                    Text(statusModel.statusMessage)
                        .daxFootnoteRegular()
                        .foregroundColor(.init(designSystemColor: .textSecondary))
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
                .toggleStyle(SwitchToggleStyle(tint: .init(designSystemColor: .accent)))
            }
        } header: {
            header()
        }
        .increaseHeaderProminence()
        .listRowBackground(Color(designSystemColor: .surface))
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
                    .daxHeadline()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.init(designSystemColor: .textPrimary))
                Text(UserText.netPStatusHeaderMessage)
                    .daxFootnoteRegular()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.init(designSystemColor: .textSecondary))
                    .padding(.bottom, 8)
            }
            .padding(.bottom, 4)
            // Pads beyond the default header inset
            .padding(.horizontal, -16)
            .background(Color(designSystemColor: .background))
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func connectionDetails() -> some View {
        Section {
            if let location = statusModel.location {
                NavigationLink(destination: NetworkProtectionVPNLocationView()) {
                    NetworkProtectionServerItemView(
                        imageID: "Server-Location-24",
                        title: UserText.netPStatusViewLocation,
                        value: location
                    )
                }
            }
            if let ipAddress = statusModel.ipAddress {
                NetworkProtectionServerItemView(
                    imageID: "IP-24",
                    title: UserText.netPStatusViewIPAddress,
                    value: ipAddress
                )
            }
        } header: {
            Text(UserText.netPStatusViewConnectionDetails).foregroundColor(.init(designSystemColor: .textSecondary))
        }
        .listRowBackground(Color(designSystemColor: .surface))
    }

    @ViewBuilder
    private func settings() -> some View {
        Section {
            NavigationLink(UserText.netPVPNSettingsTitle, destination: NetworkProtectionVPNSettingsView())
                .daxBodyRegular()
                .foregroundColor(.init(designSystemColor: .textPrimary))
            NavigationLink(UserText.netPVPNNotificationsTitle, destination: NetworkProtectionVPNNotificationsView())
                .daxBodyRegular()
                .foregroundColor(.init(designSystemColor: .textPrimary))
        } header: {
            Text(UserText.netPStatusViewSettingsSectionTitle).foregroundColor(.init(designSystemColor: .textSecondary))
        } footer: {
            inviteOnlyFooter()
        }
        .listRowBackground(Color(designSystemColor: .surface))
    }

    @ViewBuilder
    private func inviteOnlyFooter() -> some View {
        Text(UserText.networkProtectionWaitlistAvailabilityDisclaimer)
            .foregroundColor(.init(designSystemColor: .textSecondary))
            .accentColor(.init(designSystemColor: .accent))
            .daxFootnoteRegular()
            .padding(.top, 6)
    }

    @ViewBuilder
    private func feedback() -> some View {
        Section {
            NavigationLink {
                VPNFeedbackFormCategoryView()
            } label: {
                Text(UserText.netPStatusViewShareFeedback)
                    .daxBodyRegular()
                    .foregroundColor(.init(designSystemColor: .textPrimary))
            }
        }
        .listRowBackground(Color(designSystemColor: .surface))
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
                    .daxBodyBold()
                    .foregroundColor(.primary)
            }
            Text(message)
                .daxBodyRegular()
                .foregroundColor(.primary)
        }
        .listRowBackground(Color(designSystemColor: .accent))
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
                .daxBodyRegular()
                .foregroundColor(.init(designSystemColor: .textPrimary))
            Spacer(minLength: 2)
            Text(value)
                .daxBodyRegular()
                .foregroundColor(.init(designSystemColor: .textSecondary))
        }
        .listRowBackground(Color(designSystemColor: .surface))
    }
}

#endif
