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

extension TabViewController {
    
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
        alert.addAction(title: UserText.actionReadingList) { [weak self] in
            self?.onReadingAction(forUrl: url)
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
        Pixel.fire(pixel: .longPressMenuNewTabItem)
        delegate?.tab(self, didRequestNewTabForUrl: url)
    }
    
    private func onBackgroundTabAction(url: URL) {
        Pixel.fire(pixel: .longPressMenuNewBackgroundTabItem)
        delegate?.tab(self, didRequestNewBackgroundTabForUrl: url)
    }
    
    private func onOpenAction(forUrl url: URL) {
        if let webView = webView {
            Pixel.fire(pixel: .longPressMenuOpenItem)
            webView.load(URLRequest(url: url))
        }
    }
    
    private func onReadingAction(forUrl url: URL) {
        Pixel.fire(pixel: .longPressMenuReadingListItem)
        try? SSReadingList.default()?.addItem(with: url, title: nil, previewText: nil)
    }
    
    private func onCopyAction(forUrl url: URL) {
        let copyText = url.absoluteString
        Pixel.fire(pixel: .longPressMenuCopyItem)
        UIPasteboard.general.string = copyText
    }
    
    private func onShareAction(forUrl url: URL, atPoint point: Point) {
        Pixel.fire(pixel: .longPressMenuShareItem)
        guard let webView = webView else { return }
        presentShareSheet(withItems: [url], fromView: webView, atPoint: point)
    }
}
