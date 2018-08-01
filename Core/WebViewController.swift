//
//  WebViewController.swift
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

import UIKit
import WebKit

open class WebViewController: UIViewController {

    private struct WebViewKeyPaths {
        static let estimatedProgress = "estimatedProgress"
        static let hasOnlySecureContent = "hasOnlySecureContent"
        static let url = "URL"
        static let canGoBack = "canGoBack"
        static let canGoForward = "canGoForward"
    }

    private struct Constants {
        static let frameLoadInterruptedErrorCode = 102
        static let minimumProgress: Float = 0.1
    }

    var failingUrls = Set<String>()

    public weak var webEventsDelegate: WebEventsDelegate?

    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var error: UIView!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var webViewContainer: UIView!

    open private(set) var webView: WKWebView!

    public var loadedURL: URL?

    private var lastUpgradedDomain: String?
    private var lastError: Error?
    private var shouldReloadOnError = false

    private lazy var appUrls: AppUrls = AppUrls()
    private lazy var httpsUpgrade = HTTPSUpgrade()
    private lazy var tld = TLD()

    private var tearDownCount = 0
    
    public var name: String? {
        return webView.title
    }

    public var url: URL? {
        return isError ? loadedURL : webView?.url
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

    open override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onApplicationWillResignActive),
                                               name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }

    @objc func onApplicationWillResignActive() {
        shouldReloadOnError = true
    }

    fileprivate func addObservers() {
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.hasOnlySecureContent), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
    }
    
    open func attachWebView(configuration: WKWebViewConfiguration) {
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        attachLongPressHandler(webView: webView)
        webView.allowsBackForwardNavigationGestures = true

        addObservers()

        webView.navigationDelegate = self
        webView.uiDelegate = self
        webViewContainer.addSubview(webView)
        webEventsDelegate?.attached(webView: webView)

        webView.configuration.websiteDataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { _ in
            WebCacheManager.consumeCookies()
            if let url = self.url {
                self.load(url: url)
            }
        }

    }

    private func attachLongPressHandler(webView: WKWebView) {
        let handler = WebLongPressGestureRecognizer(target: self, action: #selector(onLongPress(sender:)))
        handler.delegate = self
        webView.scrollView.addGestureRecognizer(handler)
    }

    @objc func onLongPress(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }

        let x = Int(sender.location(in: webView).x)
        let y = Int(sender.location(in: webView).y)
        let offsetY = y

        webView.getUrlAtPoint(x: x, y: offsetY) { [weak self] (url) in
            guard let webView = self?.webView, let url = url else { return }
            let point = Point(x: x, y: y)
            self?.webEventsDelegate?.webView(webView, didReceiveLongPressForUrl: url, atPoint: point)
        }
    }

    public func load(url: URL) {
        loadedURL = url
        lastError = nil
        load(urlRequest: URLRequest(url: url))
    }

    private func load(urlRequest: URLRequest) {
        print("***", #function, urlRequest.url)
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
            webEventsDelegate?.webView(webView, didUpdateHasOnlySecureContent: webView.hasOnlySecureContent)

        case WebViewKeyPaths.url:
            urlDidChange()

        case WebViewKeyPaths.canGoBack:
            canGoBackChanged()

        case WebViewKeyPaths.canGoForward:
            canGoForwardChanged()

        default:
            Logger.log(text: "Unhandled keyPath \(keyPath)")
        }
    }

    private func urlDidChange() {
        DispatchQueue.main.async {
            self.webEventsDelegate?.webView(self.webView, didChangeUrl: self.webView.url)
        }
    }

    private func canGoBackChanged() {
        webEventsDelegate?.webpageCanGoBackForwardChanged()
    }

    private func canGoForwardChanged() {
        webEventsDelegate?.webpageCanGoBackForwardChanged()
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
        webView.reload()
    }

    open func goBack() {
        if isError {
            hideErrorMessage()
            loadedURL = webView.url
            webEventsDelegate?.webpageDidStartLoading(httpsForced: false)
            webEventsDelegate?.webpageDidFinishLoading()
        } else {
            webView.goBack()
        }
    }

    open func goForward() {
        webView.goForward()
    }

    fileprivate func removeObservers() {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.hasOnlySecureContent))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.url))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack))
    }
    
    public func tearDown() {
        guard tearDownCount == 0 else {
            fatalError("tearDown has already happened")
        }
        tearDownCount += 1
        removeObservers()
        webView.removeFromSuperview()
        webEventsDelegate?.detached(webView: webView)
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

    open func reloadScripts(with protectionId: String) {
        webView.configuration.userContentController.removeAllUserScripts()
        webView.configuration.loadScripts(with: protectionId, contentBlocking: !isDuckDuckGoUrl())
    }

    private func isDuckDuckGoUrl() -> Bool {
        guard let url = url else { return false }
        return appUrls.isDuckDuckGo(url: url)
    }

}

