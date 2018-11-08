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

// swiftlint:disable file_length
// swiftlint:disable type_body_length

import WebKit
import SafariServices
import Core
import Device
import StoreKit

class TabViewController: UIViewController {
    
    private struct Constants {
        static let unsupportedUrlErrorCode = -1002
        static let urlCouldNotBeLoaded = 101
        static let frameLoadInterruptedErrorCode = 102
        static let minimumProgress: Float = 0.1

        // swiftlint:disable line_length
        static let desktopUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Safari/605.1.15"
        // swiftlint:enable line_length
    }
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var error: UIView!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet var showBarsTapGestureRecogniser: UITapGestureRecognizer!
    var longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(sender:)))

    weak var delegate: TabDelegate?
    weak var chromeDelegate: BrowserChromeDelegate?

    private(set) var webView: WKWebView!
    private lazy var appRatingPrompt: AppRatingPrompt = AppRatingPrompt()
    private weak var privacyController: PrivacyProtectionController?
    
    private lazy var appUrls: AppUrls = AppUrls()
    private lazy var tld = TLD()
    private lazy var statisticsStore: StatisticsStore = StatisticsUserDefaults()
    private lazy var disconnectMeStore = DisconnectMeStore()
    private var contentBlocker: ContentBlockerConfigurationStore!
    private var httpsUpgrade = HTTPSUpgrade.shared

    private(set) var siteRating: SiteRating?
    private(set) var tabModel: Tab
    private var httpsForced: Bool = false
    private var lastUpgradedDomain: String?
    private var lastError: Error?
    private var shouldReloadOnError = false
    private var failingUrls = Set<String>()
    private var tearDownCount = 0
    
    public var url: URL? {
        didSet {
            delegate?.tabLoadingStateDidChange(tab: self)
        }
    }
    
    public var name: String? {
        return webView.title
    }
    
    public var canGoBack: Bool {
        let webViewCanGoBack = webView.canGoBack
        let navigatedToError = webView.url != nil && isError
        return webViewCanGoBack || navigatedToError
    }
    
    public var canGoForward: Bool {
        let webViewCanGoForward = webView.canGoForward
        return webViewCanGoForward && !isError
    }
    
    public var isError: Bool {
        return !error.isHidden
    }
    
    public var errorText: String? {
        return errorMessage.text
    }
    
    public var link: Link? {
        if isError {
            if let url = url ?? webView.url ?? URL(string: "") {
                return Link(title: errorText, url: url)
            }
        }
        
        guard let url = url else {
            return tabModel.link
        }
        
        let activeLink = Link(title: name, url: url)
        guard let storedLink = tabModel.link else {
            return activeLink
        }
        
        return activeLink.merge(with: storedLink)
    }

    static func loadFromStoryboard(model: Tab, contentBlocker: ContentBlockerConfigurationStore) -> TabViewController {
        let storyboard = UIStoryboard(name: "Tab", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "TabViewController") as? TabViewController else {
            fatalError("Failed to instantiate controller as TabViewController")
        }
        controller.contentBlocker = contentBlocker
        controller.tabModel = model
        return controller
    }

    required init?(coder aDecoder: NSCoder) {
        tabModel = Tab(link: nil)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addContentBlockerConfigurationObserver()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetNavigationBar()
    }
    
    @objc func onApplicationWillResignActive() {
        shouldReloadOnError = true
    }
    
    func attachWebView(configuration: WKWebViewConfiguration, andLoadUrl url: URL?, consumeCookies: Bool) {
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        attachLongPressHandler(webView: webView)
        webView.allowsBackForwardNavigationGestures = true
        
        addObservers()
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webViewContainer.addSubview(webView)
        webView.configuration.userContentController.add(self, name: MessageHandlerNames.trackerDetected)
        webView.configuration.userContentController.add(self, name: MessageHandlerNames.cache)
        webView.configuration.userContentController.add(self, name: MessageHandlerNames.log)
        reloadScripts()
        updateUserAgent()

        if consumeCookies {
            consumeCookiesThenLoadUrl(url)
        } else if let url = url {
            load(url: url)
        }
    }
    
    private func addObservers() {
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.hasOnlySecureContent), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
    }
    
    private func attachLongPressHandler(webView: WKWebView) {
        longPressGestureRecognizer.delegate = self
        webView.scrollView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    private func consumeCookiesThenLoadUrl(_ url: URL?) {
        webView.configuration.websiteDataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { _ in
            WebCacheManager.consumeCookies()
            if let url = url {
                self.load(url: url)
            }
        }
        
        if url != nil {
            progressBar.progress = Constants.minimumProgress
            delegate?.tabLoadingStateDidChange(tab: self)
            onWebpageDidStartLoading(httpsForced: false)
        }
    }
    
    public func load(url: URL) {
        self.url = url
        lastError = nil
        updateUserAgent()
        load(urlRequest: URLRequest(url: url))
    }
    
    private func load(urlRequest: URLRequest) {
        loadViewIfNeeded()
        webView.stopLoading()
        webView.load(urlRequest)
    }
    
    open override func observeValue(forKeyPath keyPath: String?,
                                    of object: Any?,
                                    change: [NSKeyValueChangeKey: Any]?,
                                    context: UnsafeMutableRawPointer?) {
        
        guard let keyPath = keyPath else { return }
        
        switch keyPath {
            
        case WebViewKeyPaths.estimatedProgress:
            progressBar.progress = max(Constants.minimumProgress, Float(webView.estimatedProgress))
            
        case WebViewKeyPaths.hasOnlySecureContent:
            hasOnlySecureContentChanged(hasOnlySecureContent: webView.hasOnlySecureContent)
            
        case WebViewKeyPaths.url:
            urlDidChange()
            
        case WebViewKeyPaths.canGoBack:
            delegate?.tabLoadingStateDidChange(tab: self)
            
        case WebViewKeyPaths.canGoForward:
            delegate?.tabLoadingStateDidChange(tab: self)
            
        default:
            Logger.log(text: "Unhandled keyPath \(keyPath)")
        }
    }
    
    func hasOnlySecureContentChanged(hasOnlySecureContent: Bool) {
        guard webView.url?.host == siteRating?.url.host else { return }
        siteRating?.hasOnlySecureContent = hasOnlySecureContent
        updateSiteRating()
    }
    
    private func urlDidChange() {
        if self.url?.host == self.webView.url?.host {
            self.url = self.webView.url
        }
    }
    
    private func checkForReloadOnError() {
        guard shouldReloadOnError else { return }
        shouldReloadOnError = false
        reload()
    }
    
    private func shouldReissueSearch(for url: URL) -> Bool {
        return appUrls.isDuckDuckGoSearch(url: url) && !appUrls.hasCorrectMobileStatsParams(url: url)
    }
    
    private func reissueSearchWithStatsParams(for url: URL) {
        let mobileSearch = appUrls.applyStatsParams(for: url)
        load(url: mobileSearch)
    }
    
    private func showProgressIndicator() {
        progressBar.alpha = 1
        progressBar.progress = Constants.minimumProgress
    }
    
    private func hideProgressIndicator() {
        UIView.animate(withDuration: 1) {
            self.progressBar.alpha = 0
        }
    }
    
    public func reload() {
        updateUserAgent()
        webView.reload()
    }
    
    private func updateUserAgent() {
        let userAgent = tabModel.isDesktop ? Constants.desktopUserAgent : nil
        webView.customUserAgent = userAgent
    }
    
    func goBack() {
        if isError {
            hideErrorMessage()
            url = webView.url
            onWebpageDidStartLoading(httpsForced: false)
            onWebpageDidFinishLoading()
        } else {
            webView.goBack()
        }
    }
    
    func goForward() {
        webView.goForward()
    }
    
    @objc func onLongPress(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        
        let x = Int(sender.location(in: webView).x)
        let y = Int(sender.location(in: webView).y)
        let offsetY = y
        
        webView.getUrlAtPoint(x: x, y: offsetY) { [weak self] (url) in
            guard let url = url else { return }
            let point = Point(x: x, y: y)
            self?.launchLongPressMenu(atPoint: point, forUrl: url)
        }
    }
    
    private func showError(message: String) {
        webView.isHidden = true
        error.isHidden = false
        errorMessage.text = message
    }
    
    private func hideErrorMessage() {
        error.isHidden = true
        webView.isHidden = false
    }
    
    private func reloadScripts() {
        webView.configuration.userContentController.removeAllUserScripts()
        webView.configuration.loadScripts(contentBlocking: !isDuckDuckGoUrl())
    }
    
    private func isDuckDuckGoUrl() -> Bool {
        guard let url = url else { return false }
        return appUrls.isDuckDuckGo(url: url)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let chromeDelegate = chromeDelegate else { return }

        if let controller = segue.destination as? PrivacyProtectionController {
            controller.popoverPresentationController?.delegate = controller

            if let siteRatingView = chromeDelegate.omniBar.siteRatingView {
                controller.popoverPresentationController?.sourceView = siteRatingView
                controller.popoverPresentationController?.sourceRect = siteRatingView.bounds
            }

            controller.delegate = self
            privacyController = controller
            controller.omniDelegate = chromeDelegate.omniBar.omniDelegate
            controller.omniBarText = chromeDelegate.omniBar.textField.text
            controller.siteRating = siteRating
            controller.errorText = isError ? errorText : nil
        }
    }

    private func addContentBlockerConfigurationObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onContentBlockerConfigurationChanged),
                                               name: ContentBlockerConfigurationChangedNotification.name,
                                               object: nil)
    }

    @objc func onContentBlockerConfigurationChanged() {
        // defer for 0.2s so that the privacy protection UI can update without a visible delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.webView?.reload()
        }
    }

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        self.url = url
        self.siteRating = SiteRating(url: url, httpsForced: httpsForced)
        updateSiteRating()
    }

    private func resetNavigationBar() {
        chromeDelegate?.setBarsHidden(false, animated: false)
    }

    @IBAction func onBottomOfScreenTapped(_ sender: UITapGestureRecognizer) {
        showBars(animated: false)
    }

    private func showBars(animated: Bool = true) {
        chromeDelegate?.setBarsHidden(false, animated: animated)
    }

    func showPrivacyProtection() {
        Pixel.fire(pixel: .privacyDashboardOpened)
        if UIUserInterfaceIdiom.pad == UIDevice.current.userInterfaceIdiom {
            performSegue(withIdentifier: "PrivacyProtectionTablet", sender: self)
        } else {
            performSegue(withIdentifier: "PrivacyProtection", sender: self)
        }
    }

    private func resetSiteRating() {
        if let url = url {
            siteRating = SiteRating(url: url, httpsForced: httpsForced)
        } else {
            siteRating = nil
        }
        onSiteRatingChanged()
    }

    private func updateSiteRating() {
        if isError {
            siteRating = nil
        }
        onSiteRatingChanged()
    }

    private func onSiteRatingChanged() {
        delegate?.tab(self, didChangeSiteRating: siteRating)
        privacyController?.updateSiteRating(siteRating)
    }

    func launchBrowsingMenu() {
        Pixel.fire(pixel: .browsingMenuOpened)

        guard let button = chromeDelegate?.omniBar.menuButton else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(refreshAction())
        alert.addAction(newTabAction())

        if let link = link, !isError {
            alert.addAction(saveBookmarkAction(forLink: link))
            alert.addAction(shareAction(forLink: link))
            alert.addAction(toggleDesktopSiteAction(forUrl: link.url))
        }

        if let domain = siteRating?.domain {
            alert.addAction(whitelistAction(forDomain: domain))
        }
        
        alert.addAction(reportBrokenSiteAction())
        alert.addAction(settingsAction())
        alert.addAction(UIAlertAction(title: UserText.actionCancel, style: .cancel))
        present(controller: alert, fromView: button)
    }
    
    func toggleDesktopSiteAction(forUrl url: URL) -> UIAlertAction {
        let title = tabModel.isDesktop ? UserText.actionRequestMobileSite : UserText.actionRequestDesktopSite
        return UIAlertAction(title: title, style: .default) { [weak self] (_) in
            Pixel.fire(pixel: .browsingMenuToggleBrowsingMode)
            self?.tabModel.toggleDesktopMode()
            let isDesktop = self?.tabModel.isDesktop ?? false
            self?.updateUserAgent()
            if isDesktop {
                self?.load(url: url.toDesktopUrl())
            } else {
                self?.reload()
            }
        }
    }
    
    func whitelistAction(forDomain domain: String) -> UIAlertAction {

        let whitelistManager = WhitelistManager()
        let whitelisted = whitelistManager.isWhitelisted(domain: domain)
        let title = whitelisted ? UserText.actionRemoveFromWhitelist : UserText.actionAddToWhitelist
        let operation = whitelisted ? whitelistManager.remove : whitelistManager.add

        return UIAlertAction(title: title, style: .default) { [weak self] (_) in
            Pixel.fire(pixel: .browsingMenuWhitelist)
            operation(domain)
            self?.reload()
        }

    }

    func launchLongPressMenu(atPoint point: Point, forUrl url: URL) {
        Pixel.fire(pixel: .longPressMenuOpened)
        
        let alert = UIAlertController(title: nil, message: url.absoluteString, preferredStyle: .actionSheet)
        alert.addAction(newTabAction(forUrl: url))
        alert.addAction(newBackgroundTabAction(forUrl: url))
        alert.addAction(openAction(forUrl: url))
        alert.addAction(readingAction(forUrl: url))
        alert.addAction(copyAction(forUrl: url))
        alert.addAction(shareAction(forUrl: url, atPoint: point))
        alert.addAction(UIAlertAction(title: UserText.actionCancel, style: .cancel))
        present(controller: alert, fromView: webView, atPoint: point)
    }

    private func refreshAction() -> UIAlertAction {
        return UIAlertAction(title: UserText.actionRefresh, style: .default) { [weak self] _ in
            Pixel.fire(pixel: .browsingMenuRefresh)
            guard let strongSelf = self else { return }
            if strongSelf.isError {
                if let url = URL(string: strongSelf.chromeDelegate?.omniBar.textField.text ?? "") {
                    strongSelf.load(url: url)
                }
            } else {
                strongSelf.reload()
            }
        }
    }

    private func saveBookmarkAction(forLink link: Link) -> UIAlertAction {

        let bookmarksManager = BookmarksManager()
        if let index = bookmarksManager.indexOf(url: link.url) {
            return UIAlertAction(title: UserText.actionRemoveBookmark, style: .default) { _ in
                Pixel.fire(pixel: .browsingMenuRemoveBookmark)
                bookmarksManager.delete(itemAtIndex: index)
            }
        } else {
            return UIAlertAction(title: UserText.actionSaveBookmark, style: .default) { [weak self] _ in
                Pixel.fire(pixel: .browsingMenuAddToBookmarks)
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
        return UIAlertAction(title: UserText.actionNewTab, style: .default) { [weak self] _ in
            Pixel.fire(pixel: .browsingMenuNewTab)
            if let weakSelf = self {
                weakSelf.delegate?.tabDidRequestNewTab(weakSelf)
            }
        }
    }

    private func newTabAction(forUrl url: URL) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionNewTabForUrl, style: .default) { [weak self] _ in
            if let weakSelf = self {
                Pixel.fire(pixel: .longPressMenuNewTabItem)
                weakSelf.delegate?.tab(weakSelf, didRequestNewTabForUrl: url)
            }
        }
    }

    private func newBackgroundTabAction(forUrl url: URL) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionNewBackgroundTabForUrl, style: .default) { [weak self] _ in
            if let weakSelf = self {
                Pixel.fire(pixel: .longPressMenuNewBackgroundTabItem)
                weakSelf.delegate?.tab(weakSelf, didRequestNewBackgroundTabForUrl: url)
            }
        }
    }

    private func openAction(forUrl url: URL) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionOpen, style: .default) { [weak self] _ in
            if let webView = self?.webView {
                Pixel.fire(pixel: .longPressMenuOpenItem)
                webView.load(URLRequest(url: url))
            }
        }
    }

    private func readingAction(forUrl url: URL) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionReadingList, style: .default) { _ in
            Pixel.fire(pixel: .longPressMenuReadingListItem)
            try? SSReadingList.default()?.addItem(with: url, title: nil, previewText: nil)
        }
    }

    private func copyAction(forUrl url: URL) -> UIAlertAction {
        let copyText = url.absoluteString
        return UIAlertAction(title: UserText.actionCopy, style: .default) { (_) in
            Pixel.fire(pixel: .longPressMenuCopyItem)
            UIPasteboard.general.string = copyText
        }
    }

    private func shareAction(forLink link: Link) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionShare, style: .default) { [weak self] _ in
            Pixel.fire(pixel: .browsingMenuShare)
            guard let menu = self?.chromeDelegate?.omniBar.menuButton else { return }
            self?.presentShareSheet(withItems: [ link.url, link ], fromView: menu)
        }
    }

    private func shareAction(forUrl url: URL, atPoint point: Point) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionShare, style: .default) { [weak self] _ in
            Pixel.fire(pixel: .longPressMenuShareItem)
            guard let webView = self?.webView else { return }
            self?.presentShareSheet(withItems: [url], fromView: webView, atPoint: point)
        }
    }

    private func reportBrokenSiteAction() -> UIAlertAction {
        return UIAlertAction(title: UserText.actionReportBrokenSite, style: .default) { [weak self] _ in
            Pixel.fire(pixel: .browsingMenuReportBrokenSite)
            if let weakSelf = self {
                weakSelf.delegate?.tabDidRequestReportBrokenSite(tab: weakSelf)
            }
        }
    }

    private func settingsAction() -> UIAlertAction {
        return UIAlertAction(title: UserText.actionSettings, style: .default) { [weak self] _ in
            Pixel.fire(pixel: .browsingMenuSettings)
            if let weakSelf = self {
                weakSelf.delegate?.tabDidRequestSettings(tab: weakSelf)
            }
        }
    }

    private func shouldLoad(url: URL, forDocument documentUrl: URL) -> Bool {
        if shouldOpenExternally(url: url) {
            openExternally(url: url)
            return false
        }
        return true
    }
    
    private func openExternally(url: URL) {
        UIApplication.shared.open(url, options: [:]) { opened in
            if !opened {
                self.view.showBottomToast(UserText.failedToOpenExternally)
            }
        }
    }

    private func shouldOpenExternally(url: URL) -> Bool {
        if SupportedExternalURLScheme.isSupported(url: url) {
           return true
        }
        
        if SupportedExternalURLScheme.isProhibited(url: url) {
            return false
        }
        
        if url.isCustomURLScheme() {
            
            let title = UserText.customUrlSchemeTitle
            let message = UserText.forCustomUrlSchemePrompt(url: url)
            let open = UserText.customUrlSchemeOpen
            let dontOpen = UserText.customUrlSchemeDontOpen
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: dontOpen, style: .cancel))
            alert.addAction(UIAlertAction(title: open, style: .destructive, handler: { _ in
                self.openExternally(url: url)
            }))
            show(alert, sender: self)
        }
        
        return false
    }

    func dismiss() {
        chromeDelegate = nil
        webView.scrollView.delegate = nil
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
    
    public func tearDown() {
        guard tearDownCount == 0 else {
            fatalError("tearDown has already happened")
        }
        tearDownCount += 1
        removeObservers()
        webView.removeFromSuperview()
        webView.configuration.userContentController.removeScriptMessageHandler(forName: MessageHandlerNames.trackerDetected)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: MessageHandlerNames.cache)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: MessageHandlerNames.log)
    }
    
    private func removeObservers() {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.hasOnlySecureContent))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.url))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack))
    }

    func destroy() {
        dismiss()
        tearDown()
    }
}

