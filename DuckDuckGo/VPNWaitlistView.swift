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
            VPNWaitlistInvitedView(viewData: NetworkProtectionInvitedToWaitlistViewData()) { action in
                Task { await viewModel.perform(action: action) }
            }
        case .waitlistRemoved:
            Text("Not supported")
        case .custom(let customState):
            if customState == .networkProtectionPrivacyPolicyScreen {
                VPNWaitlistPrivacyPolicyView()
            }
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
                    HeaderView(imageName: "JoinVPNWaitlist", title: UserText.networkProtectionWaitlistJoinTitle)

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
                        .padding(.top, 24)

                    Button("Join the Waitlist", action: { action(.joinQueue) })
                        .buttonStyle(RoundedButtonStyle(enabled: !requestInFlight))
                        .padding(.top, 24)

                    Button("I Have an Invite Code", action: { action(.custom(.openNetworkProtectionInviteCodeScreen)) })
                        .buttonStyle(RoundedButtonStyle(enabled: true, style: .bordered))
                        .padding(.top, 18)

                    if requestInFlight {
                        HStack {
                            Text(UserText.waitlistJoining)
                                .daxSubheadRegular()
                                .foregroundColor(.waitlistTextSecondary)

                            ActivityIndicator(style: .medium)
                        }
                        .padding(.top, 14)
                    }

                    Text(UserText.networkProtectionWaitlistAvailabilityDisclaimer)
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                        .padding(.top, 24)

                    Spacer()
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

            Button(UserText.waitlistAllowNotifications) {
                action(.openNotificationSettings)
            }
            .buttonStyle(RoundedButtonStyle(enabled: true))

        }
        .padding(24)
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

    let viewData: InvitedToWaitlistViewData

    let action: (WaitlistViewModel.ViewAction) -> Void

    @State private var shareButtonFrame: CGRect = .zero

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .center, spacing: 0) {
                    HeaderView(imageName: "InvitedVPNWaitlist", title: UserText.networkProtectionWaitlistInvitedTitle)

                    Text(UserText.networkProtectionWaitlistInvitedSubtitle)
                        .daxBodyRegular()
                        .foregroundColor(.waitlistTextSecondary)
                        .padding(.top, 16)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(spacing: 16.0) {
                        ForEach(viewData.entryViewViewDataList) { itemData in
                            WaitlistListEntryView(viewData: itemData)
                        }
                    }
                    .background(Color.red)
                    .padding(.top, 24)

                    Button("Get Started", action: { action(.custom(.openNetworkProtectionPrivacyPolicyScreen)) })
                        .buttonStyle(RoundedButtonStyle(enabled: true))
                        .padding(.top, 32)

                    Text(UserText.networkProtectionWaitlistAvailabilityDisclaimer)
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                        .padding(.top, 24)

                    Spacer()

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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(UserText.networkProtectionPrivacyPolicyTitle)
                    .font(.system(size: 15, weight: .bold))
                    .multilineTextAlignment(.leading)
                
                Group {
                    Text(UserText.networkProtectionPrivacyPolicySection1Title).titleStyle()

                    Text(LocalizedStringKey(UserText.networkProtectionPrivacyPolicySection1ListMarkdown)).bodyStyle()
                    Text(UserText.networkProtectionPrivacyPolicySection2Title).titleStyle()
                    Text(UserText.networkProtectionPrivacyPolicySection2List).bodyStyle()
                    Text(UserText.networkProtectionPrivacyPolicySection3Title).titleStyle()
                    Text(UserText.networkProtectionPrivacyPolicySection3List).bodyStyle()
                    Text(UserText.networkProtectionPrivacyPolicySection4Title).titleStyle()
                    Text(UserText.networkProtectionPrivacyPolicySection4List).bodyStyle()
                    Text(UserText.networkProtectionPrivacyPolicySection5Title).titleStyle()
                    Text(UserText.networkProtectionPrivacyPolicySection5List).bodyStyle()
                }
                
                Text(UserText.networkProtectionTermsOfServiceTitle)
                    .font(.system(size: 15, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 28)
                    .padding(.bottom, 14)
                
                Group {
                    Text(UserText.networkProtectionTermsOfServiceSection1Title).titleStyle(topPadding: 0)
                    Text(UserText.networkProtectionTermsOfServiceSection1List).bodyStyle()
                    Text(UserText.networkProtectionTermsOfServiceSection2Title).titleStyle()
                    Text(LocalizedStringKey(UserText.networkProtectionTermsOfServiceSection2ListMarkdown)).bodyStyle()
                    Text(UserText.networkProtectionTermsOfServiceSection3Title).titleStyle()
                    Text(UserText.networkProtectionTermsOfServiceSection3List).bodyStyle()
                    Text(UserText.networkProtectionTermsOfServiceSection4Title).titleStyle()
                    Text(UserText.networkProtectionTermsOfServiceSection4List).bodyStyle()
                    Text(UserText.networkProtectionTermsOfServiceSection5Title).titleStyle()
                    Text(UserText.networkProtectionTermsOfServiceSection5List).bodyStyle()
                }
                
                Group {
                    Text(UserText.networkProtectionTermsOfServiceSection6Title).titleStyle()
                    Text(UserText.networkProtectionTermsOfServiceSection6List).bodyStyle()
                    Text(UserText.networkProtectionTermsOfServiceSection7Title).titleStyle()
                    Text(UserText.networkProtectionTermsOfServiceSection7List).bodyStyle()
                    Text(UserText.networkProtectionTermsOfServiceSection8Title).titleStyle()
                    Text(UserText.networkProtectionTermsOfServiceSection8List).bodyStyle()
                }
            }
            .padding(.all, 20)
        }
    }

}

