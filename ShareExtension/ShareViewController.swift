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


import WebKit
import Social
import ToastSwiftFramework
import Core

class ShareViewController: UIViewController {
    
    private let urlIdentifier = "public.url"
    private let textIdentifier = "public.plain-text"
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!

    private var webController: WebViewController?
    private lazy var bookmarkStore: BookmarkUserDefaults = BookmarkUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        webController?.attachWebView(persistsData: false)
        refreshNavigationButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let urlProvider = getItemProvider(identifier: urlIdentifier) {
            loadUrl(urlProvider: urlProvider)
            return
        }
        if let textProvider = getItemProvider(identifier: textIdentifier) {
            loadText(textProvider: textProvider)
            return
        }
    }
    
    private func getItemProvider(identifier: String) -> NSItemProvider? {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem else {
            return nil
        }
        guard let itemProvider = item.attachments?.first as? NSItemProvider else {
            return nil
        }
        if itemProvider.hasItemConformingToTypeIdentifier(identifier) {
            return itemProvider
        }
        return nil
    }
    
    private func loadUrl(urlProvider: NSItemProvider) {
        urlProvider.loadItem(forTypeIdentifier: urlIdentifier, options: nil, completionHandler: { [weak self] (item, error) in
            if let url = item as? URL {
                self?.webController?.load(url: url)
            }
        })
    }
    
    private func loadText(textProvider: NSItemProvider) {
        textProvider.loadItem(forTypeIdentifier: textIdentifier, options: nil, completionHandler: { [weak self] (item, error) in
            guard let text = item as? String else { return }
            let queryUrl = AppUrls().url(forQuery: text)
            self?.webController?.load(url: queryUrl)
        })
    }
    
    fileprivate func refreshNavigationButtons() {
        backButton.isEnabled = webController?.canGoBack ?? false
        forwardButton.isEnabled = webController?.canGoForward ?? false
    }
    
    @IBAction func onRefreshPressed(_ sender: UIButton) {
        webController?.reload()
    }
    
    @IBAction func onBackPressed(_ sender: UIButton) {
        webController?.goBack()
    }
    
    @IBAction func onForwardPressed(_ sender: UIButton) {
        webController?.goForward()
    }
    
    @IBAction func onSaveBookmark(_ sender: UIButton) {
        if let link = webController?.link {
            bookmarkStore.addBookmark(link)
            webController?.view.makeToast(UserText.webSaveLinkDone)
        }
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        webController?.tearDown()
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? WebViewController {
            controller.webEventsDelegate = self
            webController = controller
        }
    }
}

extension ShareViewController: WebEventsDelegate {
    
    func attached(webView: WKWebView) {
        webView.loadScripts()
    }
    
    func detached(webView: WKWebView) {
    }
    
    func webView(_ webView: WKWebView, shouldLoadUrl url: URL, forDocument documentUrl: URL) -> Bool {
        return true
    }
    
    func webView(_ webView: WKWebView, didReceiveLongPressForUrl url: URL, atPoint point: Point) {
        webView.load(URLRequest(url: url))
    }
    
    func webpageDidStartLoading() {
    }
    
    func webpageDidFinishLoading() {
        refreshNavigationButtons()
    }
    
    func webpageDidFailToLoad() {
    }
    
    func faviconWasUpdated(_ favicon: URL, forUrl: URL) {
    }
}
