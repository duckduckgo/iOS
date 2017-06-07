//
//  HomeViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 27/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class HomeViewController: UIViewController {
    
    private struct Constants {
        static let animationDuration = 0.25
    }
    
    @IBOutlet weak var passiveContent: UIView!
    @IBOutlet weak var searchBar: UIView!
    @IBOutlet weak var searchBarContent: UIView!
    @IBOutlet weak var searchImage: UIImageView!
    @IBOutlet weak var searchText: UILabel!
    
    weak var delegate: HomeControllerDelegate?
    
    private lazy var tabIconMaker = TabIconMaker()
    
    static func loadFromStoryboard() -> HomeViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resetNavigationBar()
        refreshMode(active: false)
        super.viewWillAppear(animated)
    }
    
    private func resetNavigationBar() {
        navigationController?.isNavigationBarHidden = true
        navigationController?.isToolbarHidden = false
        navigationController?.hidesBarsOnSwipe = false
    }
    
    public func refreshMode(active: Bool) {
        if active {
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
        delegate?.homeControllerDidDeactivateOmniBar(homeController: self)
    }
    
    func enterActiveMode() {
        navigationController?.isNavigationBarHidden = false
        passiveContent.isHidden = true
        delegate?.homeControllerDidActivateOmniBar(homeController: self)
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
        delegate?.homeController(self, didRequestUrl: url)
    }

    func dismiss() {
        removeFromParentViewController()
        view.removeFromSuperview()
    }
}
