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
    weak var chromeDelegate: BrowserChromeDelegate!
    
    private lazy var appUrls: AppUrls = AppUrls()
    private(set) var contentBlocker: ContentBlockerConfigurationStore!
    private weak var privacyController: PrivacyProtectionController?
    private(set) var siteRating: SiteRating?
    private(set) var tabModel: Tab

    static func loadFromStoryboard(model: Tab, contentBlocker: ContentBlockerConfigurationStore) -> TabViewController {
        let controller = UIStoryboard(name: "Tab", bundle: nil).instantiateViewController(withIdentifier: "TabViewController") as! TabViewController
        controller.contentBlocker = contentBlocker
        controller.tabModel = model
        return controller
    }
    
    required init?(coder aDecoder: NSCoder) {
        tabModel = Tab(link: nil)
        super.init(coder: aDecoder)
        webEventsDelegate = self
    }
    
    public var link: Link? {
        guard let url = url else {
            return tabModel.link
        }
        
        let activeLink = Link(title: name, url: url, favicon: favicon)
        guard let storedLink = tabModel.link else {
            return activeLink
        }

        return activeLink.merge(with: storedLink)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addContentBlockerConfigurationObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetNavigationBar()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let controller = segue.destination as? PrivacyProtectionController {
            controller.delegate = self
            privacyController = controller
            controller.omniDelegate = chromeDelegate.omniBar.omniDelegate
            controller.siteRating = siteRating
        }

    }

    private func addContentBlockerConfigurationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(onContentBlockerConfigurationChanged), name: ContentBlockerConfigurationChangedNotification.name, object: nil)
    }
    
    @objc func onContentBlockerConfigurationChanged() {
        // defer it for 0.2s so that the privacy protection UI can update instantly, otherwise this causes a visible delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.reloadScripts()
            self.webView?.reload()
        }
    }
    
    private func resetNavigationBar() {
        chromeDelegate.setBarsHidden(false, animated: false)
    }
    
    @IBAction func onBottomOfScreenTapped(_ sender: UITapGestureRecognizer) {
        showBars(animated: false)
    }
    
    fileprivate func showBars(animated: Bool = true) {
        chromeDelegate.setBarsHidden(false, animated: animated)
    }
    
    func showPrivacyProtection() {
        performSegue(withIdentifier: "PrivacyProtection", sender: self)
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
        if let siteRating = siteRating {
            privacyController?.updateSiteRating(siteRating)
        }
    }
    
    func launchBrowsingMenu() {
        guard let button = chromeDelegate.omniBar.menuButton else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(refreshAction())
        alert.addAction(newTabAction())
        
        if let link = link {

            if let domain = siteRating?.domain {
                alert.addAction(whitelistAction(forDomain: domain))
            }

            alert.addAction(saveBookmarkAction(forLink: link))
            alert.addAction(shareAction(forLink: link))
        }
        
        alert.addAction(settingsAction())
        alert.addAction(UIAlertAction(title: UserText.actionCancel, style: .cancel))
        present(controller: alert, fromView: button)
    }

    func whitelistAction(forDomain domain: String) -> UIAlertAction {

        let whitelistManager = WhitelistManager()
        let whitelisted = whitelistManager.isWhitelisted(domain: domain)
        let title = whitelisted ? UserText.actionRemoveFromWhitelist : UserText.actionAddToWhitelist
        let operation = whitelisted ? whitelistManager.remove : whitelistManager.add

        return UIAlertAction(title: title, style: .default) { [weak self] (action) in
            operation(domain)
            self?.reload()
        }

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

        let bookmarksManager = BookmarksManager()
        if let index = bookmarksManager.indexOf(url: link.url) {
            return UIAlertAction(title: UserText.actionRemoveBookmark, style: .default) { action in
                bookmarksManager.delete(itemAtIndex: index)
            }
        } else {
            return UIAlertAction(title: UserText.actionSaveBookmark, style: .default) { [weak self] action in
                self?.launchSaveBookmarkAlert(bookmark: link)
            }
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
            guard let menu = self?.chromeDelegate.omniBar.menuButton else { return }
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
        chromeDelegate = nil
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

fileprivate struct MessageHandlerNames {
    static let trackerDetected = "trackerDetectedMessage"
    static let cache = "cacheMessage"
}

extension TabViewController: WKScriptMessageHandler {
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        switch(message.name) {
            
        case MessageHandlerNames.cache:
            handleCache(message: message)
            
        case MessageHandlerNames.trackerDetected:
            handleTrackerDetected(message: message)

        default:
            assertionFailure("Unhandled message: \(message.name)")

        }
        
    }
    
    private func handleCache(message: WKScriptMessage) {
        Logger.log(text: "\(MessageHandlerNames.cache)")
        guard let dict = message.body as? Dictionary<String, Any> else { return }
        guard let name = dict["name"] as? String else { return }
        guard let data = dict["data"] as? String else { return }
        ContentBlockerStringCache().put(name: name, value: data)
        reloadScripts()
    }
    
    struct TrackerDetectedKey {
        static let blocked = "blocked"
        static let parentDomain = "parentDomain"
        static let url = "url"
    }
    
    private func handleTrackerDetected(message: WKScriptMessage) {
        Logger.log(text: "\(MessageHandlerNames.trackerDetected) \(message.body)")
        guard let dict = message.body as? Dictionary<String, Any> else { return }
        guard let blocked = dict[TrackerDetectedKey.blocked] as? Bool else { return }
        guard let url = dict[TrackerDetectedKey.url] as? String else { return }
        let parent = dict[ TrackerDetectedKey.parentDomain] as? String
        siteRating?.trackerDetected(Tracker(url: url, parentDomain: parent), blocked: blocked)
        onSiteRatingChanged()
    }
}

extension TabViewController: WebEventsDelegate {
    
    func attached(webView: WKWebView) {
        webView.scrollView.delegate = self
        webView.configuration.userContentController.add(self, name: MessageHandlerNames.trackerDetected)
        webView.configuration.userContentController.add(self, name: MessageHandlerNames.cache)
    }
    
    func detached(webView: WKWebView) {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: MessageHandlerNames.trackerDetected)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: MessageHandlerNames.cache)
    }
    
    func contentProcessDidTerminate(webView: WKWebView) {
        delegate?.tabContentProcessDidTerminate(tab: self)
    }
    
    func webpageDidStartLoading() {
        Logger.log(items: "webpageLoading started:", Date().timeIntervalSince1970)
        resetSiteRating()
        tabModel.link = link
        delegate?.tabLoadingStateDidChange(tab: self)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webpageDidFinishLoading() {
        Logger.log(items: "webpageLoading finished:", Date().timeIntervalSince1970)
        siteRating?.finishedLoading = true
        updateSiteRating()
        tabModel.link = link
        delegate?.tabLoadingStateDidChange(tab: self)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webpageDidFailToLoad() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func faviconWasUpdated(_ favicon: URL, forUrl url: URL) {
        let bookmarks = BookmarkUserDefaults()
        bookmarks.updateFavicon(favicon, forBookmarksWithUrl: url)
        tabModel.link = link
        delegate?.tabLoadingStateDidChange(tab: self)
    }
    
    func webView(_ webView: WKWebView, shouldLoadUrl url: URL, forDocument documentUrl: URL) -> Bool {
        return shouldLoad(url: url, forDocument: documentUrl)
    }
    
    func webView(_ webView: WKWebView, didReceiveLongPressForUrl url: URL, atPoint point: Point) {
        launchLongPressMenu(atPoint: point, forUrl: url)
    }

    func webView(_ webView: WKWebView, didUpdateHasOnlySecureContent hasOnlySecureContent: Bool) {
        siteRating?.hasOnlySecureContent = hasOnlySecureContent
        updateSiteRating()
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
               chromeDelegate.isToolbarHidden == true &&
               isBottom(yPosition: y)
    }
    
    private func isBottom(yPosition y: CGFloat) -> Bool {
        return y > (view.frame.size.height - chromeDelegate.toolbarHeight)
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
        if chromeDelegate.isToolbarHidden == true {
            showBars()
            return false
        }
        return true
    }
}

extension TabViewController: ContentBlockerSettingsChangeDelegate {
    func contentBlockerSettingsDidChange() {
        onContentBlockerConfigurationChanged()
    }
}

extension TabViewController: PrivacyProtectionDelegate {

    func omniBarTextTapped() {
        chromeDelegate.omniBar.becomeFirstResponder()
    }

}
