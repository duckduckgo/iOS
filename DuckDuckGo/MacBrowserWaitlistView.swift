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

struct MacBrowserWaitlistView: View {

    @EnvironmentObject var viewModel: MacWaitlistViewModel
    
    var body: some View {
        MacBrowserWaitlistSignUpView(requestInFlight: false)
    }

}

struct MacBrowserWaitlistSignUpView: View {

    let requestInFlight: Bool

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            HeaderView(imageName: "MacWaitlistJoinWaitlist", title: "Try DuckDuckGo for Mac!")
            
            Text(UserText.macBrowserWaitlistSummary)
                .foregroundColor(Color("MacWaitlistTextColor"))
                .multilineTextAlignment(.center)
            
            Button("Join the Private Waitlist") {
                print("Joining waitlist")
            }
            .buttonStyle(RoundedButtonStyle(enabled: !requestInFlight))
            .padding(.top, 24)
            
            Text("Windows coming soon!")
            
            if requestInFlight {
                HStack {
                    Text("Joining Waitlist...")
                    ActivityIndicator(style: .medium)
                }
            }
            
            Spacer()
            
            Text(UserText.macWaitlistPrivacyDisclaimer)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding([.leading, .trailing], 24)
    }

}

// MARK: - Joined Waitlist Views

struct MacBrowserWaitlistJoinedWaitlistView: View {
    
    let notificationState: MacWaitlistViewModel.NotificationPermissionState
    
    var body: some View {
        ZStack {
            if #available(iOS 14.0, *) {
                Color("MacWaitlistBackgroundColor")
                    .ignoresSafeArea()
            } else {
                Color("MacWaitlistBackgroundColor")
            }

            VStack(spacing: 16) {
                HeaderView(imageName: "MacWaitlistJoined", title: "You're on the list!")
                
                switch notificationState {
                case .notificationAllowed:
                    Text(UserText.macBrowserWaitlistJoinedWithNotifications)
                        .foregroundColor(Color("MacWaitlistTextColor"))
                case .notificationDenied:
                    Text(UserText.macBrowserWaitlistJoinedWithoutNotifications)
                        .foregroundColor(Color("MacWaitlistTextColor"))
                    
                    Button("Notify Me") {
                        print("Notifying")
                    }
                    .buttonStyle(RoundedButtonStyle(enabled: true))
                    .padding(.top, 24)
                case .cannotPromptForNotification:
                    Text(UserText.macBrowserWaitlistJoinedWithoutNotifications)
                        .foregroundColor(Color("MacWaitlistTextColor"))
                    
                    AllowNotificationsView()
                        .padding(.top, 8)
                }
                
                Spacer()
            }
            .padding([.leading, .trailing], 24)
        }
        .multilineTextAlignment(.center)
    }
    
}

private struct AllowNotificationsView: View {
    
    var body: some View {
        
        VStack {
            
            Text("We can notify you when it’s your turn, but notifications are currently disabled for DuckDuckGo.")
                .foregroundColor(Color("MacWaitlistTextColor"))
            
            Button("Allow Notifications") {
                
            }
            .buttonStyle(RoundedButtonStyle(enabled: true))
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
        
    }
    
}

// MARK: - Invite Available Views

private struct InviteCodeView: View {
    
    let inviteCode: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(UserText.macBrowserWaitlistInviteCode)
                .font(.system(size: 17))
                .foregroundColor(.white)

            Text(inviteCode)
                .font(.system(size: 34, weight: .semibold, design: .monospaced))
                .padding([.leading, .trailing], 18)
                .padding([.top, .bottom], 6)
                .foregroundColor(.black)
                .background(Color.white)
                .cornerRadius(4)
        }
        .padding(4)
        .background(Color.green)
        .cornerRadius(8)
    }
    
}

// MARK: - Generic Views
 
struct HeaderView: View {
    
    let imageName: String
    let title: String
    
    var body: some View {
        VStack {
            Image(imageName)
            
            Text(title)
                .font(.system(size: 22, weight: .semibold, design: .default))
        }
        .padding(.top, 16)
    }
    
}

struct RoundedButtonStyle: ButtonStyle {

    let enabled: Bool

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding([.top, .bottom], 12)
            .background(enabled ? Color("MacWaitlistBlue") : Color(UIColor.lightGray))
            .foregroundColor(enabled ? .white : .gray)
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
    static var previews: some View {
        if #available(iOS 14.0, *) {
            Group {
                NavigationView {
                    MacBrowserWaitlistSignUpView(requestInFlight: false)
                        .navigationTitle("DuckDuckGo Desktop App")
                        .navigationBarTitleDisplayMode(.inline)
                        .overlay(Divider(), alignment: .top)
                }
                .previewDisplayName("Sign Up")
                
                MacBrowserWaitlistSignUpView(requestInFlight: true)
                    .previewDisplayName("Sign Up Request In-Flight")
                
                NavigationView {
                    MacBrowserWaitlistJoinedWaitlistView(notificationState: .notificationAllowed)
                        .navigationTitle("DuckDuckGo Desktop App")
                        .navigationBarTitleDisplayMode(.inline)
                        .overlay(Divider(), alignment: .top)
                }
                .previewDisplayName("Joined Waitlist – Notifications Allowed")
                
                NavigationView {
                    MacBrowserWaitlistJoinedWaitlistView(notificationState: .notificationDenied)
                        .navigationTitle("DuckDuckGo Desktop App")
                        .navigationBarTitleDisplayMode(.inline)
                        .overlay(Divider(), alignment: .top)
                }
                .previewDisplayName("Joined Waitlist – Notifications Denied")
                
                NavigationView {
                    MacBrowserWaitlistJoinedWaitlistView(notificationState: .cannotPromptForNotification)
                        .navigationTitle("DuckDuckGo Desktop App")
                        .navigationBarTitleDisplayMode(.inline)
                        .overlay(Divider(), alignment: .top)
                }
                .previewDisplayName("Joined Waitlist – Notifications Not Allowed")
                
                InviteCodeView(inviteCode: "F20IZILP")
                    .previewLayout(PreviewLayout.sizeThatFits)
                    .previewDisplayName("Invite Code View")
            }
        } else {
            Text("Use iOS 14+ simulator")
        }
    }
}
