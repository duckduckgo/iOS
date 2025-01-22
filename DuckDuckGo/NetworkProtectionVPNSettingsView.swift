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

import SwiftUI
import DesignResourcesKit

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

                shortcutsView

                toggleSection(
                    text: UserText.netPExcludeLocalNetworksSettingTitle,
                    headerText: UserText.netPExcludeLocalNetworksSettingHeader,
                    footerText: UserText.netPExcludeLocalNetworksSettingFooter
                ) {
                    Toggle("", isOn: $viewModel.excludeLocalNetworks)
                }

                dnsSection()
            }
        }
        .applyInsetGroupedListStyle()
        .navigationTitle(UserText.netPVPNSettingsTitle).onAppear {
            Task {
                await viewModel.onViewAppeared()
            }
        }
    }

    func dnsSection() -> some View {
        Section {
            NavigationLink {
                NetworkProtectionDNSSettingsView()
            } label: {
                HStack {
                    Text(UserText.vpnSettingDNSServerTitle)
                        .daxBodyRegular()
                        .foregroundColor(.init(designSystemColor: .textPrimary))
                    Spacer()
                    Text(viewModel.dnsServers)
                        .daxBodyRegular()
                        .foregroundColor(.init(designSystemColor: .textSecondary))
                }
            }
        } header: {
            Text(UserText.vpnSettingDNSSectionHeader)
        } footer: {
            if viewModel.usesCustomDNS {
                Text(UserText.vpnSettingDNSSectionDisclaimer)
                    .foregroundColor(.init(designSystemColor: .textSecondary))
            } else {
                Text(UserText.netPSecureDNSSettingFooter)
                    .foregroundColor(.init(designSystemColor: .textSecondary))
            }
        }
        .listRowBackground(Color(designSystemColor: .surface))
    }

    @ViewBuilder
    func toggleSection(text: String, headerText: String, footerText: String, @ViewBuilder toggle: () -> some View) -> some View {
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
        } header: {
            Text(headerText)
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
        } header: {
            Text(UserText.netPVPNAlertsSectionHeader)
        } footer: {
            Text(UserText.netPVPNAlertsToggleSectionFooter)
                .foregroundColor(.init(designSystemColor: .textSecondary))
                .daxFootnoteRegular()
                .padding(.top, 6)
        }
        .listRowBackground(Color(designSystemColor: .surface))
    }

    @ViewBuilder
    private var shortcutsView: some View {
        // Widget only available for iOS 17 and up
        if #available(iOS 17.0, *) {
            Section {
                NavigationLink {
                    WidgetEducationView.vpn
                } label: {
                    Label {
                        Text(UserText.vpnSettingsAddWidget)
                    } icon: {
                        Image(.addWidgetColor24)
                            .frame(width: 24, height: 24)
                    }.daxBodyRegular()
                }

                if #available(iOS 18.0, *) {
                    NavigationLink {
                        ControlCenterWidgetEducationView(navBarTitle: "Add DuckDuckGo VPN Shortcut to Your Control Center",
                                                         widget: .vpnToggle)
                    } label: {
                        Label {
                            Text(UserText.vpnSettingsAddControlCenterWidget)
                        } icon: {
                            Image(.settingsColor24)
                                .frame(width: 24, height: 24)
                        }.daxBodyRegular()
                    }
                }

                NavigationLink {
                    SiriEducationView()
                } label: {
                    Label {
                        Text(UserText.vpnSettingsControlWithSiri)
                    } icon: {
                        Image(.askSiriColor24)
                            .frame(width: 24, height: 24)
                    }.daxBodyRegular()
                }
            } header: {
                Text(UserText.netPVPNShortcutsSectionHeader)
            }
            .listRowBackground(Color(designSystemColor: .surface))
        }
    }
}

@available(iOS 17.0, *)
private extension WidgetEducationView {

    static var vpn: Self {
        WidgetEducationView(
            navBarTitle: UserText.settingsAddVPNWidget,
            thirdParagraphText: UserText.addVPNWidgetSettingsThirdParagraph,
            thirdParagraphDetail: .image(
                Image("WidgetEducationVPNWidgetExample"),
                maxWidth: 164,
                horizontalOffset: -7,
                dropsShadow: true
            )
        )
    }
}
