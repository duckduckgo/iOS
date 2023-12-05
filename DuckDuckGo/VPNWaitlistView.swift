//
//  VPNWaitlistView.swift
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
import Core
import Waitlist
import DesignResourcesKit

@available(iOS 15.0, *)
struct VPNWaitlistView: View {

    @EnvironmentObject var viewModel: WaitlistViewModel

    var body: some View {
        switch viewModel.viewState {
        case .notJoinedQueue:
            VPNWaitlistSignUpView(requestInFlight: false) { action in
                Task { await viewModel.perform(action: action) }
            }
        case .joiningQueue:
            VPNWaitlistSignUpView(requestInFlight: true) { action in
                Task { await viewModel.perform(action: action) }
            }
        case .joinedQueue(let state):
            VPNWaitlistJoinedWaitlistView(notificationState: state) { action in
                Task { await viewModel.perform(action: action) }
            }
        case .invited:
            VPNWaitlistInvitedView { action in
                Task { await viewModel.perform(action: action) }
            }
        case .waitlistRemoved:
            fatalError("State not supported for VPN waitlists")
        }
    }
}

@available(iOS 15.0, *)
struct VPNWaitlistSignUpView: View {

    let requestInFlight: Bool

    let action: WaitlistViewActionHandler

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .center, spacing: 8) {
                    HeaderView(imageName: "JoinVPNWaitlist", title: UserText.netPNavTitle)

                    Text(UserText.networkProtectionWaitlistJoinSubtitle1)
                        .daxBodyRegular()
                        .foregroundColor(.waitlistTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)

                    Text(UserText.networkProtectionWaitlistJoinSubtitle2)
                        .daxBodyRegular()
                        .foregroundColor(.waitlistTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.top, 18)

                    Button(UserText.networkProtectionWaitlistButtonJoinWaitlist, action: { action(.joinQueue) })
                        .buttonStyle(RoundedButtonStyle(enabled: !requestInFlight))
                        .padding(.top, 24)

                    Button(UserText.networkProtectionWaitlistButtonExistingInviteCode, action: {
                        action(.custom(.openNetworkProtectionInviteCodeScreen))
                    })
                        .buttonStyle(RoundedButtonStyle(enabled: true, style: .bordered))
                        .padding(.top, 16)

                    if requestInFlight {
                        HStack {
                            Text(UserText.waitlistJoining)
                                .daxSubheadRegular()
                                .foregroundColor(.waitlistTextSecondary)

                            ActivityIndicator(style: .medium)
                        }
                        .padding(.top, 14)
                    }
                    Spacer()
                    Text(UserText.networkProtectionWaitlistAvailabilityDisclaimer)
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                        .padding(.top, 24)
                }
                .padding([.leading, .trailing], 24)
                .frame(minHeight: proxy.size.height)
            }
        }
    }

}

// MARK: - Joined Waitlist Views

@available(iOS 15.0, *)
struct VPNWaitlistJoinedWaitlistView: View {

    let notificationState: WaitlistViewModel.NotificationPermissionState

    let action: (WaitlistViewModel.ViewAction) -> Void

    var body: some View {
        VStack(spacing: 16) {
            HeaderView(imageName: "JoinedVPNWaitlist", title: UserText.networkProtectionWaitlistJoinedTitle)

            switch notificationState {
            case .notificationAllowed:
                Text(UserText.networkProtectionWaitlistJoinedWithNotificationsSubtitle1)
                    .daxBodyRegular()
                    .foregroundColor(.waitlistTextSecondary)
                    .lineSpacing(6)

                Text(UserText.networkProtectionWaitlistJoinedWithNotificationsSubtitle2)
                    .daxBodyRegular()
                    .foregroundColor(.waitlistTextSecondary)
                    .lineSpacing(6)

            default:
                Text(UserText.networkProtectionWaitlistJoinedWithNotificationsSubtitle1)
                    .daxBodyRegular()
                    .foregroundColor(.waitlistTextSecondary)
                    .lineSpacing(6)

                if notificationState == .notificationsDisabled {
                    AllowNotificationsView(action: action)
                        .padding(.top, 4)
                } else {
                    Button(UserText.waitlistNotifyMe) {
                        action(.requestNotificationPermission)
                    }
                    .buttonStyle(RoundedButtonStyle(enabled: true))
                    .padding(.top, 32)
                }
            }

            Spacer()
        }
        .padding([.leading, .trailing], 24)
        .multilineTextAlignment(.center)
    }

}

