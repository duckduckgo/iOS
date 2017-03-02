//
//  WebTabViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 01/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import WebKit
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
    
    func clear() {
        tearDown()
        removeFromParentViewController()
        view.removeFromSuperview()
    }
}

extension WebTabViewController: OmniBarDelegate {
    
    func onOmniQuerySubmitted(_ query: String) {
        load(query: query)
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
    
    func webView(_ webView: WKWebView, didReceiveLongPressAtPoint point: Point) {
           webView.getUrlAtPoint(x: point.x, y: point.y) {[weak self] (url) in
            if let url = url {
                self?.tabDelegate?.openNewTab(fromWebView: webView, forUrl: url)
            }
        }
    }
}
