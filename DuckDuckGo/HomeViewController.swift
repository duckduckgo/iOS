//
//  HomeViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 27/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var passiveContainerView: UIView!

    @IBOutlet weak var centreBar: UIView!
    private var omniBar: OmniBar!
    private var activeMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureOmniBar()
    }
    
    private func configureOmniBar() {
        omniBar = OmniBar.loadFromXib(withStyle: .home)
        omniBar.omniDelegate = self
        navigationItem.titleView = omniBar
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
    
    public func loadBrowserQuery(query: String) {
        let controller = UIStoryboard(name: "Browser", bundle: nil).instantiateInitialViewController() as! BrowserViewController
        controller.load(query: query)
        show(controller, sender: nil)
    }
    
    public func loadBrowserUrl(url: URL) {
        let controller = UIStoryboard(name: "Browser", bundle: nil).instantiateInitialViewController() as! BrowserViewController
        controller.load(url: url)
        show(controller, sender: nil)
    }
    
    
    private func openSafariHelp() {
        let controller = UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController() as! SettingsViewController
        show(controller, sender: nil)
    }
}

extension HomeViewController: OmniBarDelegate {
    func onOmniQuerySubmitted(_ query: String) {
        loadBrowserQuery(query: query)
    }
    
    func onLeftButtonPressed() {
        enterPassiveMode()
    }
    
    func onRightButtonPressed() {
    }
}
