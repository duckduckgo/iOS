//
//  WaitlistViews.swift
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
import Waitlist

struct WaitlistDownloadBrowserContentView: View {

    let action: WaitlistViewActionHandler
    let constants: BrowserDownloadLinkConstants

    init(platform: BrowserDownloadLink, action: @escaping WaitlistViewActionHandler) {
        self.action = action
        self.constants = BrowserDownloadLinkConstants(platform: platform)
    }

    @State private var shareButtonFrame: CGRect = .zero

    let padding = UIDevice.current.localizedModel == "iPad" ? 100.0 : 0.0

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .center, spacing: 8) {
                    HeaderView(imageName: constants.imageName, title: constants.title)

                    Text(constants.summary)
                        .daxBodyRegular()
                        .foregroundColor(.waitlistTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, padding)

                    Text(constants.onYourString)
                        .daxBodyRegular()
                        .foregroundColor(.waitlistTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.top, 18)

                    Text(constants.downloadURL)
                        .daxHeadline()
                        .foregroundColor(.waitlistBlue)
                        .menuController(UserText.macWaitlistCopy) {
                            action(.copyDownloadURLToPasteboard)
                        }
                        .fixedSize()

                    Button(
                        action: {
                            action(.openShareSheet(shareButtonFrame))
                        }, label: {
                            HStack {
                                Image("Share-16")
                                Text(UserText.macWaitlistShareLink)
                            }
                        }
                    )
                    .buttonStyle(RoundedButtonStyle(enabled: true))
                    .padding(.horizontal, padding)
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
                            action(.custom(constants.customAction))
                        }, label: {
                            Text(constants.otherPlatformText)
                                .daxHeadline()
                                .foregroundColor(.waitlistBlue)
                                .multilineTextAlignment(.center)
                                .lineSpacing(5)
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
}

private struct ShareButtonFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}

enum BrowserDownloadLink {
    case windows
    case mac
}

struct BrowserDownloadLinkConstants {
    let platform: BrowserDownloadLink

    var imageName: String {
        switch platform {
        case .windows:
            return "WindowsWaitlistJoinWaitlist"
        case .mac:
            return "WaitlistMacComputer"
        }
    }
    var title: String {
        switch platform {
        case .windows:
            return UserText.windowsWaitlistTryDuckDuckGoForWindowsDownload
        case .mac:
            return UserText.macWaitlistTryDuckDuckGoForMac
        }
    }
    var summary: String {
        switch platform {
        case .windows:
            return UserText.windowsWaitlistSummary
        case .mac:
            return UserText.macWaitlistSummary
        }
    }
    var onYourString: String {
        switch platform {
        case .windows:
            return UserText.windowsWaitlistOnYourComputerGoTo
        case .mac:
            return UserText.macWaitlistOnYourMacGoTo
        }
    }
    var downloadURL: String {
        switch platform {
        case .windows:
            return "duckduckgo.com/windows"
        case .mac:
            return "duckduckgo.com/mac"
        }
    }
    var customAction: WaitlistViewModel.ViewCustomAction {
        switch platform {
        case .windows:
            return .openMacBrowserWaitlist
        case .mac:
            return .openWindowsBrowserWaitlist
        }
    }
    var otherPlatformText: String {
        switch platform {
        case .windows:
            return UserText.windowsWaitlistMac
        case .mac:
            return UserText.macWaitlistWindows
        }
    }
}