extension TabViewController: WKScriptMessageHandler {
    
    private struct MessageHandlerNames {
        static let trackerDetected = "trackerDetectedMessage"
        static let cache = "cacheMessage"
        static let log = "log"
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        switch message.name {

        case MessageHandlerNames.cache:
            handleCache(message: message)

        case MessageHandlerNames.trackerDetected:
            handleTrackerDetected(message: message)

        case MessageHandlerNames.log:
            handleLog(message: message)

        default:
            assertionFailure("Unhandled message: \(message.name)")
        }
    }

    private func handleLog(message: WKScriptMessage) {
        Logger.log(text: String(describing: message.body))
    }

    private func handleCache(message: WKScriptMessage) {
        Logger.log(text: "\(MessageHandlerNames.cache)")
        guard let dict = message.body as? [String: Any] else { return }
        guard let name = dict["name"] as? String else { return }
        guard let data = dict["data"] as? String else { return }
        ContentBlockerStringCache().put(name: name, value: data)
    }

    struct TrackerDetectedKey {
        static let protectionId = "protectionId"
        static let blocked = "blocked"
        static let networkName = "networkName"
        static let url = "url"
    }

    private func handleTrackerDetected(message: WKScriptMessage) {
        Logger.log(text: "\(MessageHandlerNames.trackerDetected) \(message.body)")

        guard let siteRating = siteRating else { return }
        guard let dict = message.body as? [String: Any] else { return }
        guard let blocked = dict[TrackerDetectedKey.blocked] as? Bool else { return }
        guard let urlString = dict[TrackerDetectedKey.url] as? String else { return }
        
        guard siteRating.isFor(self.url) else {
            Logger.log(text: "mismatching domain \(self.url as Any) vs \(siteRating.domain as Any)")
            return
        }

        let url = URL(string: urlString)
        var networkName: String?
        var category: String?
        if let domain = url?.host {
            let networkNameAndCategory = disconnectMeStore.networkNameAndCategory(forDomain: domain)
            networkName = networkNameAndCategory.networkName
            category = networkNameAndCategory.category
        }

        let tracker = DetectedTracker(url: urlString, networkName: networkName, category: category, blocked: blocked)
        siteRating.trackerDetected(tracker)
        onSiteRatingChanged()

        if let networkName = networkName,
            let browsingDomain = siteRating.domain {
            NetworkLeaderboard.shared.network(named: networkName, detectedWhileVisitingDomain: browsingDomain)
        }
    }
}

