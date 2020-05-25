//
//  ActionViewController.swift
//  OpenAction
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
import MobileCoreServices

class ActionViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for item in extensionContext?.inputItems as? [NSExtensionItem] ?? [] {
            for provider in item.attachments ?? [] {
                if provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                    provider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil, completionHandler: { url, _ in
                        guard let url = url as? URL else { return }
                        DispatchQueue.main.async {
                            self.launchBrowser(withUrl: url)
                            self.done()
                        }
                    })
                    break
                }
            }
        }
    }

    func launchBrowser(withUrl url: URL) {

        let path = "\(AppDeepLinks.quickLink)\(url.absoluteString)"
        guard let url = URL(string: path) else { return }
        var responder = self as UIResponder?
        let selectorOpenURL = sel_registerName("openURL:")
        while let current = responder {
            if current.responds(to: selectorOpenURL) {
                current.perform(selectorOpenURL, with: url, afterDelay: 0)
                break
            }
            responder = current.next
        }
    }

    func done() {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
}
