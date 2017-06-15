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
        
    private var contentBlocker: ContentBlocker!
    private weak var contentBlockerPopover: ContentBlockerPopover?
    private(set) var contentBlockerCount = 0
    
    static func loadFromStoryboard(contentBlocker: ContentBlocker) -> WebTabViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebTabViewController") as! WebTabViewController
        controller.contentBlocker = contentBlocker
        return controller
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
    
    func launchContentBlockerPopover() {
        guard let button = navigationController?.view.viewWithTag(OmniBar.contentBlockerTag) else { return }
        let controller = ContentBlockerPopover.loadFromStoryboard()
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.delegate = controller
        present(controller: controller, fromView: button)
        controller.trackerCountLabel.text = trackerCoundLabel()
        contentBlockerPopover = controller
    }
    
    func resetContentBlockerCount() {
        contentBlockerCount = 0
        contentBlockerPopover?.trackerCountLabel.text = trackerCoundLabel()
        tabDelegate?.webTab(self, hasBlocked: contentBlockerCount)
    }
    
    func incrementContentBlockerCount() {
        contentBlockerCount += 1
        contentBlockerPopover?.trackerCountLabel.text = trackerCoundLabel()
        tabDelegate?.webTab(self, hasBlocked: contentBlockerCount)
    }
    
    private func trackerCoundLabel() -> String {
        if contentBlockerCount == 0 {
            return UserText.contentBlockerNoTrackers
        }
        if contentBlockerCount == 1 {
            return UserText.contentBlockerATracker
        }
        return String(format: UserText.contentBlockerTrackers, contentBlockerCount)
    }
    
    func launchBrowsingMenu() {
        guard let button = navigationController?.view.viewWithTag(OmniBar.menuButtonTag) else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(refreshAction())
        
        if let url = url {
            alert.addAction(copyAction(forURL: url))
        }
        
        if let link = link {
            alert.addAction(saveBookmarkAction(forLink: link))
        }
        
        alert.addAction(settingsAction())
        alert.addAction(UIAlertAction(title: UserText.actionCancel, style: .cancel))

        present(controller: alert, fromView: button)
    }
    
    func launchLongPressMenu(atPoint point: Point, forUrl url: URL) {
        let alert = UIAlertController(title: nil, message: url.absoluteString, preferredStyle: .actionSheet)
        alert.addAction(newTabAction(forUrl: url))
        alert.addAction(openAction(forUrl: url))
        alert.addAction(readingAction(forUrl: url))
        alert.addAction(copyAction(forURL: url))
        alert.addAction(shareAction(forURL: url))
        alert.addAction(UIAlertAction(title: UserText.actionCancel, style: .cancel))
        present(controller: alert, fromView: webView, atPoint: point)
    }

    private func refreshAction() -> UIAlertAction {
        return UIAlertAction(title: UserText.actionRefresh, style: .default) { [weak self] action in
            self?.reload()
        }
    }

    private func saveBookmarkAction(forLink link: Link) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionSaveBookmark, style: .default) { [weak self] action in
            self?.launchSaveBookmarkAlert(bookmark: link)
        }
    }

    private func launchSaveBookmarkAlert(bookmark: Link) {
        let alert = EditBookmarkAlert.buildAlert (
            title: UserText.alertSaveBookmark,
            bookmark: bookmark,
            saveCompletion: { updatedBookmark in BookmarksManager().save(bookmark: updatedBookmark) },
            cancelCompletion: {})
        present(alert, animated: true, completion: nil)
    }
    
    private func settingsAction() -> UIAlertAction {
        return UIAlertAction(title: UserText.actionSettings, style: .default) { [weak self] action in
            self?.launchSettings()
        }
    }
    
    private func newTabAction(forUrl url: URL) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionNewTab, style: .default) { [weak self] action in
            if let weakSelf = self {
                weakSelf.tabDelegate?.webTab(weakSelf, didRequestNewTabForUrl: url)
            }
        }
    }
    
    private func openAction(forUrl url: URL) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionOpen, style: .default) { [weak self] action in
            if let webView = self?.webView {
                webView.load(URLRequest(url: url))
            }
        }
    }
    
    private func readingAction(forUrl url: URL) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionReadingList, style: .default) { action in
            try? SSReadingList.default()?.addItem(with: url, title: nil, previewText: nil)
        }
    }
    
    private func copyAction(forURL url: URL) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionCopy, style: .default) { (action) in
            UIPasteboard.general.string = AppUrls.searchQuery(fromUrl: url) ?? url.absoluteString
        }
    }
    
    private func shareAction(forURL url: URL) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionShare, style: .default) { [weak self] action in
            if let webView = self?.webView {
                self?.presentShareSheet(withItems: [url], fromView: webView)
            }
        }
    }
    
    fileprivate func shouldLoad(url: URL, forDocument documentUrl: URL) -> Bool {
        if contentBlocker.block(url: url, forDocument: documentUrl) {
            incrementContentBlockerCount()
            return false
        }
        if shouldOpenExternally(url: url) {
            UIApplication.shared.openURL(url)
            return false
        }
        return true
    }
    
    private func shouldOpenExternally(url: URL) -> Bool {
        return SupportedExternalURLScheme.isSupported(url: url)
    }

    private func launchSettings() {
        let controller = SettingsViewController.loadFromStoryboard()
        present(controller, animated: true, completion: nil)
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
        resetContentBlockerCount()
        tabDelegate?.webTabLoadingStateDidChange(webTab: self)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webpageDidFinishLoading() {
        tabDelegate?.webTabLoadingStateDidChange(webTab: self)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: WKWebView, shouldLoadUrl url: URL, forDocument documentUrl: URL) -> Bool {
        return shouldLoad(url: url, forDocument: documentUrl)
    }
    
    func webView(_ webView: WKWebView, didRequestNewTabForRequest urlRequest: URLRequest) {
        tabDelegate?.webTab(self, didRequestNewTabForRequest: urlRequest)
    }
    
    func webView(_ webView: WKWebView, didReceiveLongPressForUrl url: URL, atPoint point: Point) {
        launchLongPressMenu(atPoint: point, forUrl: url)
    }
}
