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
    
    @IBOutlet weak var ctaContainerBottom: NSLayoutConstraint!
    @IBOutlet weak var ctaContainer: UIView!

    @IBOutlet weak var collectionView: HomeCollectionView!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var daxDialogContainer: UIView!
    @IBOutlet weak var daxDialogContainerHeight: NSLayoutConstraint!
    weak var daxDialogViewController: DaxDialogViewController?
    
    var logoContainer: UIView! {
        return delegate?.homeDidRequestLogoContainer(self)
    }
 
    var searchHeaderTransition: CGFloat = 0.0 {
        didSet {
            let percent = searchHeaderTransition > 0.99 ? searchHeaderTransition : 0.0

            // hide the keyboard if transitioning away
            if oldValue == 1.0 && searchHeaderTransition != 1.0 {
                chromeDelegate?.omniBar.resignFirstResponder()
            }
            
            delegate?.home(self, searchTransitionUpdated: percent)
            chromeDelegate?.omniBar.alpha = percent
            chromeDelegate?.tabsBar.alpha = percent
        }
    }
    
    weak var delegate: HomeControllerDelegate?
    weak var chromeDelegate: BrowserChromeDelegate?
    
    private var viewHasAppeared = false
    private var defaultVerticalAlignConstant: CGFloat = 0
    
    private(set) var tabModel: Tab
    
    static func loadFromStoryboard(model: Tab) -> HomeViewController {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
            fatalError("Failed to instantiate correct view controller for Home")
        }
        controller.tabModel = model
        return controller
    }
    
    required init?(coder aDecoder: NSCoder) {
        tabModel = Tab(link: nil)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.onKeyboardChangeFrame),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        configureCollectionView()
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    func configureCollectionView() {
        collectionView.configure(withController: self, andTheme: ThemeManager.shared.currentTheme)
    }
    
    func enableContentUnderflow() -> CGFloat {
        return delegate?.home(self, didRequestContentOverflow: true) ?? 0
    }
    
    @discardableResult
    func disableContentUnderflow() -> CGFloat {
        return delegate?.home(self, didRequestContentOverflow: false) ?? 0
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.collectionView.viewDidTransition(to: size)
        })
    }

    func refresh() {
        collectionView.reloadData()
    }
    
    func omniBarCancelPressed() {
        collectionView.omniBarCancelPressed()
    }
    
    func openedAsNewTab() {
        collectionView.openedAsNewTab()
        showNextDaxDialog()
    }
    
    @IBAction func launchSettings() {
        delegate?.showSettings(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if presentedViewController == nil { // prevents these being called when settings forces this controller to be reattached
            showNextDaxDialog()
            Pixel.fire(pixel: .homeScreenShown)
            
            if collectionView.isShowingHomeMessage(.defaultBrowserPrompt) {
                Pixel.fire(pixel: .defaultBrowserHomeMessageShown)
            }
        }
                
        viewHasAppeared = true
        tabModel.viewed = true
    }
    
    var isShowingDax: Bool {
        return !daxDialogContainer.isHidden
    }
        
    func showNextDaxDialog() {

        guard !isShowingDax else { return }
        guard let spec = DaxDialogs.shared.nextHomeScreenMessage() else { return }
        collectionView.isHidden = true
        daxDialogContainer.isHidden = false
        daxDialogContainer.alpha = 0.0
        daxDialogViewController?.loadViewIfNeeded()
        daxDialogViewController?.message = spec.message
        daxDialogViewController?.accessibleMessage = spec.accessibilityLabel
        daxDialogContainerHeight.constant = daxDialogViewController?.calculateHeight() ?? 0
        hideLogo()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.4, animations: {
                self.daxDialogContainer.alpha = 1.0
            }, completion: { _ in
                self.daxDialogViewController?.start()
            })
        }

        configureCollectionView()
    }

    func hideLogo() {
        delegate?.home(self, didRequestHideLogo: true)
    }
    
    func onboardingCompleted() {
        showNextDaxDialog()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.destination is DaxDialogViewController {
            self.daxDialogViewController = segue.destination as? DaxDialogViewController
        }
        
    }

    @IBAction func hideKeyboard() {
        // without this the keyboard hides instantly and abruptly
        UIView.animate(withDuration: 0.5) {
            self.chromeDelegate?.omniBar.resignFirstResponder()
        }
    }

    @objc func onKeyboardChangeFrame(notification: NSNotification) {
        guard let beginFrame = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect else { return }
        guard let endFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

        let diff = beginFrame.origin.y - endFrame.origin.y

        if diff > 0 {
            ctaContainerBottom.constant = endFrame.size.height - (chromeDelegate?.toolbarHeight ?? 0)
        } else {
            ctaContainerBottom.constant = 0
        }

        view.setNeedsUpdateConstraints()

        if viewHasAppeared {
            UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
        }
    }

    func load(url: URL) {
        delegate?.home(self, didRequestUrl: url)
    }

    func dismiss() {
        delegate = nil
        chromeDelegate = nil
        removeFromParent()
        view.removeFromSuperview()
    }
    
    func launchNewSearch() {
        collectionView.launchNewSearch()
    }
}

extension HomeViewController: FavoritesHomeViewSectionRendererDelegate {
    
    func favoritesRenderer(_ renderer: FavoritesHomeViewSectionRenderer, didSelect link: Link) {
        Pixel.fire(pixel: .homeScreenFavouriteLaunched)
        Favicons.shared.loadFavicon(forDomain: link.url.host, intoCache: .bookmarks, fromCache: .tabs)
        delegate?.home(self, didRequestUrl: link.url)
    }

}

extension HomeViewController: HomeMessageViewSectionRendererDelegate {
    
    func homeMessageRenderer(_ renderer: HomeMessageViewSectionRenderer, didDismissHomeMessage homeMessage: HomeMessage) {
        refresh()
    }
}

extension HomeViewController: Themable {

    func decorate(with theme: Theme) {
        collectionView.decorate(with: theme)
        settingsButton.tintColor = theme.barTintColor
    }
}
