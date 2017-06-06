//
//  HomeTabViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 27/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class HomeTabViewController: UIViewController, Tab {
    
    private struct Constants {
        static let animationDuration = 0.25
    }
    
    @IBOutlet weak var passiveContent: UIView!
    @IBOutlet weak var searchBar: UIView!
    @IBOutlet weak var searchBarContent: UIView!
    @IBOutlet weak var searchImage: UIImageView!
    @IBOutlet weak var searchText: UILabel!
    
    weak var tabDelegate: HomeTabDelegate?
    
    let showsUrlInOmniBar = false
    
    var name: String? = UserText.homeLinkTitle
    var url: URL? = AppUrls.base
    var favicon: URL? = AppUrls.favicon
    
    var canGoBack = false
    var canGoForward = false
    var canShare = false
    
    private var activeMode = false
    private lazy var tabIconMaker = TabIconMaker()
    
    static func loadFromStoryboard() -> HomeTabViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeTabViewController") as! HomeTabViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resetNavigationBar()
        activeMode = false
        refreshMode()
        super.viewWillAppear(animated)
    }
    
    private func resetNavigationBar() {
        navigationController?.isNavigationBarHidden = true
        navigationController?.isToolbarHidden = false
        navigationController?.hidesBarsOnSwipe = false
    }
    
    private func refreshMode() {
        if activeMode {
            enterActiveMode()
        } else {
            enterPassiveMode()
        }
    }
    
    @IBAction func onEnterActiveModeTapped(_ sender: Any) {
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.moveSearchBarUp()
        }) { (finished) in
            self.enterActiveMode()
        }
    }
    
    @IBAction func onEnterPassiveModeTapped(_ sender: Any) {
        enterPassiveMode()
        UIView.animate(withDuration: Constants.animationDuration) {
            self.resetSearchBar()
        }
    }
    
    func enterPassiveMode() {
        navigationController?.isNavigationBarHidden = true
        passiveContent.isHidden = false
        tabDelegate?.homeTabDidDeactivateOmniBar(homeTab: self)
    }
    
    func enterActiveMode() {
        navigationController?.isNavigationBarHidden = false
        passiveContent.isHidden = true
        tabDelegate?.homeTabDidActivateOmniBar(homeTab: self)
    }
    
    private func moveSearchBarUp() {
        let frame = searchBar.superview!.convert(searchBar.frame.origin, to: passiveContent)
        let xScale = OmniBar.Measurement.width / searchBar.frame.size.width
        let yScale = OmniBar.Measurement.height / searchBar.frame.size.height
        let xIdentityScale = searchBar.frame.size.width / OmniBar.Measurement.width
        let yIdentityScale = searchBar.frame.size.height / OmniBar.Measurement.height
        let searchBarToOmniTextRatio: CGFloat = 0.875
        let searchTextMarginChange: CGFloat = -12
        passiveContent.transform.ty = statusBarSize - frame.y
        searchBar.transform = CGAffineTransform(scaleX: xScale, y: yScale)
        searchBarContent.transform = CGAffineTransform(scaleX: xIdentityScale, y: yIdentityScale)
        searchText.transform = CGAffineTransform(scaleX: searchBarToOmniTextRatio, y: searchBarToOmniTextRatio)
        searchText.transform.tx = searchTextMarginChange
        searchImage.alpha = 0
    }
    
    private func resetSearchBar() {
        passiveContent.transform = CGAffineTransform.identity
        searchBar.transform = CGAffineTransform.identity
        searchBarContent.transform = CGAffineTransform.identity
        searchText.transform = CGAffineTransform.identity
        searchImage.alpha = 1
    }
    
    func load(url: URL) {
        tabDelegate?.homeTab(self, didRequestUrl: url)
    }
    
    func goBack() {}
    
    func goForward() {}
    
    func reload() {}
    
    func dismiss() {
        removeFromParentViewController()
        view.removeFromSuperview()
    }
    
    func destroy() {
        dismiss()
    }
    
    func omniBarWasDismissed() {
        enterPassiveMode()
    }
}
