//
//  WindowsBrowserWaitlistView.swift
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

struct WindowsBrowserWaitlistView: View {

    @EnvironmentObject var viewModel: WaitlistViewModel

    var body: some View {
        switch viewModel.viewState {
        case .notJoinedQueue:
            WindowsBrowserWaitlistSignUpView(requestInFlight: false) { action in
                Task { await viewModel.perform(action: action) }
            }
        case .joiningQueue:
            WindowsBrowserWaitlistSignUpView(requestInFlight: true) { action in
                Task { await viewModel.perform(action: action) }
            }
        case .joinedQueue(let state):
            WindowsBrowserWaitlistJoinedWaitlistView(notificationState: state) { action in
                Task { await viewModel.perform(action: action) }
            }
        case .invited(let inviteCode):
            WindowsBrowserWaitlistInvitedView(inviteCode: inviteCode) { action in
                Task { await viewModel.perform(action: action) }
            }
        case .waitlistRemoved:
            WaitlistDownloadBrowserContentView(platform: .windows) { action in
                Task { await viewModel.perform(action: action) }
            }
        }
    }
}

struct WindowsBrowserWaitlistSignUpView: View {

    let requestInFlight: Bool

    let action: WaitlistViewActionHandler

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .center, spacing: 8) {
                    HeaderView(imageName: "WindowsWaitlistJoinWaitlist", title: UserText.windowsWaitlistTryDuckDuckGoForWindows)

                    Text(UserText.windowsWaitlistSummary)
                        .daxBodyRegular()
                        .foregroundColor(.waitlistTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)

                    Button(UserText.waitlistJoin, action: { action(.joinQueue) })
                        .buttonStyle(RoundedButtonStyle(enabled: !requestInFlight))
                        .padding(.top, 24)

                    if requestInFlight {
                        HStack {
                            Text(UserText.waitlistJoining)
                                .daxSubheadRegular()
                                .foregroundColor(.waitlistTextSecondary)

                            ActivityIndicator(style: .medium)
                        }
                        .padding(.top, 14)
                    }

                    Spacer(minLength: 24)

                    Button(
                        action: {
                            action(.custom(.openMacBrowserWaitlist))
                        }, label: {
                            Text(UserText.windowsWaitlistMac)
                                .daxHeadline()
                                .foregroundColor(.waitlistBlue)
                                .multilineTextAlignment(.center)
                                .lineSpacing(5)
                        }
                    )
                    .padding(.bottom, 12)
                    .fixedSize(horizontal: false, vertical: true)

                    Text(UserText.waitlistPrivacyDisclaimer)
                        .daxFootnoteRegular()
                        .foregroundColor(.waitlistTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .padding(.bottom, 12)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding([.leading, .trailing], 24)
                .frame(minHeight: proxy.size.height)
            }
        }
    }

}

// MARK: - Joined Waitlist Views

struct WindowsBrowserWaitlistJoinedWaitlistView: View {

    let notificationState: WaitlistViewModel.NotificationPermissionState

    let action: (WaitlistViewModel.ViewAction) -> Void

    var body: some View {
        VStack(spacing: 16) {
            HeaderView(imageName: "WaitlistJoined", title: UserText.waitlistOnTheList)

            switch notificationState {
            case .notificationAllowed:
                Text(UserText.windowsWaitlistJoinedWithNotifications)
                    .daxBodyRegular()
                    .foregroundColor(.waitlistTextSecondary)
                    .lineSpacing(6)

            default:
                Text(UserText.windowsWaitlistJoinedWithoutNotifications)
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

struct WindowsBrowserWaitlistInvitedView: View {

    let inviteCode: String
    let action: (WaitlistViewModel.ViewAction) -> Void

    @State private var shareButtonFrame: CGRect = .zero

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .center, spacing: 0) {
                    HeaderView(imageName: "WaitlistInvited", title: UserText.waitlistYoureInvited)

                    Text(UserText.windowsWaitlistInviteScreenSubtitle)
                        .daxBodyRegular()
                        .foregroundColor(.waitlistTextSecondary)
                        .padding(.top, 16)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(UserText.waitlistInviteScreenStepTitle(step: 1))
                        .daxHeadline()
                        .foregroundColor(.waitlistTextSecondary)
                        .padding(.top, 28)
                        .padding(.bottom, 8)

                    Text(UserText.windowsWaitlistInviteScreenStep1Description)
                        .daxBodyRegular()
                        .foregroundColor(.waitlistTextSecondary)
                        .lineSpacing(6)

                    Text(URL.windows.absoluteString.dropping(prefix: "https://"))
                        .daxHeadline()
                        .foregroundColor(.waitlistBlue)
                        .menuController(UserText.waitlistCopy) {
                            action(.copyDownloadURLToPasteboard)
                        }
                        .scaledToFit()

                    Text(UserText.waitlistInviteScreenStepTitle(step: 2))
                        .daxHeadline()
                        .foregroundColor(.waitlistTextSecondary)
                        .padding(.top, 22)
                        .padding(.bottom, 8)

                    Text(UserText.windowsWaitlistInviteScreenStep2Description)
                        .daxBodyRegular()
                        .foregroundColor(.waitlistTextSecondary)
                        .lineSpacing(6)

                    InviteCodeView(title: UserText.waitlistInviteCode, inviteCode: inviteCode)
                        .menuController(UserText.waitlistCopy) {
                            action(.copyInviteCodeToPasteboard)
                        }
                        .fixedSize()
                        .padding(.top, 28)

                    Spacer(minLength: 24)

                    shareButton
                        .padding(.bottom, 26)

                }
                .frame(maxWidth: .infinity, minHeight: proxy.size.height)
                .padding([.leading, .trailing], 18)
                .multilineTextAlignment(.center)
            }
        }
    }

    var shareButton: some View {

        Button(action: {
            action(.openShareSheet(shareButtonFrame))
        }, label: {
            Image("Share")
                .foregroundColor(.waitlistTextSecondary)
        })
        .frame(width: 44, height: 44)
        .background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: ShareButtonFramePreferenceKey.self, value: proxy.frame(in: .global))
            }
        )
        .onPreferenceChange(ShareButtonFramePreferenceKey.self) { newFrame in
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.shareButtonFrame = newFrame
            }
        }

    }

}

// MARK: - Previews

private struct WindowsBrowserWaitlistView_Previews: PreviewProvider {

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
