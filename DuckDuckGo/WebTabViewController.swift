//
//  WebTabViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 01/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import WebKit
import SafariServices
import Core

class WebTabViewController: WebViewController, Tab {
    
    internal var omniBar: OmniBar
    
    weak var tabDelegate: WebTabDelegate?
    
    static func loadFromStoryboard() -> WebTabViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebTabViewController") as! WebTabViewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.omniBar = OmniBar.loadFromXib(withStyle: .web)
        super.init(coder: aDecoder)
        omniBar.omniDelegate = self
        webEventsDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetNavigationBar()
    }
    
    private func resetNavigationBar() {
        navigationController?.isNavigationBarHidden = false
        navigationController?.isToolbarHidden = false
        navigationController?.hidesBarsOnSwipe = true
    }
    
    func refreshOmniText() {
        omniBar.refreshText(forUrl: url)
    }
    
    func launchActionSheet(forUrl url: URL) {
        let alert = UIAlertController(title: nil, message: url.absoluteString, preferredStyle: .actionSheet)
        alert.addAction(newTabAction(forUrl: url))
        alert.addAction(openAction(forUrl: url))
        alert.addAction(readingAction(forUrl: url))
        alert.addAction(copyAction(forURL: url))
        alert.addAction(shareAction(forURL: url))
        alert.addAction(UIAlertAction(title: UserText.actionCancel, style: .cancel))
        present(controller: alert, fromView: webView)
    }
    
    func newTabAction(forUrl url: URL) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionNewTab, style: .default) { [weak self] action in
            if let webView = self?.webView {
                self?.tabDelegate?.openNewTab(fromWebView: webView, forUrl: url)
            }
        }
    }
    
    func openAction(forUrl url: URL) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionOpen, style: .default) { [weak self] action in
            if let webView = self?.webView {
                webView.load(URLRequest(url: url))
            }
        }
    }
    
    func readingAction(forUrl url: URL) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionReadingList, style: .default) { action in
            do {
                try SSReadingList.default()?.addItem(with: url, title: nil, previewText: nil)
            } catch {
                
            }
        }
    }
    
    func copyAction(forURL url: URL) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionCopy, style: .default) { (action) in
            UIPasteboard.general.string = url.absoluteString
        }
    }
    
    
    func shareAction(forURL url: URL) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionShare, style: .default) { [weak self] action in
            if let webView = self?.webView {
                self?.presentShareSheet(withItems: [url], fromView: webView)
            }
        }
    }
    
    func clear() {
        tearDown()
        removeFromParentViewController()
        view.removeFromSuperview()
    }
}

extension WebTabViewController: OmniBarDelegate {
    
    func onOmniQuerySubmitted(_ query: String) {
        if let url = AppUrls.url(forQuery: query) {
            load(url: url)
        }
    }
    
    func onLeftButtonPressed() {
        tabDelegate?.resetAll()
    }
    
    func onRightButtonPressed() {
        reload()
    }
}

extension WebTabViewController: WebEventsDelegate {
    
    func attached(webView: WKWebView) {
        webView.loadScripts()
    }
    
    func webpageDidStartLoading() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webpageDidFinishLoading() {
        tabDelegate?.refreshControls()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: WKWebView, didReceiveLongPressForUrl url: URL) {
        launchActionSheet(forUrl: url)
    }
}
