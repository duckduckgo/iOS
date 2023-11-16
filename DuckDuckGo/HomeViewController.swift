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
import Bookmarks
import Combine
import Common
import DDGSync
import Persistence

// swiftlint:disable file_length

// swiftlint:disable:next type_body_length
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
            chromeDelegate?.tabBarContainer.alpha = percent
        }
    }
    
    weak var delegate: HomeControllerDelegate?
    weak var chromeDelegate: BrowserChromeDelegate?
    
    private var viewHasAppeared = false
    private var defaultVerticalAlignConstant: CGFloat = 0
    
    private let tabModel: Tab
    private let favoritesViewModel: FavoritesListInteracting
    private let appSettings: AppSettings
    private let syncService: DDGSyncing
    private let syncDataProviders: SyncDataProviders
    private var viewModelCancellable: AnyCancellable?
    private var favoritesDisplayModeCancellable: AnyCancellable?

#if APP_TRACKING_PROTECTION
    private let appTPHomeViewModel: AppTPHomeViewModel
#endif

#if APP_TRACKING_PROTECTION
    // swiftlint:disable:next function_parameter_count
    static func loadFromStoryboard(
        model: Tab,
        favoritesViewModel: FavoritesListInteracting,
        appSettings: AppSettings,
        syncService: DDGSyncing,
        syncDataProviders: SyncDataProviders,
        appTPDatabase: CoreDataDatabase
    ) -> HomeViewController {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "HomeViewController", creator: { coder in
            HomeViewController(
                coder: coder,
                tabModel: model,
                favoritesViewModel: favoritesViewModel,
                appSettings: appSettings,
                syncService: syncService,
                syncDataProviders: syncDataProviders,
                appTPDatabase: appTPDatabase
            )
        })
        return controller
    }
#else
    static func loadFromStoryboard(
        model: Tab,
        favoritesViewModel: FavoritesListInteracting,
        appSettings: AppSettings,
        syncService: DDGSyncing,
        syncDataProviders: SyncDataProviders
    ) -> HomeViewController {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "HomeViewController", creator: { coder in
            HomeViewController(
                coder: coder,
                tabModel: model,
                favoritesViewModel: favoritesViewModel,
                appSettings: appSettings,
                syncService: syncService,
                syncDataProviders: syncDataProviders
            )
        })
        return controller
    }
#endif

#if APP_TRACKING_PROTECTION
    required init?(
        coder: NSCoder,
        tabModel: Tab,
        favoritesViewModel: FavoritesListInteracting,
        appSettings: AppSettings,
        syncService: DDGSyncing,
        syncDataProviders: SyncDataProviders,
        appTPDatabase: CoreDataDatabase
    ) {
        self.tabModel = tabModel
        self.favoritesViewModel = favoritesViewModel
        self.appSettings = appSettings
        self.syncService = syncService
        self.syncDataProviders = syncDataProviders

        self.appTPHomeViewModel = AppTPHomeViewModel(appTrackingProtectionDatabase: appTPDatabase)

        super.init(coder: coder)
    }
#else
    required init?(
        coder: NSCoder,
        tabModel: Tab,
        favoritesViewModel: FavoritesListInteracting,
        appSettings: AppSettings,
        syncService: DDGSyncing,
        syncDataProviders: SyncDataProviders
    ) {
        self.tabModel = tabModel
        self.favoritesViewModel = favoritesViewModel
        self.appSettings = appSettings
        self.syncService = syncService
        self.syncDataProviders = syncDataProviders

        super.init(coder: coder)
    }
