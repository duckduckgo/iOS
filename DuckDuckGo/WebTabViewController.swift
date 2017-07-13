//
//  WebTabViewController.swift
//  DuckDuckGo
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
import SafariServices
import Core

class WebTabViewController: WebViewController, Tab {
    
    @IBOutlet var showBarsTapGestureRecogniser: UITapGestureRecognizer!
    
    weak var tabDelegate: WebTabDelegate?
    
    private var contentBlocker: ContentBlocker!
    private weak var contentBlockerPopover: ContentBlockerPopover?
    private(set) var contentBlockerMonitor = ContentBlockerMonitor()
    
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
        let controller = ContentBlockerPopover.loadFromStoryboard(withMonitor: contentBlockerMonitor)
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.delegate = self
        controller.popoverPresentationController?.backgroundColor = UIColor.white
        present(controller: controller, fromView: button)
        contentBlockerPopover = controller
    }
    
    fileprivate func resetContentBlockerMonitor() {
        contentBlockerMonitor = ContentBlockerMonitor()
    }
    
    fileprivate func notifyContentBlockerMonitorChanged() {
        contentBlockerPopover?.updateMonitor(monitor: contentBlockerMonitor)
        tabDelegate?.webTab(self, contentBlockerMonitorForCurrentPageDidChange: contentBlockerMonitor)
    }
    
    func launchBrowsingMenu() {
        guard let button = navigationController?.view.viewWithTag(OmniBar.menuButtonTag) else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(refreshAction())
        
        if let link = link {
            alert.addAction(copyAction(forUrl: link.url))
            alert.addAction(saveBookmarkAction(forLink: link))
            alert.addAction(shareAction(forLink: link))
        }
        
        alert.addAction(UIAlertAction(title: UserText.actionCancel, style: .cancel))
        present(controller: alert, fromView: button)
    }
    
    func launchLongPressMenu(atPoint point: Point, forUrl url: URL) {
        let alert = UIAlertController(title: nil, message: url.absoluteString, preferredStyle: .actionSheet)
        alert.addAction(newTabAction(forUrl: url))
        alert.addAction(openAction(forUrl: url))
        alert.addAction(readingAction(forUrl: url))
        alert.addAction(copyAction(forUrl: url))
        alert.addAction(shareAction(forUrl: url))
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
    
    private func copyAction(forUrl url: URL) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionCopy, style: .default) { (action) in
            UIPasteboard.general.string = AppUrls.searchQuery(fromUrl: url) ?? url.absoluteString
        }
    }
    
    private func shareAction(forLink link: Link) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionShare, style: .default) { [weak self] action in
            guard let webView = self?.webView else { return }
            var items = [link.title ?? "", link.url] as [Any]
            if let favicon = link.favicon {
                items.append(favicon)
            }
            self?.presentShareSheet(withItems: items, fromView: webView)
        }
    }
    
    private func shareAction(forUrl url: URL) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionShare, style: .default) { [weak self] action in
            guard let webView = self?.webView else { return }
            self?.presentShareSheet(withItems: [url], fromView: webView)
        }
    }
    
    fileprivate func shouldLoad(url: URL, forDocument documentUrl: URL) -> Bool {
        if let entry = contentBlocker.block(url: url, forDocument: documentUrl) {
            contentBlockerMonitor.blocked(entry: entry)
            notifyContentBlockerMonitorChanged()
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
    
    @IBAction func onBottomOfScreenTapped(_ sender: UITapGestureRecognizer) {
        showBars()
    }
    
    fileprivate func showBars() {
        navigationController?.isNavigationBarHidden = false
        navigationController?.isToolbarHidden = false
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
        webView.scrollView.delegate = self
    }
    
    func webpageDidStartLoading() {
        resetContentBlockerMonitor()
        notifyContentBlockerMonitorChanged()
        tabDelegate?.webTabLoadingStateDidChange(webTab: self)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webpageDidFinishLoading() {
        tabDelegate?.webTabLoadingStateDidChange(webTab: self)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func faviconWasUpdated(_ favicon: URL, forUrl url: URL) {
        let bookmarks = BookmarkUserDefaults()
        bookmarks.updateFavicon(favicon, forBookmarksWithUrl: url)
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

extension WebTabViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        notifyContentBlockerMonitorChanged()
    }
}

extension WebTabViewController {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if isShowBarsTap(gestureRecognizer) {
            return true
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    private func isShowBarsTap(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let y = gestureRecognizer.location(in: webView).y
        return gestureRecognizer == showBarsTapGestureRecogniser &&
               navigationController?.isToolbarHidden == true &&
               isBottom(yPosition: y)
    }
    
    private func isBottom(yPosition y: CGFloat) -> Bool {
        return y > (view.frame.size.height - InterfaceMeasurement.defaultToolbarHeight)
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == showBarsTapGestureRecogniser {
            return true
        }
        return super.gestureRecognizer(gestureRecognizer, shouldBeRequiredToFailBy: otherGestureRecognizer)
    }
}

extension WebTabViewController: UIScrollViewDelegate {
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if navigationController?.isToolbarHidden == true {
            showBars()
            return false
        }
        return true
    }
}


