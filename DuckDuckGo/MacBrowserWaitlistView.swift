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

typealias WaitlistViewActionHandler = (WaitlistViewModel.ViewAction) -> Void

struct MacBrowserWaitlistView: View {

    @EnvironmentObject var viewModel: WaitlistViewModel
    
    var body: some View {
        MacBrowserWaitlistContentView { action in
            Task { await viewModel.perform(action: action) }
        }
    }

}

private struct ShareButtonFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}

struct MacBrowserWaitlistContentView: View {
    
    enum Constants {
        static let downloadURL = "duckduckgo.com/mac"
    }
    
    let action: WaitlistViewActionHandler
    
    @State private var shareButtonFrame: CGRect = .zero

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .center, spacing: 8) {
                    HeaderView(imageName: "MacWaitlistJoinWaitlist", title: UserText.macWaitlistTryDuckDuckGoForMac)
                    
                    Text(UserText.macWaitlistSummary)
                        .font(.proximaNova(size: 16, weight: .regular))
                        .foregroundColor(.macWaitlistText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                    
                    Text(UserText.macWaitlistOnYourMacGoTo)
                        .font(.proximaNova(size: 16, weight: .regular))
                        .foregroundColor(.macWaitlistText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.top, 18)

                    Text(Constants.downloadURL)
                        .font(.proximaNovaBold17)
                        .foregroundColor(.macWaitlistBlue)
                        .menuController(UserText.waitlistCopy) {
                            action(.copyDownloadURLToPasteboard)
                        }
                        .fixedSize()

                    Button(
                        action: {
                            action(.openShareSheet(shareButtonFrame))
                        }, label: {
                            HStack {
                                Image("Share-16")
                                Text(UserText.waitlistShareLink)
                            }
                        }
                    )
                    .buttonStyle(RoundedButtonStyle(enabled: true))
                    .padding(.top, 24)
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
                    
                    Spacer(minLength: 24)

                    Button(
                        action: {

                        }, label: {
                            HStack {
                                Image("MacWaitlistWindows")
                                Text(UserText.macWaitlistWindows)
                                    .font(.proximaNovaBold17)
                                    .foregroundColor(.macWaitlistBlue)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(5)
                            }
                        }
                    )
                    .padding(.bottom, 12)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding([.leading, .trailing], 24)
                .frame(minHeight: proxy.size.height)
            }
        }
    }
    
    var shareButton: some View {
        
        Button(action: {
            action(.openShareSheet(shareButtonFrame))
        }, label: {
            Image("Share")
                .foregroundColor(.macWaitlistText)
        })
        .frame(width: 44, height: 44)
        
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
            .background(enabled ? Color.macWaitlistBlue : Color.macWaitlistBlue.opacity(0.2))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

}

// MARK: - Previews

private struct MacBrowserWaitlistView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            PreviewView("Mac Browser Beta") {
                MacBrowserWaitlistContentView { _ in }
            }

            if #available(iOS 15.0, *) {
                MacBrowserWaitlistContentView { _ in }
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

// MARK: - Extensions

private extension Color {
    
    static var macWaitlistText: Color {
        Color("MacWaitlistTextColor")
    }

    static var macWaitlistSubtitle: Color {
        Color("MacWaitlistSubtitleColor")
    }
    
    static var macWaitlistBlue: Color {
        Color("MacWaitlistBlue")
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
