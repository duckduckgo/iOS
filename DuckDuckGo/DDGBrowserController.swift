//
// Created by Sean Reilly on 2017.01.23.
// Copyright (c) 2017 DuckDuckGo. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import AssetsLibrary
import WebKit
import Photos


class DDGBrowserController: UIViewController, 
        WKUIDelegate, 
        WKNavigationDelegate, 
        UIGestureRecognizerDelegate, 
        DDGToolbarAndNavigationBarAutohiderDelegate, 
        MFMailComposeViewControllerDelegate
{
  @IBOutlet var toolnar:UIView?
  @IBOutlet var backButton:UIButton?
  @IBOutlet var forwardButton:UIButton?
  @IBOutlet var favButton:UIButton?
  @IBOutlet var shareButton:UIButton?
  @IBOutlet var tabsButton:UIButton?
  @IBOutlet var tabBarTopBorderConstraint:NSLayoutConstraint? // this exists to force the border to be 0.5px
  @IBOutlet var bottomToolbarTopConstraint:NSLayoutConstraint?
  @IBOutlet var webToolbar:UIView?
  @IBOutlet var webview: DDGWebView?
  
  weak var searchController : DDGSearchController?
  var params:Dictionary<String,String> = [:]
  var webViewURL : URL?
  var webViewLoadingDepth = 0
  var readabilityMode = false
  
  var autohider: DDGToolbarAndNavigationBarAutohider?
  var tapGestureRecognizer: UITapGestureRecognizer?
  
  var isFavorited = false
  var lastOffset = CGPoint.zero
  var lastUpwardsScrollDistance: CGFloat = 0.0
  var ignoreTapsUntil: NSDate?

  init(searchController:DDGSearchController) {
    self.searchController = searchController
    super.init(nibName:"DDGBrowserController", bundle:nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let webview = self.webview {
      webview.navigationDelegate = self
      webview.uiDelegate = self
      webview.webController = self;
      webview.backgroundColor = UIColor.duckNoContentColor
      webview.translatesAutoresizingMaskIntoConstraints = false
      webview.configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
      self.webViewLoadingDepth = 0
      
      self.autohider = DDGToolbarAndNavigationBarAutohider(containerView: webview,
                                                           scrollView: webview.scrollView,
                                                           delegate: self)
      webview.addGestureRecognizer(self.tapGestureRecognizer!)
    }
    
    self.updateButtons()
    self.tabBarTopBorderConstraint?.constant = 0.5
    let searchMenuItem = UIMenuItem(title: NSLocalizedString("Search", comment: "Search menu item name"), action: #selector(self.search))
    UIMenuController.shared.menuItems = [ searchMenuItem ]
    self.tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(handleTap))
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  deinit {
    self.webview?.scrollView.delegate = nil
    self.resetLoadingDepth()
    if let tapRecognizer = self.tapGestureRecognizer {
      self.tapGestureRecognizer = nil
      tapRecognizer.delegate = nil
      // self.view.removeGestureRecognizer(self.tapGestureRecognizer)
    }
    self.webview?.navigationDelegate = nil
    self.webview?.uiDelegate = nil
    self.webViewURL = nil
  }
  
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.shouldEnableNavControllerSwipe(true)
  }
  
  
// MARK: == Loading ==


  func loadWebView(with url: URL) {
    self.webview?.load(DDGUtility.request(with: url))
    self.searchDDG()?.updateBar(with: url)
    self.webViewURL = url
  }
  
  func currentURL() -> String {
    return self.webview?.url?.absoluteString ?? ""
  }

  // MARK: == WKUIDelegate ==
  
  func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
    if !navigationAction.targetFrame!.isMainFrame {
      webView.load(navigationAction.request)
    }
    return nil
  }
  
  // MARK: == WKNavigationDelegate ==
  
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
    self.updateButtons()
    self.incrementLoadingDepth()
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
    // Update bar
    self.updateBar(with: URLRequest(url: webView.url!))
    self.updateButtons()
    self.decrementLoadingDepth(cancelled:false)
    self.shouldEnableNavControllerSwipe(!webView.canGoBack)
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
    self.decrementLoadingDepth(cancelled:true)
  }
  
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (_: WKNavigationActionPolicy) -> Void) {
    if navigationAction.navigationType == .linkActivated {
      if let ignoreUntil = self.ignoreTapsUntil, ignoreUntil.compare(Date()) == ComparisonResult.orderedDescending {
        // ignore clicks within a certain range
        decisionHandler(.cancel)
        return
      }
      if (webView.url!.scheme!.lowercased() == "mailto") {
        // user is interested in mailing so use the internal mail API
        self.perform(#selector(self.internalMailAction), with: webView.url!, afterDelay: 0.005)
        decisionHandler(.cancel)
        return
      }
    }
    self.updateBar(with: URLRequest(url: webView.url!))
    decisionHandler(.allow)
  }
  
  
  // MARK: == Navigation Swiping Methods
  
  func shouldEnableNavControllerSwipe(_ enable: Bool) {
    if let navController = self.searchController?.navController {
      navController.interactivePopGestureRecognizer?.isEnabled = enable
      navController.interactivePopGestureRecognizer?.delegate = enable ? nil : self
    }
    self.webview?.allowsBackForwardNavigationGestures = enable
  }
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    if gestureRecognizer == self.searchController?.navController.interactivePopGestureRecognizer {
      return false
    }
    return true
  }
  
  
  
  
  
  // MARK - webview delegate methods
  func webView(_ webView: WKWebView, shouldStartLoadWithRequest request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    if navigationType == .linkClicked {
      if let ignoreUntil=self.ignoreTapsUntil, ignoreUntil.compare(Date()) == ComparisonResult.orderedDescending {
        return false
      }
      
      // ignore clicks within a certain range
      if let url = request.url, url.scheme?.lowercased() == "mailto" {
        // user is interested in mailing so use the internal mail API
        self.internalMailAction(with:url as NSURL)
        self.perform(#selector(self.internalMailAction), with: request.url, afterDelay: 0.005)
        return false
      }
    }
    //NSLog(@"shouldStartLoadWithRequest: %@ navigationType: %i", request, navigationType);
    return true
  }
  
  func webViewDidStartLoad(_ theWebView: UIWebView) {
    self.updateButtons()
    self.incrementLoadingDepth()
  }
  
  func webViewDidFinishLoad(_ theWebView: UIWebView) {
    self.updateBar(with: theWebView.request!)
    //[self.searchController webViewCanGoBack:theWebView.canGoBack];
    self.updateButtons()
    self.decrementLoadingDepth(cancelled: false)
    //    NSLog(@"webViewDidFinishLoad events: %i", _webViewLoadEvents);
  }
  
  func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
    self.decrementLoadingDepth(cancelled: true)
    //    NSLog(@"didFailLoadWithError events: %i", _webViewLoadEvents);
  }
  
  
  
  //MARK - handle mailto links
  func internalMailAction(with url:NSURL) {
    guard MFMailComposeViewController.canSendMail() else { return }
    var params:Dictionary<String,String> = [:]
    
    let withoutScheme = url.absoluteString?.replacingOccurrences(of: "mailto:", with: "", options: .anchored, range: nil)
    if let withoutScheme = withoutScheme, let questionMarkRange = withoutScheme.rangeOfCharacter(from: CharacterSet(charactersIn:"?")) {
      // more than just a to field
      let toString = withoutScheme.substring(to: questionMarkRange.lowerBound)
      params["to"] = toString.removingPercentEncoding ?? toString
      
      let parametersOffset = withoutScheme.index(questionMarkRange.lowerBound, offsetBy: 1)
      let parametersString = withoutScheme.substring(from: parametersOffset)
      for parameter in parametersString.components(separatedBy: "&") {
        var keyValuePair:Array<String> = parameter.components(separatedBy: "=")
        let key = keyValuePair[0]
        let value = (keyValuePair.count>1 ? keyValuePair[1..<keyValuePair.count].joined(separator: "") : "")
        params[(key.removingPercentEncoding ?? key)] = (value.removingPercentEncoding ?? value)
      }
    } else {
      // the mailto link has no parameters, so just use the rest of the string as the address...
      params["to"] = withoutScheme?.removingPercentEncoding ?? withoutScheme
    }
    
    // now mail it
    let mailVC = MFMailComposeViewController()
    mailVC.mailComposeDelegate = self;
    if let recipient = params["to"] {
      mailVC.setToRecipients(recipient.components(separatedBy: ","))
    } else {
      mailVC.setToRecipients([])
      mailVC.setSubject(params["subject"] ?? "")
      mailVC.setMessageBody(params["body"] ?? "", isHTML: true)
      self.present(mailVC, animated: true)
    }
  }
  
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    self.dismiss(animated: true)
  }
  
  
