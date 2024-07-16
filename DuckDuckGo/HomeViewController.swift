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
import RemoteMessaging
import SwiftUI
import BrowserServicesKit

class HomeViewController: UIViewController, NewTabPage {

    @IBOutlet weak var ctaContainerBottom: NSLayoutConstraint!
    @IBOutlet weak var ctaContainer: UIView!

    @IBOutlet weak var collectionView: HomeCollectionView!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var daxDialogContainer: UIView!
    @IBOutlet weak var daxDialogContainerHeight: NSLayoutConstraint!
    weak var daxDialogViewController: DaxDialogViewController?
    var hostingController: UIHostingController<AnyView>?

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

    var isDragging: Bool {
        collectionView.isDragging
    }

    weak var delegate: HomeControllerDelegate?
    weak var chromeDelegate: BrowserChromeDelegate?

    private var viewHasAppeared = false
    private var defaultVerticalAlignConstant: CGFloat = 0
    
    private let homePageConfiguration: HomePageConfiguration
    private let tabModel: Tab
    private let favoritesViewModel: FavoritesListInteracting
    private let appSettings: AppSettings
    private let syncService: DDGSyncing
    private let syncDataProviders: SyncDataProviders
    private let variantManager: VariantManager
    private let newTabDialogFactory: any NewTabDaxDialogProvider
    private let newTabDialogTypeProvider: NewTabDialogSpecProvider
    private var viewModelCancellable: AnyCancellable?
    private var favoritesDisplayModeCancellable: AnyCancellable?

    static func loadFromStoryboard(
        homePageDependecies: HomePageDependencies
    ) -> HomeViewController {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "HomeViewController", creator: { coder in
            HomeViewController(
                coder: coder,
                homePageConfiguration: homePageDependecies.homePageConfiguration,
                tabModel: homePageDependecies.model,
                favoritesViewModel: homePageDependecies.favoritesViewModel,
                appSettings: homePageDependecies.appSettings,
                syncService: homePageDependecies.syncService,
                syncDataProviders: homePageDependecies.syncDataProviders,
                variantManager: homePageDependecies.variantManager,
                newTabDialogFactory: homePageDependecies.newTabDialogFactory,
                newTabDialogTypeProvider: homePageDependecies.newTabDialogTypeProvider
            )
        })
        return controller
    }

    required init?(
        coder: NSCoder,
        homePageConfiguration: HomePageConfiguration,
        tabModel: Tab,
        favoritesViewModel: FavoritesListInteracting,
        appSettings: AppSettings,
        syncService: DDGSyncing,
        syncDataProviders: SyncDataProviders,
        variantManager: VariantManager,
        newTabDialogFactory: any NewTabDaxDialogProvider,
        newTabDialogTypeProvider: NewTabDialogSpecProvider
    ) {
        self.homePageConfiguration = homePageConfiguration
        self.tabModel = tabModel
        self.favoritesViewModel = favoritesViewModel
        self.appSettings = appSettings
        self.syncService = syncService
        self.syncDataProviders = syncDataProviders
        self.variantManager = variantManager
        self.newTabDialogFactory = newTabDialogFactory
        self.newTabDialogTypeProvider = newTabDialogTypeProvider

        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.onKeyboardChangeFrame),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        collectionView.homePageConfiguration = homePageConfiguration
        configureCollectionView()
        decorate()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(remoteMessagesDidChange),
                                               name: RemoteMessagingStore.Notifications.remoteMessagesDidChange,
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
        DispatchQueue.main.async {
            os_log("Remote messages did change", log: .remoteMessaging, type: .info)
            self.collectionView.refreshHomeConfiguration()
            self.refresh()
        }
    }

    func configureCollectionView() {
        collectionView.configure(withController: self, favoritesViewModel: favoritesViewModel)
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
        presentNextDaxDialog()
    }
    
    @IBAction func launchSettings() {
        delegate?.showSettings(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // If there's no tab switcher then this will be true, if there is a tabswitcher then only allow the
        //  stuff below to happen if it's being dismissed
        guard presentedViewController?.isBeingDismissed ?? true else { return }

        Pixel.fire(pixel: .homeScreenShown)
        sendDailyDisplayPixel()

        presentNextDaxDialog()

        collectionView.didAppear()

        viewHasAppeared = true
        tabModel.viewed = true
    }
    
    var isShowingDax: Bool {
        return !daxDialogContainer.isHidden
    }

    func hideLogo() {
        delegate?.home(self, didRequestHideLogo: true)
    }
    
    func onboardingCompleted() {
        presentNextDaxDialog()
    }

    func presentNextDaxDialog() {
        if variantManager.isSupported(feature: .newOnboardingIntro) {
            showNextDaxDialogNew(dialogProvider: newTabDialogTypeProvider, factory: newTabDialogFactory)
        } else {
            showNextDaxDialog(dialogProvider: newTabDialogTypeProvider)
        }
    }

    func showNextDaxDialog() {
        showNextDaxDialog(dialogProvider: newTabDialogTypeProvider)
    }

    func reloadFavorites() {
        collectionView.reloadData()
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

private extension HomeViewController {
    func sendDailyDisplayPixel() {

        let favoritesCount = favoritesViewModel.favorites.count
        let bucket = HomePageDisplayDailyPixelBucket(favoritesCount: favoritesCount)

        DailyPixel.fire(pixel: .newTabPageDisplayedDaily, withAdditionalParameters: ["FavoriteCount": bucket.value])
    }
}

extension HomeViewController: FavoritesHomeViewSectionRendererDelegate {
    
    func favoritesRenderer(_ renderer: FavoritesHomeViewSectionRenderer, didSelect favorite: BookmarkEntity) {
        guard let url = favorite.urlObject else { return }
        Pixel.fire(pixel: .favoriteLaunchedNTP)
        DailyPixel.fire(pixel: .favoriteLaunchedNTPDaily)
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

extension HomeViewController {

    private func decorate() {
        let theme = ThemeManager.shared.currentTheme
        settingsButton.tintColor = theme.barTintColor
    }
}
