//
//  NetworkProtectionVPNSettingsView.swift
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
import DesignResourcesKit

@available(iOS 15, *)
struct NetworkProtectionVPNSettingsView: View {
    @StateObject var viewModel = NetworkProtectionVPNSettingsViewModel()

    var body: some View {
        VStack {
            List {
                switch viewModel.viewKind {
                case .loading: EmptyView()
                case .unauthorized: notificationsUnauthorizedView
                case .authorized: notificationAuthorizedView
                }

                toggleSection(
                    text: UserText.netPExcludeLocalNetworksSettingTitle,
                    footerText: UserText.netPExcludeLocalNetworksSettingFooter
                ) {
                    Toggle("", isOn: $viewModel.excludeLocalNetworks)
                        .onTapGesture {
                            viewModel.toggleExcludeLocalNetworks()
                        }
                }

                Section {
                    HStack(spacing: 16) {
                        Image("Info-Solid-24")
                            .foregroundColor(.init(designSystemColor: .icons).opacity(0.3))
                        Text(UserText.netPSecureDNSSettingFooter)
                            .daxFootnoteRegular()
                            .foregroundColor(.init(designSystemColor: .textSecondary))
                    }
                }
                .listRowBackground(Color(designSystemColor: .surface))
            }
        }
        .applyInsetGroupedListStyle()
        .navigationTitle(UserText.netPVPNSettingsTitle).onAppear {
            Task {
                await viewModel.onViewAppeared()
            }
        }
    }

    @ViewBuilder
    func toggleSection(text: String, footerText: String, @ViewBuilder toggle: () -> some View) -> some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(text)
                        .daxBodyRegular()
                        .foregroundColor(.init(designSystemColor: .textPrimary))
                        .layoutPriority(1)
                }

                toggle()
                    .toggleStyle(SwitchToggleStyle(tint: .init(designSystemColor: .accent)))
            }
        } footer: {
            Text(footerText)
                .foregroundColor(.init(designSystemColor: .textSecondary))
                .accentColor(Color(designSystemColor: .accent))
                .daxFootnoteRegular()
                .padding(.top, 6)
        }
        .listRowBackground(Color(designSystemColor: .surface))
    }

    @ViewBuilder
    private var notificationsUnauthorizedView: some View {
        Section {
            Button(UserText.netPTurnOnNotificationsButtonTitle) {
                viewModel.turnOnNotifications()
            }
            .foregroundColor(.init(designSystemColor: .accent))
        } footer: {
            Text(UserText.netPTurnOnNotificationsSectionFooter)
                .foregroundColor(.init(designSystemColor: .textSecondary))
                .daxFootnoteRegular()
                .padding(.top, 6)
        }
        .listRowBackground(Color(designSystemColor: .surface))
    }

    @ViewBuilder
    private var notificationAuthorizedView: some View {
        Section {
            Toggle(
                UserText.netPVPNAlertsToggleTitle,
                isOn: Binding(
                    get: { viewModel.alertsEnabled },
                    set: viewModel.didToggleAlerts(to:)
                )
            )
            .toggleStyle(SwitchToggleStyle(tint: .init(designSystemColor: .accent)))
        } footer: {
            Text(UserText.netPVPNAlertsToggleSectionFooter)
                .foregroundColor(.init(designSystemColor: .textSecondary))
                .daxFootnoteRegular()
                .padding(.top, 6)
        }
        .listRowBackground(Color(designSystemColor: .surface))
    }

}

#endif