#endif

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.onKeyboardChangeFrame),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        configureCollectionView()
        applyTheme(ThemeManager.shared.currentTheme)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(remoteMessagesDidChange),
                                               name: RemoteMessaging.Notifications.remoteMessagesDidChange,
                                               object: nil)

        registerForBookmarksChanges()
    }

    private func registerForBookmarksChanges() {
        viewModelCancellable = favoritesViewModel.externalUpdates.sink { [weak self] _ in
            guard let self = self else { return }
            self.bookmarksDidChange()
            if self.favoritesViewModel.favorites.isEmpty {
                self.delegate?.home(self, didRequestHideLogo: false)
            }
        }

        favoritesDisplayModeCancellable = NotificationCenter.default.publisher(for: AppUserDefaults.Notifications.favoritesDisplayModeChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                self.favoritesViewModel.favoritesDisplayMode = self.appSettings.favoritesDisplayMode
                self.collectionView.reloadData()
            }
    }
    
    @objc func bookmarksDidChange() {
        configureCollectionView()
    }
    
    @objc func remoteMessagesDidChange() {
        os_log("Remote messages did change", log: .remoteMessaging, type: .info)
        collectionView.refreshHomeConfiguration()
        refresh()
    }

    func configureCollectionView() {
#if APP_TRACKING_PROTECTION
        collectionView.configure(withController: self,
                                 favoritesViewModel: favoritesViewModel,
                                 appTPHomeViewModel: appTPHomeViewModel,
                                 andTheme: ThemeManager.shared.currentTheme)
#else
        collectionView.configure(withController: self,
                                 favoritesViewModel: favoritesViewModel,
                                 appTPHomeViewModel: nil,
                                 andTheme: ThemeManager.shared.currentTheme)
#endif
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
        self.collectionView.collectionViewLayout.invalidateLayout()
    }

    func refresh() {
        collectionView.reloadData()
    }
    
    func omniBarCancelPressed() {
        collectionView.omniBarCancelPressed()
    }
    
    func openedAsNewTab(allowingKeyboard: Bool) {
        collectionView.openedAsNewTab(allowingKeyboard: allowingKeyboard)
        showNextDaxDialog()
    }
    
    @IBAction func launchSettings() {
        delegate?.showSettings(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if presentedViewController == nil { // prevents these being called when settings forces this controller to be reattached
            showNextDaxDialog()
        }

        Pixel.fire(pixel: .homeScreenShown)
        collectionView.didAppear()

        viewHasAppeared = true
        tabModel.viewed = true
    }
    
    var isShowingDax: Bool {
        return !daxDialogContainer.isHidden
    }
        
    func showNextDaxDialog() {

        guard !isShowingDax else { return }
        guard let spec = DaxDialogs.shared.nextHomeScreenMessage(),
              let daxDialogViewController = daxDialogViewController else { return }
        collectionView.isHidden = true
        daxDialogContainer.isHidden = false
        daxDialogContainer.alpha = 0.0
        
        daxDialogViewController.loadViewIfNeeded()
        daxDialogViewController.message = spec.message
        daxDialogViewController.accessibleMessage = spec.accessibilityLabel
        
        view.addGestureRecognizer(daxDialogViewController.tapToCompleteGestureRecognizer)
        
        daxDialogContainerHeight.constant = daxDialogViewController.calculateHeight()
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

    private(set) lazy var faviconsFetcherOnboarding: FaviconsFetcherOnboarding =
        .init(syncService: syncService, syncBookmarksAdapter: syncDataProviders.bookmarksAdapter)
}

extension HomeViewController: FavoritesHomeViewSectionRendererDelegate {
    
    func favoritesRenderer(_ renderer: FavoritesHomeViewSectionRenderer, didSelect favorite: BookmarkEntity) {
        guard let url = favorite.urlObject else { return }
        Pixel.fire(pixel: .homeScreenFavouriteLaunched)
        Favicons.shared.loadFavicon(forDomain: url.host, intoCache: .fireproof, fromCache: .tabs)
        delegate?.home(self, didRequestUrl: url)
    }
    
    func favoritesRenderer(_ renderer: FavoritesHomeViewSectionRenderer, didRequestEdit favorite: BookmarkEntity) {
        delegate?.home(self, didRequestEdit: favorite)
    }

    func favoritesRenderer(_ renderer: FavoritesHomeViewSectionRenderer, favoriteDeleted favorite: BookmarkEntity) {
        delegate?.home(self, didRequestHideLogo: renderer.viewModel.favorites.count > 0)
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
