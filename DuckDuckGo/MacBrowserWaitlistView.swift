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
            Image("EmailWaitlistWeHatched")
            
            Text("Try DuckDuckGo for the Mac")
                .font(.system(size: 22, weight: .semibold, design: .default))
            
            Text("We're bringing Privacy Simplified to your desktop and we would ❤️ your feedback.")
                .multilineTextAlignment(.center)
            
            Button("Join the Private Waitlist") {
                
            }
            .buttonStyle(RoundedButtonStyle(enabled: !requestInFlight))
            .padding(.top, 24)
            
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
        .padding([.leading, .trailing], 32)
    }
}
 
struct RoundedButtonStyle: ButtonStyle {
    let enabled: Bool

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .padding(12)
            .background(enabled ? Color(UIColor.systemBlue) : Color(UIColor.lightGray))
            .foregroundColor(enabled ? .white : .gray)
            .cornerRadius(8)
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
        Group {
            MacBrowserWaitlistSignUpView(requestInFlight: false)
            
            MacBrowserWaitlistSignUpView(requestInFlight: true)
        }
    }
}
