//
//  HomeViewController.swift
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
import Core

class HomeViewController: UIViewController {
    
    private struct Constants {
        static let animationDuration = 0.25
        static let minHeightForSafariButton: CGFloat = 500
    }
    
    @IBOutlet weak var passiveContent: UIView!
    @IBOutlet weak var searchBar: UIView!
    @IBOutlet weak var searchBarContent: UIView!
    @IBOutlet weak var searchImage: UIImageView!
    @IBOutlet weak var searchText: UILabel!
    
    weak var delegate: HomeControllerDelegate?
    weak var chromeDelegate: BrowserChromeDelegate?
    private var active = false
    
    static func loadFromStoryboard(active: Bool) -> HomeViewController {
        let controller = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        controller.active = active
        return controller
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if active {
            enterActiveMode()
        } else {
            enterPassiveMode()
        }
    }
    
    @IBAction func onEnterActiveModeTapped(_ sender: Any) {
         enterActiveModeAnimated()
    }
    
    private func enterActiveModeAnimated() {
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.moveSearchBarUp()
        }, completion: { _ in
            self.enterActiveMode()
        })
    }
    
    private func enterActiveMode() {
        chromeDelegate?.setNavigationBarHidden(false)
        passiveContent.isHidden = true
        delegate?.homeDidActivateOmniBar(home: self)
    }

    @IBAction func onEnterPassiveModeTapped(_ sender: Any) {
        enterPassiveModeAnimated()
    }
    
    private func enterPassiveModeAnimated() {
        chromeDelegate?.setNavigationBarHidden(true)
        passiveContent.isHidden = false
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.resetSearchBar()
        }, completion: { _ in
            self.enterPassiveMode()
        })
    }
    
    private func enterPassiveMode() {
        chromeDelegate?.setNavigationBarHidden(true)
        passiveContent.isHidden = false
        delegate?.homeDidDeactivateOmniBar(home: self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    }
    
    private func moveSearchBarUp() {
        guard let omniSearch = chromeDelegate?.omniBar.searchContainer else { return }
        guard let convertedOrigin = searchBar.superview?.convert(searchBar.frame.origin, to: passiveContent) else { return }
        
        let xScale = omniSearch.frame.size.width / searchBar.frame.size.width
        let yScale = omniSearch.frame.size.height / searchBar.frame.size.height
        let xIdentityScale = searchBar.frame.size.width / omniSearch.frame.size.width
        let yIdentityScale = searchBar.frame.size.height / omniSearch.frame.size.height
        let searchBarToOmniTextRatio: CGFloat = 0.875
        let searchTextMarginChange: CGFloat = -12
        passiveContent.transform.ty = -convertedOrigin.y
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
        delegate?.home(self, didRequestUrl: url)
    }
    
    func omniBarWasDismissed() {
        enterPassiveModeAnimated()
    }

    func dismiss() {
        delegate = nil
        chromeDelegate = nil
        removeFromParentViewController()
        view.removeFromSuperview()
    }
}
