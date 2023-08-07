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
    @ObservedObject public var inviteModel: NetworkProtectionInviteViewModel

    var body: some View {
        List {
            toggle()
            inviteCodeEntry()
        }
        .applyListStyle()
        .navigationTitle(UserText.netPNavTitle)
    }

    @ViewBuilder
    func toggle() -> some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(UserText.netPStatusViewTitle)
                        .font(.system(size: 16))
                        .foregroundColor(.titleText)
                    Text(statusModel.statusMessage)
                        .font(.system(size: 13))
                        .foregroundColor(.messageText)
                }

                Toggle("", isOn: Binding(
                    get: { statusModel.isNetPEnabled },
                    set: { isOn in
                        Task {
                            await statusModel.didToggleNetP(to: isOn)
                        }
                    }
                ))
                .disabled(statusModel.shouldShowLoading)
                .toggleStyle(SwitchToggleStyle(tint: .toggleColor))
            }
            .background(Color.cellBackground)
        } header: {
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 16) {
                    Image(statusModel.statusImageID)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 96)
                        .padding(8)
                    Text(statusModel.headerTitle)
                        .font(.system(size: 17, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.titleText)
                    Text(UserText.netPStatusHeaderMessage)
                        .font(.system(size: 13))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.messageText)
                }
                .padding(.bottom, 4)
                .background(Color.viewBackground)
                Spacer()
            }
        }.increaseHeaderProminence()
    }

    @ViewBuilder
    func inviteCodeEntry() -> some View {
        Section {
            Button("Clear Invite Code") {
                Task {
                    await inviteModel.clear()
                }
            }
            .foregroundColor(.red)
        }
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
            .listStyle(.insetGrouped)
            .hideScrollContentBackground()
            .background(
                Rectangle().ignoresSafeArea().foregroundColor(Color.viewBackground))
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
    static let titleText = Color(designSystemColor: .textPrimary)
    static let messageText = Color(designSystemColor: .textSecondary)
    static let cellBackground = Color(designSystemColor: .surface)
    static let viewBackground = Color(designSystemColor: .background)
    static let toggleColor = Color(designSystemColor: .accent)
}

struct NetworkProtectionStatusView_Previews: PreviewProvider {
    static var previews: some View {
        let inviteViewModel = NetworkProtectionInviteViewModel(
            redemptionCoordinator: NetworkProtectionCodeRedemptionCoordinator()
        ) { }
        NetworkProtectionStatusView(statusModel: NetworkProtectionStatusViewModel(), inviteModel: inviteViewModel)
    }
}

#endif
