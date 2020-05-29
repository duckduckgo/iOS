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
    var daxDialogSpecToShow: DaxOnboarding.HomeScreenSpec?
    
    var statusBarBackground: UIView? {
        return (parent as? MainViewController)?.statusBarBackground
    }

    var navigationBar: UIView? {
        return (parent as? MainViewController)?.customNavigationBar
    }
    
    var bottomOffset: CGFloat {
        // doesn't take in to account extra space on iPhone X but is good enough to show the bottom items in the collection view
        return ((parent as? MainViewController)?.toolbar.frame.height ?? 0)
    }

    var searchHeaderTransition: CGFloat = 0.0 {
        didSet {
            let percent = searchHeaderTransition > 0.99 ? searchHeaderTransition : 0.0
            
            // hide the keyboard if transitioning away
            if oldValue == 1.0 && searchHeaderTransition != 1.0 {
                chromeDelegate?.omniBar.resignFirstResponder()
            }
            
            statusBarBackground?.alpha = percent
            chromeDelegate?.omniBar.alpha = percent
            navigationBar?.alpha = percent
        }
    }

    var logoContainer: UIView? {
        return (parent as? MainViewController)?.logoContainer
    }
    
    var logo: UIImageView? {
        return (parent as? MainViewController)?.logo
    }
    
    weak var delegate: HomeControllerDelegate?
    weak var chromeDelegate: BrowserChromeDelegate?
    
    private var viewHasAppeared = false
    private var defaultVerticalAlignConstant: CGFloat = 0
    
    static func loadFromStoryboard() -> HomeViewController {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
            fatalError("Failed to instantiate correct view controller for Home")
        }
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.onKeyboardChangeFrame),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        collectionView.configure(withController: self, andTheme: ThemeManager.shared.currentTheme)
        applyTheme(ThemeManager.shared.currentTheme)
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
    
    func remove(_ renderer: ExtraContentHomeSectionRenderer) {
        if let section = collectionView.renderers.remove(renderer: renderer) {
            collectionView.performBatchUpdates({
                collectionView.deleteSections(IndexSet(integer: section))
            }, completion: nil)
        }
    }
    
    func omniBarCancelPressed() {
        collectionView.omniBarCancelPressed()
    }
    
    func openedAsNewTab() {
        collectionView.openedAsNewTab()
    }
    
    @IBAction func launchSettings() {
        delegate?.showSettings(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if presentedViewController == nil { // prevents these being called when settings forces this controller to be reattached
            Pixel.fire(pixel: .homeScreenShown)
            installHomeScreenTips()
        }
        
        viewHasAppeared = true
    }
        
    func installHomeScreenTips() {
        let variantManager = DefaultVariantManager()
        if variantManager.isSupported(feature: .daxOnboarding) {
            daxDialogSpecToShow = DaxOnboarding().nextHomeScreenMessage()
            showNextDaxDialog()
        } else {
            HomeScreenTips(delegate: self)?.trigger()
        }
    }
    
    func showNextDaxDialog() {
        guard let spec = daxDialogSpecToShow else { return }
        collectionView.isHidden = true
        logoContainer?.isHidden = true
        daxDialogContainer.isHidden = false
        daxDialogContainer.alpha = 0.0
        daxDialogContainerHeight.constant = spec.height
        daxDialogViewController?.message = spec.message
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.4, animations: {
                self.daxDialogContainer.alpha = 1.0
            }, completion: { _ in
                self.daxDialogViewController?.start()
            })
        }
        
    }

    func onboardingCompleted() {
        installHomeScreenTips()
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
        delegate?.home(self, didRequestUrl: link.url)
    }

}

extension HomeViewController: Themable {

    func decorate(with theme: Theme) {
        collectionView.decorate(with: theme)
        view.backgroundColor = theme.backgroundColor
        settingsButton.tintColor = theme.barTintColor
    }
}
