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
    
    weak var tabDelegate: WebTabDelegate?
    
    var omniBarStyle: OmniBar.Style = .web
    var canShare = true
    var showsUrlInOmniBar = true
    
    private lazy var settings = TutorialSettings()

    static func loadFromStoryboard() -> WebTabViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebTabViewController") as! WebTabViewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displayFireTutorialIfNotSeen()
    }
    
    private func displayFireTutorialIfNotSeen() {
        if !settings.hasSeenFireTutorial {
            displayFireTutorial()
        }
    }
    
    private func displayFireTutorial() {
        guard let button = navigationController?.view.viewWithTag(OmniBar.actionButtonTag) else { return }
        let controller = FireTutorialViewController.loadFromStoryboard()
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.delegate = controller
        present(controller: controller, fromView: button)
        settings.hasSeenFireTutorial = true
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
            if let weakSelf = self {
                weakSelf.tabDelegate?.webTab(weakSelf, didRequestNewTabForUrl: url)
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
            try? SSReadingList.default()?.addItem(with: url, title: nil, previewText: nil)
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
    
    func dismiss() {
        removeFromParentViewController()
        view.removeFromSuperview()
    }
    
    func destroy() {
        dismiss()
        tearDown()
    }
    
    func omniBarWasDismissed() {}
}

extension WebTabViewController: WebEventsDelegate {
    
    func attached(webView: WKWebView) {
        webView.loadScripts()
    }
    
    func webpageDidStartLoading() {
        tabDelegate?.webTabLoadingStateDidChange(webTab: self)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webpageDidFinishLoading() {
        tabDelegate?.webTabLoadingStateDidChange(webTab: self)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: WKWebView, didRequestNewTabForRequest urlRequest: URLRequest) {
        tabDelegate?.webTab(self, didRequestNewTabForRequest: urlRequest)
    }
    
    func webView(_ webView: WKWebView, didReceiveLongPressForUrl url: URL) {
        launchActionSheet(forUrl: url)
    }
}