protocol InvitedToWaitlistViewData {
    var headerImageName: String { get }
    var title: String { get }
    var subtitle: String { get }
    var entryViewViewDataList: [WaitlistEntryViewItemViewData] { get }
    var availabilityDisclaimer: String { get }
    var buttonDismissLabel: String { get }
    var buttonGetStartedLabel: String { get }
}

struct WaitlistEntryViewItemViewData: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
}

struct NetworkProtectionInvitedToWaitlistViewData: InvitedToWaitlistViewData {
    let headerImageName = "Gift-96"
    let title = UserText.networkProtectionWaitlistInvitedTitle
    let subtitle = UserText.networkProtectionWaitlistInvitedSubtitle
    let buttonDismissLabel = UserText.networkProtectionWaitlistButtonDismiss
    let buttonGetStartedLabel = UserText.networkProtectionWaitlistButtonGetStarted
    let availabilityDisclaimer = UserText.networkProtectionWaitlistAvailabilityDisclaimer
    let entryViewViewDataList: [WaitlistEntryViewItemViewData] =
    [
        .init(imageName: "Shield-16",
              title: UserText.networkProtectionWaitlistInvitedSection1Title,
              subtitle: UserText.networkProtectionWaitlistInvitedSection1Subtitle),

        .init(imageName: "Rocket-16",
                  title: UserText.networkProtectionWaitlistInvitedSection2Title,
                  subtitle: UserText.networkProtectionWaitlistInvitedSection2Subtitle),

        .init(imageName: "Card-16",
                  title: UserText.networkProtectionWaitlistInvitedSection3Title,
                  subtitle: UserText.networkProtectionWaitlistInvitedSection3Subtitle),
    ]
}

private struct WaitlistListEntryView: View {
    let viewData: WaitlistEntryViewItemViewData

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(viewData.imageName)
                .frame(maxWidth: 16, maxHeight: 16)

            VStack(alignment: .leading, spacing: 6) {
                Text(viewData.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("BlackWhite80"))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(viewData.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(Color("BlackWhite60"))
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
            .font(.system(size: 11, weight: .bold))
            .multilineTextAlignment(.leading)
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
    }

    func bodyStyle() -> some View {
        self
            .font(.system(size: 11))
    }

}

// MARK: - Previews

private struct VPNWaitlistView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            PreviewView("Sign Up") {
                WindowsBrowserWaitlistSignUpView(requestInFlight: false) { _ in }
            }

            PreviewView("Sign Up (API Request In Progress)") {
                WindowsBrowserWaitlistSignUpView(requestInFlight: true) { _ in }
            }

            PreviewView("Joined Waitlist (Notifications Allowed)") {
                WindowsBrowserWaitlistJoinedWaitlistView(notificationState: .notificationAllowed) { _ in }
            }

            PreviewView("Joined Waitlist (Notifications Not Allowed)") {
                WindowsBrowserWaitlistJoinedWaitlistView(notificationState: .notificationsDisabled) { _ in }
            }

            PreviewView("Invite Screen With Code") {
                WindowsBrowserWaitlistInvitedView(inviteCode: "T3STC0DE") { _ in }
            }

            if #available(iOS 15.0, *) {
                WindowsBrowserWaitlistInvitedView(inviteCode: "T3STC0DE") { _ in }
                    .previewInterfaceOrientation(.landscapeLeft)
            }
        }
    }

    private struct PreviewView<Content: View>: View {
        let title: String
        var content: () -> Content

        init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
            self.title = title
            self.content = content
        }

        var body: some View {
            NavigationView {
                content()
                    .navigationTitle("DuckDuckGo Desktop App")
                    .navigationBarTitleDisplayMode(.inline)
                    .overlay(Divider(), alignment: .top)
            }
            .previewDisplayName(title)
        }
    }
}