//  func setUpWebToolBar() {
//    UINib(nibName: "DDGWebToolbar", bundle: nil).instantiate(withOwner: self)
//    if let webtoolbar = self.webToolbar {
//      self.view.addSubview(webtoolbar)
//      var constraints = [
//              NSLayoutConstraint(item: webtoolbar, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
//              NSLayoutConstraint(item: webtoolbar, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0),
//              NSLayoutConstraint(item: webtoolbar, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
//      ]
//      if let toolbarConstraint = self.bottomToolbarTopConstraint {
//        constraints.append(toolbarConstraint)
//      }
//
//      self.view.addConstraints(constraints)
//    }
//  }
  
  override func viewWillAppear(_ animated:Bool) {
    super.viewWillAppear(animated)
    
    // used to set insets for toolbars.  Shouldn't be necessary in our case... yet
    //[self.searchControllerDDG.homeController registerScrollableContent:self.webView.scrollView];
  }

  override func viewWillDisappear(_ animated:Bool) {
    if let webview = self.webview, webview.isLoading {
      webview.stopLoading()
    }
    self.resetLoadingDepth()
    self.searchDDG()?.expandNavigationBar()
    super.viewWillDisappear(animated)
    UIMenuController.shared.menuItems = nil
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if let webview = self.webview {
      webview.scrollView.contentInset = UIEdgeInsets()
      webview.scrollView.scrollIndicatorInsets = UIEdgeInsets()
      lastOffset = webview.scrollView.contentOffset
    }
    lastUpwardsScrollDistance = 0;
  }
  
  override func willRotate(to orientation:UIInterfaceOrientation, duration:TimeInterval) {
    self.searchDDG()?.willRotate(to: orientation, duration: duration)
  }
  
  
  // MARK - long-press gesture handling
  
  func handleTap(recognizer:UITapGestureRecognizer?) {
    print("tap handled")
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    guard otherGestureRecognizer is UILongPressGestureRecognizer else {
      return true
    }
    
    if(otherGestureRecognizer.state == .began && gestureRecognizer.state == .failed) {
      let touchLoc = otherGestureRecognizer.location(in: self.webview)
      if let imageURL = self.findImage(atLocation:touchLoc) {
        self.longPress(onImage:imageURL as URL, atLocation:touchLoc)
      }
    }
    return true
  }
  
  func longPress(onImage image:URL, atLocation location:CGPoint) {
//    var applicationActivities = []
//    var activityItemProviders:Array<DDGImageActivityItemProvider>
    
    print("should handle the long-press by opening an activity view controller with the image (URL)")
  
//    var activityItems = [ DDGImageActivityItemProvider(imageURL) ]
//    DDGActivityViewController *avc = [[DDGActivityViewController alloc] initWithActivityItems:items
//    applicationActivities:applicationActivities];
//    if ( [avc respondsToSelector:@selector(popoverPresentationController)] ) {
//      // iOS8
//      avc.popoverPresentationController.sourceView = self.view;
//      avc.popoverPresentationController.sourceRect = CGRectMake(tapPoint.x, tapPoint.y, 1, 1);
//    }
//  
//    [self presentViewController:avc animated:YES completion:NULL];
  }

  
  func handleLongPress(recognizer:UIGestureRecognizer) {
    let touchLocation = recognizer.location(in: self.webview)
    if let imageURL = self.findImage(atLocation:touchLocation) {
      self.longPress(onImage: imageURL, atLocation: touchLocation)
    }
  }
  
  func findImage(atLocation tapLocation:CGPoint) -> URL? {
    let javascript = "var ddg_url = '';" +
            "var node = document.elementFromPoint(\(tapLocation.x), \(tapLocation.y));" +
            "while(node) {" +
            "  if (node.tagName) {" +
            "    if(node.tagName.toLowerCase() == 'img' && node.src && node.src.length > 0) {" +
            "      ddg_url = node.src;" +
            "      break;" +
            "    }" +
            "  }" +
            "  node = node.parentNode;" +
            "}";
    
    if let url = self.webview?.stringByEvaluatingJavaScript(fromString: javascript), DDGUtility.looksLikeURL(url) {
      print("tapped on image: \(url)")
      return URL(string:url)
    }
    return nil;
  }
  

  func updateButtons() {
    if let webview = self.webview {
      self.backButton?.isEnabled = webview.canGoBack || (self.navigationController?.viewControllers.count ?? 0) > 1
      self.forwardButton?.isEnabled = webview.canGoForward
    }
  }
  
  func updateProgressBar() {
    if webViewLoadingDepth==1 {
      self.searchDDG()?.setProgress(0.15)
    } else if webViewLoadingDepth==2 {
      self.searchDDG()?.setProgress(0.7)
    }
  }
  
  func incrementLoadingDepth() {
    webViewLoadingDepth += 1
    if webViewLoadingDepth==1 {
      searchDDG()?.webViewStartedLoading()
    }
    
    self.updateProgressBar()
  }
  
  func decrementLoadingDepth(cancelled:Bool) {
    webViewLoadingDepth -= 1
    
    if webViewLoadingDepth <= 0 {
      if (cancelled) { 
        self.searchDDG()?.webViewCancelledLoading()
      } else {
        self.searchDDG()?.webViewFinishedLoading()
      }
      webViewLoadingDepth = 0
    }
  }

  func resetLoadingDepth() {
    if webViewLoadingDepth > 0 {
      self.searchDDG()?.webViewCancelledLoading()
    }
    
    webViewLoadingDepth = 0
  }

 // MARK - other
  func hasAccessToPhotos() -> Bool {
    let status = PHPhotoLibrary.authorizationStatus()
    return status == .notDetermined || status == .authorized
  }
  
  
  
  func setHideToolbarAndNavigationBar(_ shouldHide: Bool, forScrollview scrollView: UIScrollView) {
    let newConstant = CGFloat(shouldHide ? 50.0 : 0.0)
    if (shouldHide) {
      self.searchDDG()?.compactNavigationBar()
    } else {
      self.searchDDG()?.expandNavigationBar()
    }
    if let topConstraint = self.bottomToolbarTopConstraint, topConstraint.constant != newConstant {
      self.bottomToolbarTopConstraint?.constant = newConstant
      let toolbarBottomInset = CGFloat(shouldHide ? 0 : 50)
      UIView.animate(withDuration: 0.25, animations: {
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, toolbarBottomInset, 0);
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, toolbarBottomInset, 0);
        self.view.layoutSubviews()
      })
    }
  }

  @IBAction func searchControllerActionButtonPressed(_ sender: Any?) {
    guard var shareURL = self.webViewURL else {
      return
    }
  
    if let queryString = DDGUtility.extractQuery(fromDDGURL: shareURL) {
      let encodedQuery = queryString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? queryString
      shareURL = URL(string:("https://duckduckgo.com/?q=".appending(encodedQuery))) ?? shareURL
    }
  
    var shareString = NSLocalizedString("{title}\n\nvia DuckDuckGo for iOS", comment:"The default text to use when sharing a link, replacing {title} with the page's title, if any")
    let pageTitle = self.webview?.stringByEvaluatingJavaScript(fromString: "document.title") ?? ""
    shareString = shareString.replacingOccurrences(of: "{title}", with: pageTitle)
    
    //var appActivities = []
    let items = [shareString, shareURL] as [Any]
    
//    if (self.inReadabilityMode) {
//        DDGReadabilityToggleActivity *toggleActivity = [[DDGReadabilityToggleActivity alloc] init];
//        toggleActivity.toggleMode = DDGReadabilityToggleModeOff;
//        applicationActivities = [applicationActivities arrayByAddingObject:toggleActivity];
//    } else if ([self canSwitchToReadabilityMode]) {
//        DDGReadabilityToggleActivity *toggleActivity = [[DDGReadabilityToggleActivity alloc] init];
//        toggleActivity.toggleMode = DDGReadabilityToggleModeOn;
//        applicationActivities = [applicationActivities arrayByAddingObject:toggleActivity];
//    }
//    
    let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
    activityController.popoverPresentationController?.sourceView = sender as? UIView ?? self.shareButton ?? self.view
    self.present(activityController, animated: true)
  }
  
  
  // MARK - search handler
  
  func prepareForUserInput() {
    if let searchField = self.searchDDG()?.searchBar?.searchField, searchField.window != nil {
      searchField.becomeFirstResponder()
    }
  }

  @IBAction func backButtonPressed(_ sender: Any?) {
    if let webview=self.webview, webview.canGoBack {
      webview.goBack()
    } else if searchDDG()?.canPopContentViewController() ?? false {
      searchDDG()?.popContentViewController(animated: true)
    }
  }
  
  @IBAction func forwardButtonPressed(_ sender: Any?) {
    if let webview=self.webview, webview.canGoForward {
      webview.goForward()
    }
  }

  @IBAction func shareButtonPressed(_ sender:Any?) {
    self.searchControllerActionButtonPressed(sender)
  }
  
  @IBAction func searchControllerLeftButtonPressed(_ sender:Any?) {
    if searchDDG()?.canPopContentViewController() ?? false {
      searchDDG()?.popContentViewController(animated: true)
    }
  }
  
  @IBAction func searchControllerStopOrReloadButtonPressed() {
    if let webview=self.webview {
      if webview.isLoading {
        webview.stopLoading()
      } else {
        webview.reload()
      }
    }
  }

  func loadQueryOrURL(queryOrURLString:String) {
    //self.loadViewIfNeeded()
    
    
    if let urlString = DDGUtility.validURLString(from: queryOrURLString), let url = URL(string:urlString) {
      self.loadWebView(with: url)
    } else {
      // it wasn't something we could interpret as a URL, so query for it
      let encodedQuery = queryOrURLString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? queryOrURLString
      let encodedRegion = (UserDefaults.standard.string(forKey:DDGSettingRegion) ?? "").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
      if let url = URL(string:"https://duckduckgo.com/?q="+encodedQuery+"&ko=-1&kl=" + encodedRegion) {
        self.loadWebView(with: url)
      }
    }
  }
  
  // MARK - Searching for selected text
  

  override func canPerformAction(_ action:Selector, withSender sender:Any?) -> Bool {
    if action==#selector(search) {
      return !(self.searchDDG()?.searchBar?.searchField?.isFirstResponder ?? false)
    }
    return super.canPerformAction(action, withSender:sender)
  }

  func search(menuItem:UIMenuItem) {
    if let selection = self.webview?.stringByEvaluatingJavaScript(fromString: "window.getSelection().toString()") {
      self.loadQueryOrURL(queryOrURLString: selection)
    }
  }
  
  func updateBar(with request: URLRequest) {
    let url = request.url
    let mainURL = request.mainDocumentURL
    if url != nil && url != mainURL {
      let scheme = url!.scheme?.lowercased() ?? ""
      if scheme=="http" || scheme=="https" {
        self.searchDDG()?.updateBar(with: url!)
        self.webViewURL = url
        self.readabilityMode = false
      }
    }    
  }
  
  
}





