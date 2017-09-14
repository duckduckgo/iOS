//
//  TabViewController.swift
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

class TabViewController: WebViewController {
        
    @IBOutlet var showBarsTapGestureRecogniser: UITapGestureRecognizer!
    
    weak var delegate: TabDelegate?
    
    private lazy var appUrls: AppUrls = AppUrls()
    private(set) var contentBlocker: ContentBlockerConfigurationStore!
    private weak var contentBlockerPopover: ContentBlockerPopover?
    fileprivate var siteRating: SiteRating?
    
    static func loadFromStoryboard(contentBlocker: ContentBlockerConfigurationStore) -> TabViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabViewController") as! TabViewController
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
        navigationController?.hidesBarsOnSwipe = true
    }
        
    @IBAction func onBottomOfScreenTapped(_ sender: UITapGestureRecognizer) {
        showBars()
    }
    
    fileprivate func showBars() {
        navigationController?.isNavigationBarHidden = false
        navigationController?.isToolbarHidden = false
        let offset = webView.scrollView.contentOffset
        webView.scrollView.setContentOffset(CGPoint(x:0, y:offset.y + InterfaceMeasurement.defaultToolbarHeight + InterfaceMeasurement.defaultToolbarHeight), animated: true)
    }

    func launchContentBlockerPopover() {
        guard let siteRating = siteRating else { return }
        guard let button = navigationController?.view.viewWithTag(OmniBar.Tag.siteRating) else { return }
        let controller = ContentBlockerPopover.loadFromStoryboard(withDelegate: self, contentBlocker: contentBlocker, siteRating: siteRating)
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.delegate = self
        controller.popoverPresentationController?.backgroundColor = UIColor.white
        present(controller: controller, fromView: button)
        contentBlockerPopover = controller
    }
    
    fileprivate func resetSiteRating() {
        if let url = url {
            siteRating = SiteRating(url: url)
        } else {
            siteRating = nil
        }
        onSiteRatingChanged()
    }
    
    fileprivate func updateSiteRating() {
        if let url = url {
            siteRating?.url = url
        } else {
            siteRating = nil
        }
        onSiteRatingChanged()
    }
    
    fileprivate func onSiteRatingChanged() {
        delegate?.tab(self, didChangeSiteRating: siteRating)
        contentBlockerPopover?.updateSiteRating(siteRating: siteRating!)
    }

    func launchBrowsingMenu() {
        guard let button = navigationController?.view.viewWithTag(OmniBar.Tag.menuButton) else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(refreshAction())
        alert.addAction(newTabAction())
        
        if let link = link {
            alert.addAction(saveBookmarkAction(forLink: link))
            alert.addAction(shareAction(forLink: link))
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
        alert.addAction(copyAction(forUrl: url))
        alert.addAction(shareAction(forUrl: url, atPoint: point))
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
            saveCompletion: { [weak self] updatedBookmark in
                BookmarksManager().save(bookmark: updatedBookmark)
                self?.view.showBottomToast(UserText.webSaveLinkDone)
            },
            cancelCompletion: {})
        present(alert, animated: true, completion: nil)
    }
    
    private func newTabAction() -> UIAlertAction {
        return UIAlertAction(title: UserText.actionNewTab, style: .default) { [weak self] action in
            if let weakSelf = self {
                weakSelf.delegate?.tabDidRequestNewTab(weakSelf)
            }
        }
    }
    
    private func newTabAction(forUrl url: URL) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionNewTabForUrl, style: .default) { [weak self] action in
            if let weakSelf = self {
                weakSelf.delegate?.tab(weakSelf, didRequestNewTabForUrl: url)
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
        let copyText = url.absoluteString
        return UIAlertAction(title: UserText.actionCopy, style: .default) { (action) in
            UIPasteboard.general.string = copyText
        }
    }
    
    private func shareAction(forLink link: Link) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionShare, style: .default) { [weak self] action in
            guard let menu = self?.navigationController?.view.viewWithTag(OmniBar.Tag.menuButton) else { return }
            self?.presentShareSheet(withItems: [ link.title ?? "", link.url, link ], fromView: menu)
        }
    }
    
    private func shareAction(forUrl url: URL, atPoint point: Point) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionShare, style: .default) { [weak self] action in
            guard let webView = self?.webView else { return }
            self?.presentShareSheet(withItems: [url], fromView: webView, atPoint: point)
        }
    }
    
    private func settingsAction() -> UIAlertAction {
        return UIAlertAction(title: UserText.actionSettings, style: .default) { [weak self] action in
            if let weakSelf = self {
                weakSelf.delegate?.tabDidRequestSettings(tab: weakSelf)
            }
        }
    }
    
    fileprivate func shouldLoad(url: URL, forDocument documentUrl: URL) -> Bool {
        if shouldOpenExternally(url: url) {
            UIApplication.shared.openURL(url)
            return false
        }
        return true
    }
    
    private func shouldOpenExternally(url: URL) -> Bool {
        return SupportedExternalURLScheme.isSupported(url: url)
    }
    
    func dismiss() {
        webView.scrollView.delegate = nil
        willMove(toParentViewController: nil)
        removeFromParentViewController()
        view.removeFromSuperview()
    }

    func destroy() {
        dismiss()
        tearDown()
    }
}

extension TabViewController: WKScriptMessageHandler {

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "trackerDetectedMessage" {
            print("trackerDetectedMessage:", message.body)
        }
    }

}

extension TabViewController: WebEventsDelegate {
    
    func attached(webView: WKWebView) {
        webView.loadScripts()
        webView.scrollView.delegate = self
        webView.configuration.userContentController.add(self, name: "trackerDetectedMessage")
    }

    func webpageDidStartLoading() {
        resetSiteRating()
        delegate?.tabLoadingStateDidChange(tab: self)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webpageDidFinishLoading() {
        updateSiteRating()
        delegate?.tabLoadingStateDidChange(tab: self)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webpageDidFailToLoad() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func faviconWasUpdated(_ favicon: URL, forUrl url: URL) {
        let bookmarks = BookmarkUserDefaults()
        bookmarks.updateFavicon(favicon, forBookmarksWithUrl: url)
        delegate?.tabLoadingStateDidChange(tab: self)
    }
    
    func webView(_ webView: WKWebView, shouldLoadUrl url: URL, forDocument documentUrl: URL) -> Bool {
        return shouldLoad(url: url, forDocument: documentUrl)
    }
    
    func webView(_ webView: WKWebView, didReceiveLongPressForUrl url: URL, atPoint point: Point) {
        launchLongPressMenu(atPoint: point, forUrl: url)
    }
}

extension TabViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension TabViewController {
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

extension TabViewController: UIScrollViewDelegate {
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if navigationController?.isToolbarHidden == true {
            showBars()
            return false
        }
        return true
    }
}

extension TabViewController: ContentBlockerSettingsChangeDelegate {
    func contentBlockerSettingsDidChange() {
        webView.reload()
    }
}
