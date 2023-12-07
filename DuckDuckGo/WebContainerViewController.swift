//
//  WebContainerViewController.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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
import Core
import UIKit
import WebKit
import Networking

/// Use title property to set the displayed title
class WebContainerViewController: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    weak var webView: WKWebView?

    var url: URL? {
        didSet {
            if let url = url {
                load(url: url)
            }
        }
    }

    var progress: Float = 0.0 {
        didSet {
            progressView.progress = progress
            progressView.isHidden = progress >= 1.0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        applyTheme(ThemeManager.shared.currentTheme)

        let webView = WKWebView(frame: view.frame)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        view.addSubview(webView)
        self.webView = webView

        if let url = url {
            load(url: url)
        }

        view.bringSubviewToFront(progressView)
    }

    @IBAction func dismiss() {
        dismiss(animated: true)
    }

    private func load(url: URL) {
        var request = URLRequest.userInitiated(url)
        request.addValue(DefaultUserAgentManager.duckDuckGoUserAgent, forHTTPHeaderField: "User-Agent")
        webView?.load(request)
    }

    // swiftlint:disable block_based_kvo
    open override func observeValue(forKeyPath keyPath: String?,
                                    of object: Any?,
                                    change: [NSKeyValueChangeKey: Any]?,
                                    context: UnsafeMutableRawPointer?) {
        // swiftlint:enable block_based_kvo

        guard let keyPath = keyPath else { return }

        switch keyPath {

        case #keyPath(WKWebView.estimatedProgress):
            progress = Float(webView?.estimatedProgress ?? 0.0)

        default:
            os_log("Unhandled keyPath %s", log: .generalLog, type: .debug, keyPath)
        }
    }

    private func removeObservers() {
        webView?.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObservers()
    }

}

extension WebContainerViewController: Themable { }
