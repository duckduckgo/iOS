//
//  MacBrowserWaitlistView.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

typealias ViewActionHandler = (MacWaitlistViewModel.ViewAction) -> Void

// swiftlint:disable file_length
struct MacBrowserWaitlistView: View {

    @EnvironmentObject var viewModel: MacWaitlistViewModel
    
    var body: some View {
        switch viewModel.viewState {
        case .notJoinedQueue:
            MacBrowserWaitlistSignUpView(requestInFlight: false,
                                         showNotificationAlert: $viewModel.showNotificationPrompt) { action in
                Task { await viewModel.perform(action: action) }
            }
        case .joiningQueue:
            MacBrowserWaitlistSignUpView(requestInFlight: true,
                                         showNotificationAlert: $viewModel.showNotificationPrompt) { action in
                Task { await viewModel.perform(action: action) }
            }
        case .joinedQueue(let state):
            MacBrowserWaitlistJoinedWaitlistView(notificationState: state,
                                                 showNotificationAlert: $viewModel.showNotificationPrompt) { action in
                Task { await viewModel.perform(action: action) }
            }
        case .invited(let inviteCode):
            MacBrowserWaitlistInvitedView(inviteCode: inviteCode,
                                          activityItems: viewModel.createShareSheetActivityItems(),
                                          showShareSheet: $viewModel.showShareSheet) { action in
                Task { await viewModel.perform(action: action) }
            }
        }
    }

}

struct MacBrowserWaitlistSignUpView: View {

    let requestInFlight: Bool
    @Binding var showNotificationAlert: Bool
    
    let action: ViewActionHandler

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .center, spacing: 8) {
                    HeaderView(imageName: "MacWaitlistJoinWaitlist", title: UserText.macWaitlistTryDuckDuckGoForMac)
                    
                    Text(UserText.macWaitlistSummary)
                        .font(.custom("proximanova-regular", size: 16))
                        .foregroundColor(.macWaitlistText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                    
                    Button(UserText.macWaitlistJoin, action: { action(.joinQueue) })
                        .buttonStyle(RoundedButtonStyle(enabled: !requestInFlight))
                        .padding(.top, 24)
                        .alert(isPresented: $showNotificationAlert, content: { Alert.notificationPermissionAlert(action: action) })
                    
                    Text(UserText.macWaitlistWindows)
                        .font(.custom("proximanova-regular", size: 14))
                        .foregroundColor(.macWaitlistSubtitle)
                        .padding(.top, 4)
                    
                    if requestInFlight {
                        HStack {
                            Text(UserText.macWaitlistJoining)
                                .font(.custom("proximanova-regular", size: 15))
                                .foregroundColor(.macWaitlistText)
                            
                            ActivityIndicator(style: .medium)
                        }
                        .padding(.top, 14)
                    }
                    
                    Spacer(minLength: 24)
                    
                    Text(UserText.macWaitlistPrivacyDisclaimer)
                        .font(.custom("proximanova-regular", size: 13))
                        .foregroundColor(.macWaitlistSubtitle)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                }
                .padding([.leading, .trailing], 24)
                .frame(minHeight: proxy.size.height)
            }
        }
    }

}

// MARK: - Joined Waitlist Views

struct MacBrowserWaitlistJoinedWaitlistView: View {
    
    let notificationState: MacWaitlistViewModel.NotificationPermissionState
    @Binding var showNotificationAlert: Bool

    let action: (MacWaitlistViewModel.ViewAction) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HeaderView(imageName: "MacWaitlistJoined", title: UserText.macWaitlistOnTheList)
            
            switch notificationState {
            case .notificationAllowed:
                Text(UserText.macWaitlistJoinedWithNotifications)
                    .font(.custom("proximanova-regular", size: 17))
                    .foregroundColor(.macWaitlistText)
                    .lineSpacing(6)

            case .notificationDenied:
                Text(UserText.macWaitlistJoinedWithoutNotifications)
                    .font(.custom("proximanova-regular", size: 17))
                    .foregroundColor(.macWaitlistText)
                    .lineSpacing(6)
                
                Button("Notify Me") {
                    action(.requestNotificationPrompt)
                }
                .buttonStyle(RoundedButtonStyle(enabled: true))
                .padding(.top, 24)
                .alert(isPresented: $showNotificationAlert, content: { Alert.notificationPermissionAlert(action: action) })

            case .notificationsDisabled:
                Text(UserText.macWaitlistJoinedWithoutNotifications)
                    .font(.custom("proximanova-regular", size: 17))
                    .foregroundColor(.macWaitlistText)
                    .lineSpacing(6)
                
                AllowNotificationsView(action: action)
                    .padding(.top, 4)
            }
            
