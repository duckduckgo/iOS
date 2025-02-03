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

import SwiftUI
import NetworkProtection
import TipKit
import Networking

struct NetworkProtectionStatusView: View {

    static let defaultImageSize = CGSize(width: 32, height: 32)

    @Environment(\.colorScheme) var colorScheme

    @ObservedObject
    public var statusModel: NetworkProtectionStatusViewModel

    @StateObject
    public var feedbackFormModel: UnifiedFeedbackFormViewModel

    var tipsModel: VPNTipsModel {
        statusModel.tipsModel
    }

    // MARK: - View

    var body: some View {
        List {
            if let errorItem = statusModel.error {
                NetworkProtectionErrorView(
                    title: errorItem.title,
                    message: errorItem.message
                )
            }

            toggle()

            locationDetails()

            if statusModel.isNetPEnabled && statusModel.hasServerInfo && !statusModel.isSnoozing {
                connectionDetails()
            }

            settings()
            about()
        }
        .padding(.top, statusModel.error == nil ? 0 : -20)
        .if(statusModel.animationsOn, transform: {
            $0
                .animation(.easeOut, value: statusModel.hasServerInfo)
                .animation(.easeOut, value: statusModel.shouldShowError)
        })
        .applyInsetGroupedListStyle()
        .sheet(isPresented: $statusModel.showAddWidgetEducationView) {
            if #available(iOS 17.0, *) {
                widgetEducationSheet()
            }
        }
        .onAppear {
            if #available(iOS 18.0, *) {
                tipsModel.handleStatusViewAppear()
            }
        }
        .onDisappear {
            if #available(iOS 18.0, *) {
                tipsModel.handleStatusViewDisappear()
            }
        }
    }

    @ViewBuilder
    private func toggle() -> some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(UserText.netPStatusViewTitle)
                        .daxBodyRegular()
                        .foregroundColor(.init(designSystemColor: .textPrimary))

                    HStack {
                        statusBadge(isConnected: statusModel.isNetPEnabled)

                        Text(statusModel.statusMessage)
                            .daxFootnoteRegular()
                            .foregroundColor(.init(designSystemColor: .textSecondary))
                    }
                }
                .layoutPriority(1)

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
            .padding([.top, .bottom], 2)

            snooze()

        } header: {
            header()
        }
        .increaseHeaderProminence()
        .listRowBackground(Color(designSystemColor: .surface))

        Section {
            if #available(iOS 18.0, *) {
                widgetTipView()
                    .tipImageSize(Self.defaultImageSize)
                    .padding(.horizontal, 3)
            }

            if #available(iOS 18.0, *) {
                snoozeTipView()
                    .tipImageSize(Self.defaultImageSize)
                    .padding(.horizontal, 3)
            }
        }
        .listRowBackground(Color(designSystemColor: .surface))
    }

    @ViewBuilder
    private func statusBadge(isConnected: Bool) -> some View {
        Circle()
            .foregroundStyle(isConnected ? .green : .yellow)
            .frame(width: 8, height: 8)
    }

    @ViewBuilder
    private func header() -> some View {
        HStack {
            Spacer(minLength: 0)
            VStack(alignment: .center, spacing: 8) {
                if colorScheme == .light {
                    headerAnimationView("vpn-light-mode")
                } else {
                    headerAnimationView("vpn-dark-mode")
                }
                Text(statusModel.headerTitle)
                    .daxHeadline()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.init(designSystemColor: .textPrimary))
                Text(statusModel.isNetPEnabled ? UserText.netPStatusHeaderMessageOn : UserText.netPStatusHeaderMessageOff)
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
    private func snooze() -> some View {
        if statusModel.isSnoozing {
            Button(UserText.netPStatusViewWakeUp) {
                Task {
                    await statusModel.cancelSnooze()
                }
            }
            .tint(Color(designSystemColor: .accent))
            .disabled(statusModel.snoozeRequestPending)
        } else if statusModel.hasServerInfo {
            Button(UserText.netPStatusViewSnooze) {
                Task {
                    await statusModel.startSnooze()
                }
            }
            .tint(Color(designSystemColor: .accent))
            .disabled(statusModel.snoozeRequestPending)
        }
    }

    @ViewBuilder
    private func locationDetails() -> some View {
        Section {
            if !statusModel.isSnoozing, let location = statusModel.location {
                var locationAttributedString: AttributedString {
                    var attributedString = AttributedString(
                        statusModel.preferredLocation.isNearest ? "\(location) \(UserText.netPVPNLocationNearest)" : location
                    )
                    attributedString.foregroundColor = .init(designSystemColor: .textPrimary)
                    if let range = attributedString.range(of: UserText.netPVPNLocationNearest) {
                        attributedString[range].foregroundColor = Color(.init(designSystemColor: .textSecondary))
                    }
                    return attributedString
                }

                NavigationLink(destination: locationView()) {
                    NetworkProtectionLocationItemView(title: locationAttributedString, imageName: nil)
                }
            } else {
                let imageName = statusModel.preferredLocation.isNearest ? "VPNLocation" : nil
                var nearestLocationAttributedString: AttributedString {
                    var attributedString = AttributedString(statusModel.preferredLocation.title)
                    attributedString.foregroundColor = .init(designSystemColor: .textPrimary)
                    return attributedString
                }

                NavigationLink(destination: locationView()) {
                    NetworkProtectionLocationItemView(title: nearestLocationAttributedString, imageName: imageName)
                }
            }
        } header: {
            Text(statusModel.isNetPEnabled ? UserText.vpnLocationConnected : UserText.vpnLocationSelected)
                .foregroundColor(.init(designSystemColor: .textSecondary))
        }
        .listRowBackground(Color(designSystemColor: .surface))

        Section {
            if #available(iOS 18.0, *) {
                geoswitchingTipView()
                    .tipImageSize(Self.defaultImageSize)
                    .padding(.horizontal, 3)
            }
        }
        .listRowBackground(Color(designSystemColor: .surface))
    }

    @ViewBuilder
    private func locationView() -> some View {
        NetworkProtectionVPNLocationView()
            .onAppear {
                statusModel.handleUserOpenedVPNLocations()
            }
    }

    @ViewBuilder
    private func connectionDetails() -> some View {
        Section {
            if let ipAddress = statusModel.ipAddress {
                NetworkProtectionConnectionDetailView(title: UserText.netPStatusViewIPAddress, value: ipAddress)
            }

            if statusModel.dnsSettings.usesCustomDNS {
                NetworkProtectionConnectionDetailView(title: UserText.netPStatusViewCustomDNS, value: String(describing: statusModel.dnsSettings))
            }

            NetworkProtectionThroughputItemView(
                title: UserText.vpnDataVolume,
                downloadSpeed: statusModel.downloadTotal ?? NetworkProtectionStatusViewModel.Constants.defaultDownloadVolume,
                uploadSpeed: statusModel.uploadTotal ?? NetworkProtectionStatusViewModel.Constants.defaultUploadVolume
            )
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
        } header: {
            Text(UserText.netPStatusViewSettingsSectionTitle).foregroundColor(.init(designSystemColor: .textSecondary))
        }
        .listRowBackground(Color(designSystemColor: .surface))
    }

    @ViewBuilder
    private func about() -> some View {
        Section {
            NavigationLink(UserText.netPVPNSettingsFAQ, destination: LazyView(NetworkProtectionFAQView()))
                .daxBodyRegular()
                .foregroundColor(.init(designSystemColor: .textPrimary))

            if statusModel.usesUnifiedFeedbackForm {
                NavigationLink(
                    UserText.subscriptionFeedback,
                    destination: LazyView(UnifiedFeedbackRootView(viewModel: feedbackFormModel))
                )
                    .daxBodyRegular()
                    .foregroundColor(.init(designSystemColor: .textPrimary))
            } else {
                NavigationLink(UserText.netPVPNSettingsShareFeedback, destination: LazyView(VPNFeedbackFormCategoryView()))
                    .daxBodyRegular()
                    .foregroundColor(.init(designSystemColor: .textPrimary))
            }
        } header: {
            Text(UserText.vpnAbout).foregroundColor(.init(designSystemColor: .textSecondary))
        }
        .listRowBackground(Color(designSystemColor: .surface))
    }

    @ViewBuilder
    private func headerAnimationView(_ animationName: String) -> some View {
        LottieView(
            lottieFile: animationName,
            loopMode: .withIntro(
                .init(
                    // Skip the intro if NetP is enabled, but the user didn't manually trigger it
                    skipIntro: statusModel.isNetPEnabled && !statusModel.shouldDisableToggle,
                    introStartFrame: 0,
                    introEndFrame: 100,
                    loopStartFrame: 130,
                    loopEndFrame: 370
                )
            ),
            isAnimating: $statusModel.isNetPEnabled
        )
    }

    // MARK: - Tips

    @available(iOS 18.0, *)
    @ViewBuilder
    private func geoswitchingTipView() -> some View {
        if statusModel.canShowTips {
            TipView(tipsModel.geoswitchingTip)
                .removeGroupedListStyleInsets()
                .tipCornerRadius(0)
                .tipBackground(Color(designSystemColor: .surface))
                .onAppear {
                    tipsModel.handleGeoswitchingTipShown()
                }
                .task {
                    var previousStatus = tipsModel.geoswitchingTip.status

                    for await status in tipsModel.geoswitchingTip.statusUpdates {
                        if case .invalidated(let reason) = status {
                            if case .available = previousStatus {
                                tipsModel.handleGeoswitchingTipInvalidated(reason)
                            }
                        }

                        previousStatus = status
                    }
                }
        }
    }

    @available(iOS 18.0, *)
    @ViewBuilder
    private func snoozeTipView() -> some View {
        if statusModel.canShowTips,
           statusModel.hasServerInfo {

            TipView(tipsModel.snoozeTip, action: statusModel.snoozeActionHandler(action:))
                .removeGroupedListStyleInsets()
                .tipCornerRadius(0)
                .tipBackground(Color(designSystemColor: .surface))
                .onAppear {
                    tipsModel.handleSnoozeTipShown()
                }
                .task {
                    var previousStatus = tipsModel.snoozeTip.status

                    for await status in tipsModel.snoozeTip.statusUpdates {
                        if case .invalidated(let reason) = status {
                            if case .available = previousStatus {
                                tipsModel.handleSnoozeTipInvalidated(reason)
                            }
                        }

                        previousStatus = status
                    }
                }
        }
    }

    @available(iOS 18.0, *)
    @ViewBuilder
    private func widgetTipView() -> some View {
        if statusModel.canShowTips,
           !statusModel.isNetPEnabled && !statusModel.isSnoozing {

            TipView(tipsModel.widgetTip, action: statusModel.widgetActionHandler(action:))
                .removeGroupedListStyleInsets()
                .tipCornerRadius(0)
                .tipBackground(Color(designSystemColor: .surface))
                .onAppear {
                    tipsModel.handleWidgetTipShown()
                }
                .task {
                    var previousStatus = tipsModel.widgetTip.status

                    for await status in tipsModel.widgetTip.statusUpdates {
                        if case .invalidated(let reason) = status {
                            if case .available = previousStatus {
                                tipsModel.handleWidgetTipInvalidated(reason)
                            }
                        }

                        previousStatus = status
                    }
                }
        }
    }

    // MARK: - Sheets

    @available(iOS 17.0, *)
    private func widgetEducationSheet() -> some View {
        NavigationView {
            WidgetEducationView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(UserText.navigationTitleDone) {
                            statusModel.showAddWidgetEducationView = false
                        }
                    }
                }
        }
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
        .listRowBackground(Color(designSystemColor: .surface))
    }
}

