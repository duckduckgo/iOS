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

struct FailedAssertionView: View {
    var body: some View { EmptyView() }
    init(_ message: String) { assertionFailure(message) }
}


// swiftlint:disable file_length
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
            FailedAssertionView("Windows waitlist is not removed")
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
                        .font(.proximaNova(size: 16, weight: .regular))
                        .foregroundColor(.windowsWaitlistText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)

                    Button(UserText.waitlistJoin, action: { action(.joinQueue) })
                        .buttonStyle(RoundedButtonStyle(enabled: !requestInFlight))
                        .padding(.top, 24)

                    if requestInFlight {
                        HStack {
                            Text(UserText.waitlistJoining)
                                .font(.proximaNova(size: 15, weight: .regular))
                                .foregroundColor(.windowsWaitlistText)

                            ActivityIndicator(style: .medium)
                        }
                        .padding(.top, 14)
                    }

                    Spacer(minLength: 24)

                    Button(
                        action: {

                        }, label: {
                            HStack {
                                Image("WindowsWaitlistMac")
                                Text(UserText.windowsWaitlistMac)
                                    .font(.proximaNovaBold17)
                                    .foregroundColor(.windowsWaitlistBlue)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(5)
                            }
                        }
                    )
                    .padding(.bottom, 12)
                    .fixedSize(horizontal: false, vertical: true)

                    Text(UserText.waitlistPrivacyDisclaimer)
                        .font(.proximaNova(size: 13, weight: .regular))
                        .foregroundColor(.windowsWaitlistSubtitle)
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
            HeaderView(imageName: "WindowsWaitlistJoined", title: UserText.waitlistOnTheList)

            switch notificationState {
            case .notificationAllowed:
                Text(UserText.windowsWaitlistJoinedWithNotifications)
                    .font(.proximaNovaRegular17)
                    .foregroundColor(.windowsWaitlistText)
                    .lineSpacing(6)

            default:
                Text(UserText.windowsWaitlistJoinedWithoutNotifications)
                    .font(.proximaNovaRegular17)
                    .foregroundColor(.windowsWaitlistText)
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
                .font(.proximaNovaRegular17)
                .foregroundColor(.windowsWaitlistText)
                .lineSpacing(5)

            Button(UserText.waitlistAllowNotifications) {
                action(.openNotificationSettings)
            }
            .buttonStyle(RoundedButtonStyle(enabled: true))

        }
        .padding(24)
        .background(Color.windowsWaitlistNotificationBackground)
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
                    HeaderView(imageName: "WindowsWaitlistInvited", title: UserText.waitlistYoureInvited)

                    Text(UserText.windowsWaitlistInviteScreenSubtitle)
                        .font(.proximaNovaRegular17)
                        .foregroundColor(.windowsWaitlistText)
                        .padding(.top, 10)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(UserText.waitlistInviteScreenStepTitle(step: 1))
                        .font(.proximaNovaBold17)
                        .foregroundColor(.windowsWaitlistText)
                        .padding(.top, 22)
                        .padding(.bottom, 8)

                    Text(UserText.windowsWaitlistInviteScreenStep1Description)
                        .font(.proximaNovaRegular17)
                        .foregroundColor(.windowsWaitlistText)
                        .lineSpacing(6)

                    if #available(iOS 14.0, *) {
                        Text("duckduckgo.com/mac")
                            .font(.proximaNovaBold17)
                            .foregroundColor(.blue)
                            .menuController(UserText.waitlistCopy) {
                                action(.copyDownloadURLToPasteboard)
                            }
                            .padding(.top, 6)
                    } else {
                        Text("duckduckgo.com/mac")
                            .font(.proximaNovaBold17)
                            .foregroundColor(.blue)
                            .padding(.top, 6)
                    }

                    Text(UserText.waitlistInviteScreenStepTitle(step: 2))
                        .font(.proximaNovaBold17)
                        .foregroundColor(.windowsWaitlistText)
                        .padding(.top, 22)
                        .padding(.bottom, 8)

                    Text(UserText.windowsWaitlistInviteScreenStep2Description)
                        .font(.proximaNovaRegular17)
                        .foregroundColor(.windowsWaitlistText)
                        .lineSpacing(6)

                    if #available(iOS 14.0, *) {
                        InviteCodeView(inviteCode: inviteCode)
                            .menuController(UserText.waitlistCopy) {
                                action(.copyInviteCodeToPasteboard)
                            }
                            .padding(.top, 28)
                    } else {
                        InviteCodeView(inviteCode: inviteCode)
                            .padding(.top, 28)
                    }


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
                .foregroundColor(.windowsWaitlistText)
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