extension TabViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView,
                        didReceive challenge: URLAuthenticationChallenge,
                        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        completionHandler(.performDefaultHandling, nil)
        guard let serverTrust = challenge.protectionSpace.serverTrust else { return }
        ServerTrustCache.shared.put(serverTrust: serverTrust, forDomain: challenge.protectionSpace.host)
    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        url = webView.url
        let httpsForced = tld.domain(lastUpgradedDomain) == tld.domain(webView.url?.host)
        onWebpageDidStartLoading(httpsForced: httpsForced)
        
        if let url = webView.url, isHttpsUpgradeSite(url: url) {
            statisticsStore.httpsUpgradesTotal += 1
        }
    }
    
    private func onWebpageDidStartLoading(httpsForced: Bool) {
        Logger.log(items: "webpageLoading started:", Date().timeIntervalSince1970)
        self.httpsForced = httpsForced
        delegate?.showBars()
        
        // if host and scheme are the same, don't inject scripts, otherwise, reset and reload
        if let siteRating = siteRating, siteRating.url.host == url?.host, siteRating.url.scheme == url?.scheme {
            self.siteRating = SiteRating(url: siteRating.url, httpsForced: httpsForced)
        } else {
            resetSiteRating()
        }
        
        tabModel.link = link
        delegate?.tabLoadingStateDidChange(tab: self)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if let domain = siteRating?.domain {
            NetworkLeaderboard.shared.visited(domain: domain)
        }
        
        if #available(iOS 10.3, *) {
            appRatingPrompt.registerUsage()
            if appRatingPrompt.shouldPrompt() {
                SKStoreReviewController.requestReview()
                appRatingPrompt.shown()
            }
        }
    }
    
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationResponse: WKNavigationResponse,
                        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
        url = webView.url
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        lastError = nil
        shouldReloadOnError = false
        hideErrorMessage()
        showProgressIndicator()
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideProgressIndicator()
        onWebpageDidFinishLoading()
    }
    
    private func onWebpageDidFinishLoading() {
        Logger.log(items: "webpageLoading finished:", Date().timeIntervalSince1970)
        siteRating?.finishedLoading = true
        updateSiteRating()
        tabModel.link = link
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        delegate?.tabLoadingStateDidChange(tab: self)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideProgressIndicator()
        webpageDidFailToLoad()
        
        let error = error as NSError
        if let url = webView.url, isHttpsUpgradeSite(url: url) {
            reportHttpsUpgradeSiteError(url: url, error: "\(error.domain)_\(error.code)")
        }
        
        checkForReloadOnError()
    }

    private func webpageDidFailToLoad() {
        Logger.log(items: "webpageLoading failed:", Date().timeIntervalSince1970)
        if isError {
            showBars(animated: true)
        }
        siteRating?.finishedLoading = true
        updateSiteRating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.delegate?.tabLoadingStateDidChange(tab: self)
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        hideProgressIndicator()
        lastError = error
        let error = error as NSError
        
        if let url = url, isHttpsUpgradeSite(url: url) {
            reportHttpsUpgradeSiteError(url: url, error: "\(error.domain)_\(error.code)")
        }
        
        // prevent loops where a site keeps redirecting to itself (e.g. bbc)
        if let url = url,
            let domain = url.host,
            error.code == Constants.frameLoadInterruptedErrorCode {
            failingUrls.insert(domain)
        }
        
        // wait before showing errors in case they recover automatically
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showErrorNow()
        }
    }
    
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let decision = decidePolicyFor(navigationAction: navigationAction)
        
        if let url = navigationAction.request.url,
            decision == .allow,
            appUrls.isDuckDuckGoSearch(url: url) {
            StatisticsLoader.shared.refreshRetentionAtb()
        }
        
        decisionHandler(decision)
    }
    
    private func decidePolicyFor(navigationAction: WKNavigationAction) -> WKNavigationActionPolicy {
        
        if navigationAction.isTargetingMainFrame()
            && tld.domain(navigationAction.request.mainDocumentURL?.host) != tld.domain(lastUpgradedDomain) {
            lastUpgradedDomain = nil
        }
        
        guard let url = navigationAction.request.url else {
            return .allow
        }
        
        guard !url.absoluteString.hasPrefix("x-apple-data-detectors://") else {
            return .cancel
        }
        
        guard let documentUrl = navigationAction.request.mainDocumentURL else {
            return .allow
        }
        
        if shouldReissueSearch(for: url) {
            reissueSearchWithStatsParams(for: url)
            return .cancel
        }
        
        if !failingUrls.contains(url.host ?? ""),
            navigationAction.isTargetingMainFrame(),
            let upgradeUrl = httpsUpgrade.upgrade(url: url) {
            
            lastUpgradedDomain = upgradeUrl.host
            load(url: upgradeUrl)
            
            return .cancel
        }
        
        if shouldLoad(url: url, forDocument: documentUrl) {
            return .allow
        }
        
        return .cancel
    }
    
    private func showErrorNow() {
        guard let error = lastError else { return }
        hideProgressIndicator()
        
        let code = (error as NSError).code
        if  ![Constants.unsupportedUrlErrorCode, Constants.urlCouldNotBeLoaded].contains(code) {
            showError(message: error.localizedDescription)
        }
        
        webpageDidFailToLoad()
        checkForReloadOnError()
    }
    
    private func isHttpsUpgradeSite(url: URL) -> Bool {
        return url.isHttps() && HTTPSUpgrade.shared.isInUpgradeList(url: url)
    }
    
    private func reportHttpsUpgradeSiteError(url: URL, error: String) {
        guard let host = url.host else { return }
        let params = [
            Pixel.EhdParameters.errorCode: error,
            Pixel.EhdParameters.url: "https://\(host)"
        ]
        Pixel.fire(pixel: .httpsUpgradeSiteError, withAdditionalParameters: params)
        statisticsStore.httpsUpgradesFailures += 1
    }
}