private struct NetworkProtectionLocationItemView: View {
    let title: AttributedString
    let imageName: String?

    var body: some View {
        HStack(spacing: 8) {
            if let imageName {
                Image(imageName)
            }

            Text(title)
                .daxBodyRegular()
        }
        .listRowBackground(Color(designSystemColor: .surface))
    }
}

private struct NetworkProtectionConnectionDetailView: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 16) {
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

private struct NetworkProtectionThroughputItemView: View {
    let title: String
    let downloadSpeed: String
    let uploadSpeed: String

    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .daxBodyRegular()
                .foregroundColor(.init(designSystemColor: .textPrimary))

            Spacer(minLength: 2)

            Image("VPNDownload")
                .foregroundColor(.init(designSystemColor: .textSecondary))
            Text(downloadSpeed)
                .daxBodyRegular()
                .foregroundColor(.init(designSystemColor: .textSecondary))

            Image("VPNUpload")
                .foregroundColor(.init(designSystemColor: .textSecondary))
                .padding(.leading, 4)
            Text(uploadSpeed)
                .daxBodyRegular()
                .foregroundColor(.init(designSystemColor: .textSecondary))
        }
        .listRowBackground(Color(designSystemColor: .surface))
    }
}

extension NetworkProtectionDNSSettings {
    var usesCustomDNS: Bool {
        guard case .custom(let servers) = self, !servers.isEmpty else { return false }
        return true
    }
}