class DDGWebView: WKWebView {
  var webController:DDGBrowserController?
  let blackHoleView = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(1), height: CGFloat(1)))
  
  func stringByEvaluatingJavaScript(fromString script: String) -> String? {
    var resultURLString: String? = nil
    var finished = false
    self.evaluateJavaScript(script, completionHandler: {(_ result: Any?, _ error: Error?) -> Void in
      if let error = error {
        print("error : \(error.localizedDescription)")
      } else if let result = result {
        resultURLString = "\(result)"
      } else {
        print("no result or error from javascript")
      }
      finished = true
    })
    
    while !finished {
      RunLoop.current.run(mode: .defaultRunLoopMode, before: Date.distantFuture)
    }
    return resultURLString
  }
  
  
  
  // this method was added to swallow any taps on the bottom toolbar area if the toolbars were collapsed so that the bottom toolbar could be shown without passing through any taps
  override func hitTest(_ tapPoint: CGPoint, with event: UIEvent?) -> UIView? {
    // if someone taps the bottom toolbar area, swallow the tap and show the toolbar
    if let controller = self.webController {
      if tapPoint.y + 50 > self.frame.size.height {
        controller.setHideToolbarAndNavigationBar(false, forScrollview: self.scrollView)
        return self.blackHoleView
      }
    }
    return super.hitTest(tapPoint, with: event)!
  }
  
}