extension TabViewController: ContentBlockerSettingsChangeDelegate {
    func contentBlockerSettingsDidChange() {
        onContentBlockerConfigurationChanged()
    }
}

extension TabViewController: PrivacyProtectionDelegate {
    func omniBarTextTapped() {
        chromeDelegate?.omniBar.becomeFirstResponder()
    }
}

extension TabViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView,
                        createWebViewWith configuration: WKWebViewConfiguration,
                        for navigationAction: WKNavigationAction,
                        windowFeatures: WKWindowFeatures) -> WKWebView? {
        webView.load(navigationAction.request)
        return nil
    }
    
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        delegate?.tabContentProcessDidTerminate(tab: self)
    }
}

extension TabViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension TabViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if isShowBarsTap(gestureRecognizer) {
            return true
        }
        if gestureRecognizer == longPressGestureRecognizer {
            let x = Int(gestureRecognizer.location(in: webView).x)
            let y = Int(gestureRecognizer.location(in: webView).y)
            let url = webView.getUrlAtPointSynchronously(x: x, y: y)
            return url != nil
        }
        return false
    }

    private func isShowBarsTap(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let y = gestureRecognizer.location(in: webView).y
        return gestureRecognizer == showBarsTapGestureRecogniser && chromeDelegate?.isToolbarHidden == true && isBottom(yPosition: y)
    }

    private func isBottom(yPosition y: CGFloat) -> Bool {
        guard let chromeDelegate = chromeDelegate else { return false }
        return y > (view.frame.size.height - chromeDelegate.toolbarHeight)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == showBarsTapGestureRecogniser || gestureRecognizer == longPressGestureRecognizer
    }
}

private extension WKNavigationAction {
    
    func isTargetingMainFrame() -> Bool {
        return targetFrame?.isMainFrame ?? false
    }
}
