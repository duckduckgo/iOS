//
//  ShareViewController.swift
//  ShareExtension
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

import Common
import UIKit
import Social
import Core

class ShareViewController: SLComposeServiceViewController {

    struct Identifier {
        static let url = "public.url"
        static let text = "public.plain-text"
    }

    struct Constants {
        static let openURLSelector = "openURL:"
    }

    override func configurationItems() -> [Any]! {
        if let urlProvider = getItemProvider(identifier: Identifier.url) {
            loadUrl(fromUrlProvider: urlProvider)
        } else if let textProvider = getItemProvider(identifier: Identifier.text) {
            loadText(fromTextProvider: textProvider)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.cancel()
        }
        return []
    }

    private func getItemProvider(identifier: String) -> NSItemProvider? {

        guard let item = extensionContext?.inputItems.first as? NSExtensionItem else {
            return nil
        }

        guard let attachments = item.attachments else { return nil }

        for attachment in attachments where attachment.hasItemConformingToTypeIdentifier(identifier) {
            return attachment
        }
        return nil
    }

    private func loadUrl(fromUrlProvider urlProvider: NSItemProvider) {
        urlProvider.loadItem(forTypeIdentifier: Identifier.url, options: nil) { [weak self] (item, _) in
            if let url = item as? URL {
                self?.open(url: url)
            }
        }
    }

    private func loadText(fromTextProvider textProvider: NSItemProvider) {
        textProvider.loadItem(forTypeIdentifier: Identifier.text, options: nil) { [weak self] (item, _) in
            guard let query = item as? String else { return }
            guard let url = URL.makeSearchURL(query: query) else {
                os_log("Couldn‘t form URL for query “%s”", log: .lifecycleLog, type: .error, query)
                return
            }
            self?.open(url: url)
        }
    }

    private func open(url: URL) {
        let selector = sel_registerName(Constants.openURLSelector)
        let deepLink = URL(string: AppDeepLinkSchemes.quickLink.appending(url.absoluteString))!
        var responder = self as UIResponder?
        while responder != nil {
            if responder!.responds(to: selector) {
                _ = responder?.perform(selector, with: deepLink, with: {})
                break
            }
            responder = responder!.next
        }
    }
}
