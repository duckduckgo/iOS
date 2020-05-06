//
//  ActionViewController.swift
//  OpenAction
//
//  Created by Chris Brind on 06/05/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
        let path = "ddgQuickLink://\(url.absoluteString)"
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
