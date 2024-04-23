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
import LinkPresentation
import DuckUI
import Core

struct DesktopDownloadView: View {

    @StateObject var viewModel: DesktopDownloadViewModel
    @State private var shareButtonFrame: CGRect = .zero
    @State private var isShareSheetVisible = false

    private struct ShareItem: Identifiable {
        var id: String {
            value
        }

        var item: Any {
            if let url = URL(string: value), let title = title, let message {
                return DesktopDownloadShareItemSource(url: url, title: title, message: message)
            } else {
                return value
            }
        }

        let value: String
        let title: String?
        let message: String?
    }

    let padding = UIDevice.current.localizedModel == "iPad" ? 100.0 : 0.0

    @State private var activityItem: ShareItem?
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .center, spacing: 6) {
                    headerView

                    if !viewModel.browserDetails.summary.isEmpty {
                        Text(viewModel.browserDetails.summary)
                            .daxBodyRegular()
                            .foregroundColor(.waitlistTextSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .padding(.horizontal, padding)
                            .padding(.bottom, 6)
                    }

                    Text(viewModel.browserDetails.onYourString)
                        .daxBodyRegular()
                        .foregroundColor(.waitlistTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)

                    menuView
                        .daxHeadline()
                        .foregroundColor(.waitlistBlue)
                        .fixedSize()
                    
                    Button(
                        action: {
                            if viewModel.browserDetails.platform == .desktop {
                                activityItem = ShareItem(value: viewModel.downloadURL.absoluteString,
                                                         title: viewModel.browserDetails.shareTitle,
                                                         message: viewModel.browserDetails.shareMessage)
                                Pixel.fire(pixel: .getDesktopShare)
                            } else {
                                activityItem = ShareItem(value: viewModel.downloadURL.absoluteString, title: nil, message: nil)
                            }
                        }, label: {
                            HStack {
                                Image(.share24)
                                Text(viewModel.browserDetails.button)
                            }
                        }
                    )
                    .buttonStyle(PrimaryButtonStyle(fullWidth: false))
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
                    .sheet(item: $activityItem) { activityItem in
                        ActivityViewController(activityItems: [activityItem.item])
                            .modifier(ActivityViewPresentationModifier())
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
                .padding([.horizontal], 24)
                .frame(maxWidth: .infinity, minHeight: proxy.size.height)
            }
            .navigationTitle(viewModel.browserDetails.viewTitle)
            .background(Rectangle()
                .foregroundColor(Color(designSystemColor: .background))
                .ignoresSafeArea())

        }
    }
    
    @ViewBuilder
    private var headerView: some View {
            VStack(spacing: 18) {
                Image(viewModel.browserDetails.imageName)

                Text(viewModel.browserDetails.title)
                    .daxTitle3()
                    .foregroundColor(.waitlistTextPrimary)
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
            Text(viewModel.browserDetails.goToUrl)
                .menuController(UserText.macWaitlistCopy) {
                    viewModel.copyLink()
                }
        } else {
            Text(viewModel.browserDetails.goToUrl)
                .menuController(UserText.macWaitlistCopy) {
                    viewModel.copyLink()
                    if viewModel.browserDetails.platform == .desktop {
                        Pixel.fire(pixel: .getDesktopCopy)
                    }
                }
        }
    }
}

private struct ShareButtonFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}

private class DesktopDownloadShareItemSource: NSObject, UIActivityItemSource {
    var url: URL
    var title: String
    var message: String

    init(url: URL, title: String, message: String) {
        self.url = url
        self.title = title
        self.message = message
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return url
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        if activityType == .mail {
            return "\(message)\n\n\(url.absoluteString)"
        }
        return url
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return title
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        metadata.url = url
        return metadata
    }

}
