//
//  BrowserViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 24/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import WebKit


class BrowserViewController: UIViewController, UISearchBarDelegate, WebLoadingDelegate {
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    private var searchBar: UISearchBar!
    private weak var webController: WebViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        refreshNavigationButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    private func configureSearchBar() {
        searchBar = UISearchBar()
        searchBar.placeholder = UserText.searchDuckDuckGo
        searchBar.textColor = UIColor.darkGray
        searchBar.autocapitalizationType = .none
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    private func configureNavigationBar() {
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.isToolbarHidden = false
    }
    
    private func refreshSearchText() {
        guard let url = webController?.url else {
            searchBar.text = nil
            return
        }
        guard !AppUrls.isDuckDuckGo(url: url) else {
            searchBar.text = nil
            return
        }
        searchBar.text = url.absoluteString
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        onSearchSubmitted()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        onSearchSubmitted()
    }
    
    private func onSearchSubmitted() {
        searchBar.resignFirstResponder()
        guard let text = searchBar.text?.trimWhitespace() else {
            return
        }
        webController?.load(text: text)
    }
    
    func webpageDidStartLoading() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webpageDidFinishLoading() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        refreshNavigationButtons()
    }
    
    private func refreshNavigationButtons() {
        backButton.isEnabled = webController?.canGoBack ?? false
        forwardButton.isEnabled = webController?.canGoForward ?? false
    }
    
    @IBAction func onHomePressed(_ sender: UIBarButtonItem) {
        webController?.loadHomepage()
    }
    
    @IBAction func onRefreshPressed(_ sender: UIBarButtonItem) {
        webController?.reload()
    }
    
    @IBAction func onBackPressed(_ sender: UIBarButtonItem) {
        webController?.goBack()
    }
    
    @IBAction func onForwardPressed(_ sender: UIBarButtonItem) {
        webController?.goForward()
    }
    
    @IBAction func onOpenInSafari(_ sender: UIBarButtonItem) {
        if let url = webController?.url {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func onSharePressed(_ sender: UIBarButtonItem) {
        if let url = webController?.url {
            presentShareSheetFromButton(activityItems: [url], buttonItem: sender)
        }
    }
    
    @IBAction func onDeleteEverything(_ sender: UIBarButtonItem) {
        webController?.reset()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? WebViewController {
            controller.loadingDelegate = self
            webController = controller
        }
    }
}
