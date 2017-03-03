//
//  HomeViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 27/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class HomeViewController: UIViewController, Tab {
    
    @IBOutlet weak var passiveContainerView: UIView!
    @IBOutlet weak var centreBar: UIView!
    
    weak var tabDelegate: HomeTabDelegate?
    var omniBar: OmniBar
    var name: String? = UserText.homeLinkTitle
    var url: URL? = URL(string: AppUrls.base)!
    var canGoBack = false
    var canGoForward: Bool = false
    
    private var activeMode = false

    static func loadFromStoryboard() -> HomeViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.omniBar = OmniBar.loadFromXib(withStyle: .home)
        super.init(coder: aDecoder)
        omniBar.omniDelegate = self
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
        tabDelegate?.launchTabsSwitcher()
    }
    
    fileprivate func enterPassiveMode() {
        navigationController?.isNavigationBarHidden = true
        passiveContainerView.isHidden = false
        _ = omniBar.resignFirstResponder()
        omniBar.clear()
    }
    
    fileprivate func enterActiveMode() {
        navigationController?.isNavigationBarHidden = false
        passiveContainerView.isHidden = true
        _ = omniBar.becomeFirstResponder()
    }
    
    func load(url: URL) {}
    
    func refreshOmniText() {}
    
    func goBack() {}
    
    func goForward() {}
    
    func clear() {
        removeFromParentViewController()
        view.removeFromSuperview()
    }
}

extension HomeViewController: OmniBarDelegate {
    
    func onOmniQuerySubmitted(_ query: String) {
        tabDelegate?.loadNewWebQuery(query: query)
    }
    
    func onLeftButtonPressed() {
        enterPassiveMode()
    }
    
    func onRightButtonPressed() {
    }
}
