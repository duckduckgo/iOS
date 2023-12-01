//
//  NetworkProtectionVPNNotificationsView.swift
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
import UIKit
import NetworkProtection
import Core

@available(iOS 15, *)
struct NetworkProtectionVPNNotificationsView: View {
    @StateObject var model = NetworkProtectionVPNNotificationsViewModel()

    var body: some View {
        List {
            switch model.viewKind {
            case .loading:
                EmptyView()
            case .unauthorized:
                unauthorizedView
            case .authorized:
                authorizedView
            }
        }
        .animation(.default, value: model.viewKind)
        .applyInsetGroupedListStyle()
        .navigationTitle(UserText.netPVPNNotificationsTitle).onAppear {
            Task {
                await model.onViewAppeared()
            }
        }
    }

    @ViewBuilder
    private var unauthorizedView: some View {
        Section {
            Button(UserText.netPTurnOnNotificationsButtonTitle) {
                model.turnOnNotifications()
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
    private var authorizedView: some View {
        Section {
            Toggle(
                UserText.netPVPNAlertsToggleTitle,
                isOn: Binding(
                    get: { model.alertsEnabled },
                    set: model.didToggleAlerts(to:)
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