@available(iOS 15.0, *)
private struct AllowNotificationsView: View {

    let action: (WaitlistViewModel.ViewAction) -> Void

    var body: some View {

        VStack(spacing: 20) {

            Text(UserText.waitlistNotificationDisabled)
                .daxBodyRegular()
                .foregroundColor(.waitlistTextSecondary)
                .fixMultilineScrollableText()
                .lineSpacing(5)


            Button {
                action(.openNotificationSettings)
            } label: {
                HStack {
                    Image("Bell-16")
                    Text(UserText.waitlistAllowNotifications)
                        .daxButton()
                }
            }
            .buttonStyle(RoundedButtonStyle(enabled: true))
        }
        .padding(20)
        .background(Color.waitlistNotificationBackground)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
    }

}

// MARK: - Invite Available Views

private struct ShareButtonFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}

@available(iOS 15.0, *)
struct VPNWaitlistInvitedView: View {

    let benefitsList: [VPNWaitlistBenefit] = [
        .init(
            imageName: "Shield-24",
            title: UserText.networkProtectionWaitlistInvitedSection1Title,
            subtitle: UserText.networkProtectionWaitlistInvitedSection1Subtitle
        ),
        .init(
            imageName: "Rocket-24",
            title: UserText.networkProtectionWaitlistInvitedSection2Title,
            subtitle: UserText.networkProtectionWaitlistInvitedSection2Subtitle
        ),
        .init(
            imageName: "Card-24",
            title: UserText.networkProtectionWaitlistInvitedSection3Title,
            subtitle: UserText.networkProtectionWaitlistInvitedSection3Subtitle
        ),
    ]

    let action: WaitlistViewActionHandler

    @State private var shareButtonFrame: CGRect = .zero

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .center, spacing: 0) {
                    HeaderView(
                        imageName: "InvitedVPNWaitlist",
                        title: UserText.networkProtectionWaitlistInvitedTitle
                    )

                    Text(UserText.networkProtectionWaitlistInvitedSubtitle)
                        .daxBodyRegular()
                        .foregroundColor(.waitlistTextSecondary)
                        .padding(.top, 16)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(spacing: 16.0) {
                        ForEach(benefitsList) { WaitlistListEntryView(viewData: $0) }
                    }
                    .padding(.top, 24)

                    Button(UserText.networkProtectionWaitlistGetStarted, action: { action(.custom(.openNetworkProtectionPrivacyPolicyScreen)) })
                        .buttonStyle(RoundedButtonStyle(enabled: true))
                        .padding(.top, 32)
                    Spacer()
                    Text(UserText.networkProtectionWaitlistAvailabilityDisclaimer)
                        .font(.footnote)
                        .foregroundStyle(Color(designSystemColor: .textSecondary))
                        .padding(.top, 24)
                }
                .frame(maxWidth: .infinity, minHeight: proxy.size.height)
                .padding([.leading, .trailing], 18)
                .multilineTextAlignment(.center)
            }
        }
    }
}

@available(iOS 15.0, *)
struct VPNWaitlistPrivacyPolicyView: View {

    let action: WaitlistViewActionHandler

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(UserText.networkProtectionPrivacyPolicyTitle)
                    .font(.system(size: 17, weight: .bold))
                    .multilineTextAlignment(.leading)
                