            Spacer()
        }
        .padding([.leading, .trailing], 24)
        .multilineTextAlignment(.center)
    }

}

private extension Alert {
    
    static func notificationPermissionAlert(action: @escaping ViewActionHandler) -> Alert {
        let accept = ActionSheet.Button.default(Text(UserText.macWaitlistNotificationNotifyMe)) { action(.acceptNotifications) }
        let decline = ActionSheet.Button.cancel(Text(UserText.macWaitlistNotificationNoThanks)) { action(.declineNotifications) }
        
        return Alert(title: Text(UserText.macWaitlistNotificationTitle),
                     message: Text(UserText.macWaitlistNotificationMessage),
                     primaryButton: accept,
                     secondaryButton: decline)
    }
    
}

private struct AllowNotificationsView: View {
    
    let action: (MacWaitlistViewModel.ViewAction) -> Void

    var body: some View {
        
        VStack(spacing: 20) {
            
            Text(UserText.macWaitlistNotificationDisabled)
                .font(.custom("proximanova-regular", size: 17))
                .foregroundColor(.macWaitlistText)
                .lineSpacing(5)
            
            Button("Allow Notifications") {
                action(.openNotificationSettings)
            }
            .buttonStyle(RoundedButtonStyle(enabled: true))
            
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
        
    }
    
}

// MARK: - Invite Available Views

struct MacBrowserWaitlistInvitedView: View {
    
    let inviteCode: String
    let activityItems: [Any]
    
    @Binding var showShareSheet: Bool
    
    let action: (MacWaitlistViewModel.ViewAction) -> Void
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .center, spacing: 0) {
                    HeaderView(imageName: "MacWaitlistInvited", title: UserText.macWaitlistYoureInvited)
                    
                    Text(UserText.macWaitlistInviteScreenSubtitle)
                        .font(.custom("proximanova-regular", size: 17))
                        .foregroundColor(.macWaitlistText)
                        .padding(.top, 10)
                    
                    Text(UserText.macWaitlistInviteScreenStep1Title)
                        .font(.custom("proximanova-bold", size: 17))
                        .foregroundColor(.macWaitlistText)
                        .padding(.top, 22)
                        .padding(.bottom, 8)
                    
                    Text(UserText.macWaitlistInviteScreenStep1Description)
                        .font(.custom("proximanova-regular", size: 17))
                        .foregroundColor(.macWaitlistText)
                    
                    Text("duckduckgo.com/mac")
                        .font(.custom("proximanova-bold", size: 17))
                        .foregroundColor(.blue)
                        .menuController(UserText.macWaitlistCopy) {
                            action(.copyDownloadURLToPasteboard)
                        }
                        .padding(.top, 6)
                    
                    Text(UserText.macWaitlistInviteScreenStep2Title)
                        .font(.custom("proximanova-bold", size: 17))
                        .foregroundColor(.macWaitlistText)
                        .padding(.top, 22)
                        .padding(.bottom, 8)
                    
                    Text(UserText.macWaitlistInviteScreenStep2Description)
                        .font(.custom("proximanova-regular", size: 17))
                        .foregroundColor(.macWaitlistText)
                        .lineSpacing(6)
                    
                    InviteCodeView(inviteCode: inviteCode)
                        .menuController(UserText.macWaitlistCopy) {
                            action(.copyInviteCodeToPasteboard)
                        }
                        .padding(.top, 28)
                    
                    Spacer(minLength: 24)
                    
                    Button(action: {
                        action(.openShareSheet)
                    }, label: {
                        Image("Share")
                            .foregroundColor(.macWaitlistText)
                    })
                        .padding(.bottom, 18)
                        .sheet(isPresented: $showShareSheet, onDismiss: {
                            // Nothing to do
                        }, content: {
                            ActivityViewController(activityItems: activityItems)
                        })
                }
                .frame(maxWidth: .infinity, minHeight: proxy.size.height)
                .padding([.leading, .trailing], 18)
                .multilineTextAlignment(.center)
            }
        }
    }
    
}

