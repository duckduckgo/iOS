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
    
    @IBOutlet weak var passiveContainerView: UIView!
    @IBOutlet weak var centreBar: UIView!
    
    weak var tabDelegate: HomeTabDelegate?
    
    let omniBarStyle: OmniBar.Style = .home
    let showsUrlInOmniBar = false
    
    var name: String? = UserText.homeLinkTitle
    var url: URL? = URL(string: AppUrls.base)!
    
    var canGoBack = false
    var canGoForward: Bool = false
    
    private var activeMode = false

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
        navigationController?.isToolbarHidden = true
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
        enterActiveMode()
    }
    
    @IBAction func onEnterPassiveModeTapped(_ sender: Any) {
        enterPassiveMode()
    }
    
    @IBAction func onTabButtonTapped(_ sender: UIButton) {
        tabDelegate?.homeTabDidRequestTabsSwitcher(homeTab: self)
    }
    
    func enterPassiveMode() {
        navigationController?.isNavigationBarHidden = true
        passiveContainerView.isHidden = false
        tabDelegate?.homeTabDidDeactivateOmniBar(homeTab: self)
    }
    
    func enterActiveMode() {
        navigationController?.isNavigationBarHidden = false
        passiveContainerView.isHidden = true
        tabDelegate?.homeTabDidActivateOmniBar(homeTab: self)
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
