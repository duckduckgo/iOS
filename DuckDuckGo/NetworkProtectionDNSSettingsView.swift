//
//  NetworkProtectionDNSSettingsView.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import NetworkProtection

struct NetworkProtectionDNSSettingsView: View {
    @StateObject var viewModel = NetworkProtectionDNSSettingsViewModel(settings: VPNSettings(defaults: .networkProtectionGroupDefaults), controller: AppDependencyProvider.shared.networkProtectionTunnelController)
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isCustomDNSServerFocused: Bool

    var body: some View {
        VStack {
            List {
                Section {
                    NetworkProtectionUIElements.ChecklistItem(isSelected: !viewModel.isCustomDNSSelected) {
                        viewModel.toggleDNSSettings()
                    } label: {
                        Text(UserText.vpnSettingDNSServerOptionRecommended)
                            .daxBodyRegular()
                            .foregroundStyle(Color(designSystemColor: .textPrimary))
                    }
                    NetworkProtectionUIElements.ChecklistItem(isSelected: viewModel.isCustomDNSSelected) {
                        viewModel.toggleDNSSettings()
                    } label: {
                        Text(UserText.vpnSettingDNSServerOptionCustom)
                            .daxBodyRegular()
                            .foregroundStyle(Color(designSystemColor: .textPrimary))
                    }
                } footer: {
                    if !viewModel.isCustomDNSSelected {
                        Text(UserText.netPSecureDNSSettingFooter)
                            .daxFootnoteRegular()
                            .foregroundColor(.init(designSystemColor: .textSecondary))
                    }
                }
                .listRowBackground(Color(designSystemColor: .surface))
                .onChange(of: viewModel.isCustomDNSSelected) { _ in
                    viewModel.updateApplyButtonState()
                }

                if viewModel.isCustomDNSSelected {
                    customDNSSection()
                } else {
                    if viewModel.isRiskySitesProtectionFeatureEnabled {
                        blockRiskyDomainsSection()
                    }
                }
            }
        }
        .applyInsetGroupedListStyle()
        .navigationTitle(UserText.vpnSettingDNSServerScreenTitle)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    viewModel.applyDNSSettings()
                    dismiss()
                } label: {
                    Text(UserText.vpnSettingDNSServerApplyButtonTitle)
                }
                .disabled(!viewModel.isApplyButtonEnabled)
            }
        }
    }

    func customDNSSection() -> some View {
        Section {
            HStack {
                Text(UserText.vpnSettingDNSServerIPv4Title)
                    .daxBodyRegular()
                    .foregroundColor(.init(designSystemColor: .textPrimary))
                Spacer(minLength: 2)
                TextField("0.0.0.0", text: $viewModel.customDNSServers)
                    .daxBodyRegular()
                    .foregroundColor(.init(designSystemColor: .textSecondary))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.numbersAndPunctuation)
                    .multilineTextAlignment(.trailing)
                    .focused($isCustomDNSServerFocused)
                    .onChange(of: viewModel.customDNSServers) { _ in
                        viewModel.updateApplyButtonState()
                    }
            }
        } header: {
            Text(UserText.vpnSettingDNSSectionHeader)
        } footer: {
            Text(UserText.vpnSettingDNSSectionDisclaimer)
                .foregroundColor(.init(designSystemColor: .textSecondary))
        }
        .listRowBackground(Color(designSystemColor: .surface))
        .onAppear {
            isCustomDNSServerFocused = true
        }
    }

    func blockRiskyDomainsSection() -> some View {
        NetworkProtectionUIElements.ToggleSectionView(
            text: "Block risky domains",
            headerText: "Content Blocking and Filtering",
            footerText: UserText.vpnContentBlockingFilteringFooter
        ) {
            Toggle("", isOn: $viewModel.isBlockRiskyDomainsOn)
        }
    }

}
