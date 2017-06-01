//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Mia Alexiou on 01/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import WebKit
import Social
import Core

class ShareViewController: UIViewController {
    
    private let urlIdentifier = "public.url"
    private let textIdentifier = "public.plain-text"
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    private var webController: WebViewController?
    private lazy var bookmarkStore = BookmarkUserDefaults()
    fileprivate lazy var contentBlocker = ContentBlocker()

    override func viewDidLoad() {
        super.viewDidLoad()
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
            let filterStore = SearchFilterUserDefaults()
            guard let queryUrl = AppUrls.url(forQuery: text, filters: filterStore) else { return }
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
    
    @IBAction func onDeleteEverything(_ sender: UIButton) {
        webController?.reset()
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
    
    func webView(_ webView: WKWebView, shouldLoadUrl url: URL, forDocument documentUrl: URL) -> Bool {
        return !contentBlocker.block(url: url, forDocument: documentUrl)
    }
    
    func webView(_ webView: WKWebView, didReceiveLongPressForUrl url: URL, atPoint point: Point) {
        webView.load(URLRequest(url: url))
    }

    func webView(_ webView: WKWebView, didRequestNewTabForRequest urlRequest: URLRequest) {
        webView.load(urlRequest)
    }
    
    func webpageDidStartLoading() {
    }
    
    func webpageDidFinishLoading() {
        refreshNavigationButtons()
    }
}