private struct InviteCodeView: View {

    let inviteCode: String

    var body: some View {
        VStack(spacing: 4) {
            Text(UserText.waitlistInviteCode)
                .font(.proximaNovaRegular17)
                .foregroundColor(.white)
                .padding([.top, .bottom], 4)

            Text(inviteCode)
                .font(.system(size: 34, weight: .semibold, design: .monospaced))
                .padding([.leading, .trailing], 18)
                .padding([.top, .bottom], 6)
                .foregroundColor(.black)
                .background(Color.white)
                .cornerRadius(4)
        }
        .padding(4)
        .background(Color.windowsWaitlistGreen)
        .cornerRadius(8)
    }

}

// MARK: - Generic Views

private struct HeaderView: View {

    let imageName: String
    let title: String

    var body: some View {
        VStack(spacing: 18) {
            Image(imageName)

            Text(title)
                .font(.proximaNova(size: 22, weight: .bold))
        }
        .padding(.top, 24)
        .padding(.bottom, 12)
    }

}

private struct RoundedButtonStyle: ButtonStyle {

    let enabled: Bool

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.proximaNovaBold17)
            .frame(maxWidth: .infinity)
            .padding([.top, .bottom], 16)
            .background(enabled ? Color.windowsWaitlistBlue : Color.windowsWaitlistBlue.opacity(0.2))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

}

private struct ActivityIndicator: UIViewRepresentable {

    typealias UIViewType = UIActivityIndicatorView

    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ view: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        view.startAnimating()
    }

}

// MARK: - Previews

private struct WindowsBrowserWaitlistView_Previews: PreviewProvider {

    static var previews: some View {
        if #available(iOS 14.0, *) {
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
        } else {
            Text("Use iOS 14+ simulator")
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
                if #available(iOS 14.0, *) {
                    content()
                        .navigationTitle("DuckDuckGo Desktop App")
                        .navigationBarTitleDisplayMode(.inline)
                        .overlay(Divider(), alignment: .top)
                } else {
                    content()
                }

            }
            .previewDisplayName(title)
        }
    }
}

// MARK: - Extensions

private extension Color {

    static var windowsWaitlistText: Color {
        Color("WindowsWaitlistTextColor")
    }

    static var windowsWaitlistSubtitle: Color {
        Color("WindowsWaitlistSubtitleColor")
    }

    static var windowsWaitlistGreen: Color {
        Color("WindowsWaitlistGreen")
    }

    static var windowsWaitlistBlue: Color {
        Color("WindowsWaitlistBlue")
    }

    static var windowsWaitlistNotificationBackground: Color {
        Color("WindowsWaitlistNotificationsBackgroundColor")
    }

}

private extension Font {

    static var proximaNovaRegular17: Self {
        let fontName = "proximanova-\(Font.ProximaNovaWeight.regular.rawValue)"
        return .custom(fontName, size: 17)
    }

    static var proximaNovaBold17: Self {
        let fontName = "proximanova-\(Font.ProximaNovaWeight.bold.rawValue)"
        return .custom(fontName, size: 17)
    }

}

// swiftlint:enable file_length
