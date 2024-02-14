//
//  DesktopDownloadView.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

import Foundation
import SwiftUI

struct DesktopDownloadView: View {

    @StateObject var viewModel: DesktopDownloadViewModel
    @State private var shareButtonFrame: CGRect = .zero
    @State private var isShareSheetVisible = false

    let padding = UIDevice.current.localizedModel == "iPad" ? 100.0 : 0.0

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .center, spacing: 8) {
                    headerView

                    Text(viewModel.browserDetails.summary)
                        .daxBodyRegular()
                        .foregroundColor(.waitlistTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, padding)

                    Text(viewModel.browserDetails.onYourString)
                        .daxBodyRegular()
                        .foregroundColor(.waitlistTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.top, 18)
                    
                    menuView
                        .daxHeadline()
                        .foregroundColor(.waitlistBlue)
                        .fixedSize()
                    
                    Button(
                        action: {
                            self.isShareSheetVisible = true
                        }, label: {
                            HStack {
                                Image("Share-16")
                                Text(viewModel.browserDetails.downloadURL)
                            }
                        }
                    )
                    // XAI: Move all strings to a Constants enum at the top
                    .buttonStyle(DesktopDownloadViewButtonStyle(enabled: true))
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
                    .sheet(isPresented: $isShareSheetVisible) {
                        DesktopDownloadShareSheet(items: [viewModel.downloadURL])
                    }

                    Spacer(minLength: 24)

                    Button(
                        action: {
                            withAnimation {
                                viewModel.switchPlatform()
                            }
                        }, label: {
                            Text(viewModel.browserDetails.otherPlatformText)
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
            .navigationTitle(viewModel.browserDetails.viewTitle)
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
            VStack(spacing: 18) {
                Image(viewModel.browserDetails.imageName)

                Text(viewModel.browserDetails.title)
                    .daxTitle2()
                    .foregroundColor(.waitlistTextPrimary)
                    .lineSpacing(6)
                    .multilineTextAlignment(.center)
                    .fixMultilineScrollableText()
            }
            .padding(.top, 24)
            .padding(.bottom, 12)
    }
    
    @ViewBuilder
    private var menuView: some View {
        
        // The .menuController modifier prevents the Text view from
        // updating when viewModel.browserDetails.downloadURL changes
        // so this is a hack to render another view
        if viewModel.browserDetails.platform == .mac {
            Text(viewModel.browserDetails.downloadURL)
                .menuController(UserText.macWaitlistCopy) {
                    viewModel.copyLink()
                }
        } else {
            Text(viewModel.browserDetails.downloadURL)
                .menuController(UserText.macWaitlistCopy) {
                    viewModel.copyLink()
                }
        }
    }
}

private struct ShareButtonFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}

struct DesktopDownloadShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
