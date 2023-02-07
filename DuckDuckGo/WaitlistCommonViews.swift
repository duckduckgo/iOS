//
//  WaitlistCommonViews.swift
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

struct WaitlistHeaderView: View {

    let imageName: String
    let title: String

    var body: some View {
        VStack(spacing: 18) {
            Image(imageName)

            Text(title)
                .font(.proximaNova(size: 22, weight: .bold))
                .multilineTextAlignment(.center)
                .fixMultilineScrollableText()
        }
        .padding(.top, 24)
        .padding(.bottom, 12)
    }

}

struct WaitlistRoundedButtonStyle: ButtonStyle {

    let enabled: Bool

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.proximaNova(size: 17, weight: .bold))
            .frame(maxWidth: .infinity)
            .padding([.top, .bottom], 16)
            .background(enabled ? Color.waitlistBlue : Color.waitlistBlue.opacity(0.2))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

}

struct InviteCodeView: View {

    let inviteCode: String

    var body: some View {
        VStack(spacing: 4) {
            Text(UserText.waitlistInviteCode)
                .font(.proximaNova(size: 17))
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
        .background(Color.waitlistGreen)
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