private struct InviteCodeView: View {
    
    let inviteCode: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(UserText.macWaitlistInviteCode)
                .font(.custom("proximanova-regular", size: 17))
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
        .background(Color.macWaitlistGreen)
        .cornerRadius(8)
    }
    
}

// MARK: - Generic Views
 
struct HeaderView: View {
    
    let imageName: String
    let title: String
    
    var body: some View {
        VStack(spacing: 18) {
            Image(imageName)
            
            Text(title)
                .font(.custom("proximanova-bold", size: 22))
        }
        .padding(.top, 24)
        .padding(.bottom, 12)
    }
    
}

struct RoundedButtonStyle: ButtonStyle {

    let enabled: Bool

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.custom("proximanova-bold", size: 16))
            .frame(maxWidth: .infinity)
            .padding([.top, .bottom], 12)
            .background(enabled ? Color.macWaitlistBlue : Color.macWaitlistBlue.opacity(0.2))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }

}

struct ActivityIndicator: UIViewRepresentable {
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

struct MacBrowserWaitlistView_Previews: PreviewProvider {
    @State static var showNotification = true
    @State static var hideNotification = false

    @State static var showShareSheet = false
    
    static var previews: some View {
        if #available(iOS 14.0, *) {
            Group {
                PreviewView("Sign Up") {
                    MacBrowserWaitlistSignUpView(requestInFlight: false,
                                                 showNotificationAlert: $hideNotification) { _ in }
                }
                
                PreviewView("Sign Up (API Request In Progress)") {
                    MacBrowserWaitlistSignUpView(requestInFlight: true,
                                                 showNotificationAlert: $hideNotification) { _ in }
                }
                
                PreviewView("Sign Up (API Request In Progress, With Alert)") {
                    MacBrowserWaitlistSignUpView(requestInFlight: true,
                                                 showNotificationAlert: $showNotification) { _ in }
                }
                
                PreviewView("Joined Waitlist (Notifications Allowed)") {
                    MacBrowserWaitlistJoinedWaitlistView(notificationState: .notificationAllowed, showNotificationAlert: $hideNotification) { _ in }
                }
                
                PreviewView("Joined Waitlist (Notifications Denied)") {
                    MacBrowserWaitlistJoinedWaitlistView(notificationState: .notificationDenied, showNotificationAlert: $hideNotification) { _ in }
                }
                
                PreviewView("Joined Waitlist (Notifications Not Allowed)") {
                    MacBrowserWaitlistJoinedWaitlistView(notificationState: .notificationsDisabled,
                                                         showNotificationAlert: $hideNotification) { _ in }
                }
                
                PreviewView("Invite Screen With Code") {
                    MacBrowserWaitlistInvitedView(inviteCode: "T3STC0DE",
                                                  activityItems: [],
                                                  showShareSheet: $showShareSheet) { _ in }
                }
                
                if #available(iOS 15.0, *) {
                    MacBrowserWaitlistInvitedView(inviteCode: "T3STC0DE",
                                                  activityItems: [],
                                                  showShareSheet: $showShareSheet) { _ in }
                    .previewInterfaceOrientation(.landscapeLeft)
                }
            }
        } else {
            Text("Use iOS 14+ simulator")
        }
    }
    
    struct PreviewView<Content: View>: View {
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

private extension Color {
    
    static var macWaitlistText: Color {
        Color("MacWaitlistTextColor")
    }

    static var macWaitlistSubtitle: Color {
        Color("MacWaitlistSubtitleColor")
    }
    
    static var macWaitlistGreen: Color {
        Color("MacWaitlistGreen")
    }
    
    static var macWaitlistBlue: Color {
        Color("MacWaitlistBlue")
    }
    
}
// swiftlint:enable file_length