extension WebViewController: WKUIDelegate {

    public func webView(_ webView: WKWebView,
                        createWebViewWith configuration: WKWebViewConfiguration,
                        for navigationAction: WKNavigationAction,
                        windowFeatures: WKWindowFeatures) -> WKWebView? {
        webView.load(navigationAction.request)
        return nil
    }

    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webEventsDelegate?.contentProcessDidTerminate(webView: webView)
    }

}

extension WebViewController: WKNavigationDelegate {

    public func webView(_ webView: WKWebView,
                        didReceive challenge: URLAuthenticationChallenge,
                        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        completionHandler(.performDefaultHandling, nil)
        guard let serverTrust = challenge.protectionSpace.serverTrust else { return }
        ServerTrustCache.shared.put(serverTrust: serverTrust, forDomain: challenge.protectionSpace.host)
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        lastError = nil
        shouldReloadOnError = false
        hideErrorMessage()
        showProgressIndicator()

        let httpsForced = tld.domain(lastUpgradedDomain) == tld.domain(webView.url?.host)
        webEventsDelegate?.webpageDidStartLoading(httpsForced: httpsForced)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideProgressIndicator()
        webEventsDelegate?.webpageDidFinishLoading()
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideProgressIndicator()
        webEventsDelegate?.webpageDidFailToLoad()
        checkForReloadOnError()
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        lastError = error
        let error = error as NSError

        // prevent loops where a site keeps redirecting to itself (e.g. bbc)
        if let url = loadedURL,
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
        if decision == .allow && navigationAction.isTargettingMainFrame() {
            showProgressIndicator()
        }
        decisionHandler(decision)
    }

    private func decidePolicyFor(navigationAction: WKNavigationAction) -> WKNavigationActionPolicy {

        if navigationAction.isTargettingMainFrame()
            && tld.domain(navigationAction.request.mainDocumentURL?.host) != tld.domain(lastUpgradedDomain) {

            lastUpgradedDomain = nil

        }

        guard let url = navigationAction.request.url else {
            return .allow
        }

        guard !url.absoluteString.hasPrefix("x-apple-data-detectors://") else {
            return .cancel
        }

        guard let delegate = webEventsDelegate,
            let documentUrl = navigationAction.request.mainDocumentURL else {
                return .allow
        }

        if appUrls.isDuckDuckGoSearch(url: url) {
            print("***", #function, "refreshing statistics", url)
            StatisticsLoader.shared.refreshRetentionAtb()
        }

        if shouldReissueSearch(for: url) {
            reissueSearchWithStatsParams(for: url)
            return .cancel
        }

        if !failingUrls.contains(url.host ?? ""),
            navigationAction.isTargettingMainFrame(),
            let upgradeUrl = httpsUpgrade.upgrade(url: url) {

            lastUpgradedDomain = upgradeUrl.host
            load(url: upgradeUrl)

            return .cancel
        }

        if delegate.webView(webView, shouldLoadUrl: url, forDocument: documentUrl) {
            return .allow
        }

        return .cancel
    }

    private func showErrorNow() {
        guard let error = lastError else { return }
        hideProgressIndicator()
        showError(message: error.localizedDescription)
        webEventsDelegate?.webpageDidFailToLoad()
        checkForReloadOnError()
    }

}

extension WebViewController: UIGestureRecognizerDelegate {

    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer is WebLongPressGestureRecognizer else {
            return false
        }

        let x = Int(gestureRecognizer.location(in: webView).x)
        let y = Int(gestureRecognizer.location(in: webView).y)
        let url = webView.getUrlAtPointSynchronously(x: x, y: y)
        return url != nil
    }

    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return gestureRecognizer is WebLongPressGestureRecognizer
    }
}

private class WebLongPressGestureRecognizer: UILongPressGestureRecognizer {}

fileprivate extension WKNavigationAction {

    func isTargettingMainFrame() -> Bool {
        return targetFrame?.isMainFrame ?? false
    }

}
