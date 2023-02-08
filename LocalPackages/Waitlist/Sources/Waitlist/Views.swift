//
//  Views.swift
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

public struct HeaderView: View {

    public let imageName: String
    public let title: String

    public init(imageName: String, title: String) {
        self.imageName = imageName
        self.title = title
    }

    public var body: some View {
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

public struct RoundedButtonStyle: ButtonStyle {

    public let enabled: Bool

    public init(enabled: Bool) {
        self.enabled = enabled
    }

    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.proximaNova(size: 17, weight: .bold))
            .frame(maxWidth: .infinity)
            .padding([.top, .bottom], 16)
            .background(enabled ? Color.waitlistBlue : Color.waitlistBlue.opacity(0.2))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

}

public struct InviteCodeView: View {

    public let title: String
    public let inviteCode: String

    public init(title: String, inviteCode: String) {
        self.title = title
        self.inviteCode = inviteCode
    }

    public var body: some View {
        VStack(spacing: 4) {
            Text(title)
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

public struct ActivityIndicator: UIViewRepresentable {

    public typealias UIViewType = UIActivityIndicatorView

    public let style: UIActivityIndicatorView.Style

    public init(style: UIActivityIndicatorView.Style) {
        self.style = style
    }

    public func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    public func updateUIView(_ view: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        view.startAnimating()
    }

}

extension View {
    /**
     * Ensures that multiline text is properly broken into lines
     * when put in scroll views.
     *
     * As seen on [Stack Overflow](https://stackoverflow.com/a/70512685).
     * Radar: FB6859124.
     */
    func fixMultilineScrollableText() -> some View {
        lineLimit(nil).modifier(MultilineScrollableTextFix())
    }
}

private struct MultilineScrollableTextFix: ViewModifier {

    func body(content: Content) -> some View {
        return AnyView(content.fixedSize(horizontal: false, vertical: true))
    }
}

extension Font {

    enum ProximaNovaWeight: String {
        case light
        case regular
        case semiBold = "semibold"
        case bold
        case extraBold = "extrabold"
    }

    static func proximaNova(size: CGFloat, weight: ProximaNovaWeight = .regular) -> Self {
        let fontName = "proximanova-\(weight.rawValue)"
        return .custom(fontName, size: size)
    }

}
