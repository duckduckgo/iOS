//
//  TabViewControllerLongPressMenuExtension.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

import UIKit
import Core
import SafariServices
import WebKit

extension TabViewController {

    @available(iOS 13.0, *)
    func buildLinkPreviewMenu(for url: URL, withProvided providedElements: [UIMenuElement]) -> UIMenu {
        var items = [UIMenuElement]()

        items.append(UIAction(title: UserText.actionNewTabForUrl, image: UIImage(systemName: "plus.square.on.square")) { [weak self] _ in
            self?.onNewTabAction(url: url)
        })
        items.append(UIAction(title: UserText.actionNewBackgroundTabForUrl,
                              image: UIImage(systemName: "arrow.up.right.square")) { [weak self] _ in
            self?.onBackgroundTabAction(url: url)
        })
        return UIMenu(title: url.host?.dropPrefix(prefix: "www.") ?? "", children: items + providedElements)
    }
    
    func buildLongPressMenu(atPoint point: Point, forUrl url: URL) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: makeMessage(from: url), preferredStyle: .actionSheet)
        alert.overrideUserInterfaceStyle()
        alert.addAction(title: UserText.actionNewTabForUrl) { [weak self] in
            self?.onNewTabAction(url: url)
        }
        alert.addAction(title: UserText.actionNewBackgroundTabForUrl) { [weak self] in
            self?.onBackgroundTabAction(url: url)
        }
        alert.addAction(title: UserText.actionOpen) { [weak self] in
            self?.onOpenAction(forUrl: url)
        }
        alert.addAction(title: UserText.actionCopy) { [weak self] in
            self?.onCopyAction(forUrl: url)
        }
        alert.addAction(title: UserText.actionShare) { [weak self] in
            self?.onShareAction(forUrl: url, atPoint: point)
        }
        alert.addAction(title: UserText.actionCancel, style: .cancel)
        return alert
    }
    
    private func makeMessage(from url: URL) -> String {
        if var components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            components.query = nil
            if let newUrl = components.url {
                return newUrl.absoluteString
            }
        }
        
        return url.absoluteString
    }
    
    private func onNewTabAction(url: URL) {
        delegate?.tab(self, didRequestNewTabForUrl: url, openedByPage: false)
    }
    
    private func onBackgroundTabAction(url: URL) {
        delegate?.tab(self, didRequestNewBackgroundTabForUrl: url)
    }
    
    private func onOpenAction(forUrl url: URL) {
        if let webView = webView {
            webView.load(URLRequest(url: url))
        }
    }

    private func onCopyAction(forUrl url: URL) {
        let copyText = url.absoluteString
        UIPasteboard.general.string = copyText
    }
    
    private func onShareAction(forUrl url: URL, atPoint point: Point?) {
        guard let webView = webView else { return }
        presentShareSheet(withItems: [url], fromView: webView, atPoint: point)
    }
}

@available(iOS 13.0, *)
extension TabViewController {

    static let excludedLongPressItems = [
        UIImage(systemName: "safari"),
        UIImage(systemName: "eyeglasses"),
        UIImage(systemName: "eye.fill"), //  hide/show link previews on some versions of ios
        nil // hide/show link previews on some versions of ios
    ]

        func webView(_ webView: WKWebView, contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo,
                     completionHandler: @escaping (UIContextMenuConfiguration?) -> Void) {

        guard let url = elementInfo.linkURL else {
            completionHandler(nil)
            return
        }

        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: {
            return AppUserDefaults().longPressPreviews ? self.buildOpenLinkPreview(for: url) : nil
        }, actionProvider: { elements in

            let provided = elements.filter({
                !TabViewController.excludedLongPressItems.contains($0.image)
            })

            return self.buildLinkPreviewMenu(for: url, withProvided: provided)
        })

        completionHandler(config)
    }

    func webView(_ webView: WKWebView, contextMenuForElement elementInfo: WKContextMenuElementInfo,
                 willCommitWithAnimator animator: UIContextMenuInteractionCommitAnimating) {
        guard let url = elementInfo.linkURL else { return }
        load(url: url)
    }

    fileprivate func buildOpenLinkPreview(for url: URL) -> UIViewController? {
        let tab = Tab(link: Link(title: nil, url: url))
        let tabController = TabViewController.loadFromStoryboard(model: tab)
        tabController.isLinkPreview = true
        tabController.decorate(with: ThemeManager.shared.currentTheme)
        let configuration = WKWebViewConfiguration.nonPersistent()
        tabController.attachWebView(configuration: configuration, andLoadRequest: URLRequest(url: url), consumeCookies: false)
        tabController.loadViewIfNeeded()
        return tabController
    }

}