                Group {
                    Text(VPNWaitlistUserText.networkProtectionPrivacyPolicySection1Title).titleStyle()

                    Text(.init(VPNWaitlistUserText.networkProtectionPrivacyPolicySection1ListMarkdown)).bodyStyle()
                    Text(VPNWaitlistUserText.networkProtectionPrivacyPolicySection2Title).titleStyle()
                    Text(VPNWaitlistUserText.networkProtectionPrivacyPolicySection2List).bodyStyle()
                    Text(VPNWaitlistUserText.networkProtectionPrivacyPolicySection3Title).titleStyle()
                    Text(VPNWaitlistUserText.networkProtectionPrivacyPolicySection3List).bodyStyle()
                    Text(VPNWaitlistUserText.networkProtectionPrivacyPolicySection4Title).titleStyle()
                    Text(VPNWaitlistUserText.networkProtectionPrivacyPolicySection4List).bodyStyle()
                    Text(VPNWaitlistUserText.networkProtectionPrivacyPolicySection5Title).titleStyle()
                    Text(VPNWaitlistUserText.networkProtectionPrivacyPolicySection5List).bodyStyle()
                }
                
                Text(VPNWaitlistUserText.networkProtectionTermsOfServiceTitle)
                    .font(.system(size: 17, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 28)
                    .padding(.bottom, 14)
                
                Group {
                    Text(VPNWaitlistUserText.networkProtectionTermsOfServiceSection1Title).titleStyle(topPadding: 0)
                    Text(VPNWaitlistUserText.networkProtectionTermsOfServiceSection1List).bodyStyle()
                    Text(VPNWaitlistUserText.networkProtectionTermsOfServiceSection2Title).titleStyle()
                    Text(.init(VPNWaitlistUserText.networkProtectionTermsOfServiceSection2ListMarkdown)).bodyStyle()
                    Text(VPNWaitlistUserText.networkProtectionTermsOfServiceSection3Title).titleStyle()
                    Text(VPNWaitlistUserText.networkProtectionTermsOfServiceSection3List).bodyStyle()
                    Text(VPNWaitlistUserText.networkProtectionTermsOfServiceSection4Title).titleStyle()
                    Text(VPNWaitlistUserText.networkProtectionTermsOfServiceSection4List).bodyStyle()
                    Text(VPNWaitlistUserText.networkProtectionTermsOfServiceSection5Title).titleStyle()
                    Text(VPNWaitlistUserText.networkProtectionTermsOfServiceSection5List).bodyStyle()
                }
                
                Group {
                    Text(VPNWaitlistUserText.networkProtectionTermsOfServiceSection6Title).titleStyle()
                    Text(VPNWaitlistUserText.networkProtectionTermsOfServiceSection6List).bodyStyle()
                    Text(VPNWaitlistUserText.networkProtectionTermsOfServiceSection7Title).titleStyle()
                    Text(VPNWaitlistUserText.networkProtectionTermsOfServiceSection7List).bodyStyle()
                    Text(VPNWaitlistUserText.networkProtectionTermsOfServiceSection8Title).titleStyle()
                    Text(VPNWaitlistUserText.networkProtectionTermsOfServiceSection8List).bodyStyle()
                }

                Button(UserText.networkProtectionWaitlistAgreeAndContinue, action: { action(.custom(.acceptNetworkProtectionTerms)) })
                    .buttonStyle(RoundedButtonStyle(enabled: true))
                    .padding(.top, 24)
            }
            .padding(.all, 20)
        }
    }

}

struct VPNWaitlistBenefit: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
}

private struct WaitlistListEntryView: View {

    let viewData: VPNWaitlistBenefit

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(viewData.imageName)

            VStack(alignment: .leading, spacing: 2) {
                Text(viewData.title)
                    .font(.system(size: 13, weight: .bold))
                    .opacity(0.8)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(viewData.subtitle)
                    .font(.system(size: 13))
                    .opacity(0.6)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)

            Spacer()
        }
    }

}

private extension Text {

    func titleStyle(topPadding: CGFloat = 24, bottomPadding: CGFloat = 14) -> some View {
        self
            .font(.system(size: 13, weight: .bold))
            .multilineTextAlignment(.leading)
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
    }

    func bodyStyle() -> some View {
        self
            .font(.system(size: 13))
    }

}

#endif
