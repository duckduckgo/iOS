//
//  PlatformLinksView.swift
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

import SwiftUI
import DesignResourcesKit
import DuckUI

public struct PlatformLinksView: View {

    private struct Constants {
        static let goToUrl: String = "duckduckgo.com/app"
        static let downloadUrl: String = "https://duckduckgo.com/app?origin=funnel_browser_ios_sync"
    }

    private var model: SyncSettingsViewModel
    private var source: SyncSettingsViewModel.PlatformLinksPixelSource

    @State private var shareButtonFrame: CGRect = .zero

    public init(model: SyncSettingsViewModel, source: SyncSettingsViewModel.PlatformLinksPixelSource) {
        self.model = model
        self.source = source
    }

    public var body: some View {
            ScrollView {
                VStack {
                    content
                    Spacer()
                }
                .padding(16)
                .frame(maxWidth: .infinity)
            }
        .background(Rectangle()
            .foregroundColor(Color(designSystemColor: .background))
            .ignoresSafeArea())

        .navigationTitle(UserText.syncGetOtherDevicesScreenTitle)
    }

    private var content: some View {
        VStack(alignment: .center, spacing: 0) {

            Image("Sync-App-Download-128")
                .resizable()
                .frame(width: 96, height: 72)


            Text(UserText.syncGetOtherDevicesTitle)
                .daxTitle3()
                .foregroundColor(Color(designSystemColor: .textPrimary))
                .padding([.top, .horizontal], 16)
                .multilineTextAlignment(.center)

            Group {
                Text(UserText.syncGetOtherDevicesMessage)
                    .daxBodyRegular()
                    .foregroundColor(Color(designSystemColor: .textPrimary))
                    .padding(.top, 8)
                    .multilineTextAlignment(.center)

                Text(Constants.goToUrl)
                    .daxBodyBold()
                    .foregroundColor(Color(designSystemColor: .accent))
                    .overlay(
                        CopyActionOverlay(copyText: Constants.downloadUrl, onCopy: {
                            model.fireOtherPlatformLinksPixel(for: .copy, source: source)
                        })
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    )
                    .padding(.top, 2)

                Button {
                    if let url = URL(string: Constants.downloadUrl) {
                        model.shareLinkPressed(for: url, with: UserText.syncGetOtherDeviceShareLinkMessage, from: shareButtonFrame)
                        model.fireOtherPlatformLinksPixel(for: .share, source: source)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image("Share-Apple-24")
                        Text(UserText.syncGetOtherDevicesButtonTitle)
                            .daxBodyBold()
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 24)
                .background(
                    GeometryReader { geometryProxy in
                        Color.clear
                            .preference(key: ShareButtonFramePreferenceKey.self, value: geometryProxy.frame(in: .global))
                    }
                )
                .onPreferenceChange(ShareButtonFramePreferenceKey.self) { newFrameRect in
                    shareButtonFrame = newFrameRect
                }
            }
            .padding(.horizontal, 24)

        }
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(designSystemColor: .surface))
        )
        .onAppear {
            model.fireOtherPlatformLinksPixel(for: .appear, source: source)
        }
    }
}

private struct ShareButtonFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

private struct CopyActionOverlay: UIViewRepresentable {
    let copyText: String
    let onCopy: () -> Void

    class Coordinator: NSObject {
        var copyText: String
        var onCopy: () -> Void

        init(copyText: String, onCopy: @escaping () -> Void) {
            self.copyText = copyText
            self.onCopy = onCopy
        }

        @objc func showMenu(_ sender: UITapGestureRecognizer) {
            guard let view = sender.view else { return }
            view.becomeFirstResponder()

            let menuController = UIMenuController.shared
            menuController.menuItems = [
                UIMenuItem(title: UserText.copyButton, action: #selector(copyTextAction))
            ]
            menuController.showMenu(from: view, rect: view.bounds)
        }

        @objc func copyTextAction() {
            UIPasteboard.general.string = copyText

            onCopy()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(copyText: copyText, onCopy: onCopy)
    }

    func makeUIView(context: Context) -> UIView {
        let view = CopyableUIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.showMenu(_:)))
        view.addGestureRecognizer(tapGesture)

        view.copyAction = context.coordinator.copyTextAction
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

private class CopyableUIView: UIView {
    var copyAction: (() -> Void)?

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func copy(_ sender: Any?) {
        copyAction?()
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

#Preview {
    PlatformLinksView(model: SyncSettingsViewModel(isOnDevEnvironment: { true }, switchToProdEnvironment: {}), source: .activated)
}
