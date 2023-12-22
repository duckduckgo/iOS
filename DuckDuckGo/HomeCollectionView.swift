//
//  HomeCollectionView.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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
import Bookmarks
import Persistence

class HomeCollectionView: UICollectionView {
    
    struct Constants {
        static let topInset: CGFloat = 79
    }
    
    private weak var controller: HomeViewController!
    
    private(set) var renderers: HomeViewSectionRenderers!
    
    private lazy var collectionViewReorderingGesture =
        UILongPressGestureRecognizer(target: self, action: #selector(self.collectionViewReorderingGestureHandler(gesture:)))
    
    private lazy var homePageConfiguration = AppDependencyProvider.shared.homePageConfiguration
    
    private var topIndexPath: IndexPath? {
        for section in 0..<renderers.numberOfSections(in: self) where numberOfItems(inSection: section) > 0 {
            return IndexPath(row: 0, section: section)
        }
        return nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        register(UINib(nibName: "FavoriteHomeCell", bundle: nil),
                 forCellWithReuseIdentifier: "favorite")
        register(UINib(nibName: "HomeMessageCell", bundle: nil),
                 forCellWithReuseIdentifier: "homeMessageCell")
        
        register(HomeMessageCollectionViewCell.self, forCellWithReuseIdentifier: "HomeMessageCell")

#if APP_TRACKING_PROTECTION
        register(AppTPCollectionViewCell.self, forCellWithReuseIdentifier: "AppTPHomeCell")
#endif
        
        register(EmptyCollectionReusableView.self,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                 withReuseIdentifier: EmptyCollectionReusableView.reuseIdentifier)
        register(EmptyCollectionReusableView.self,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                 withReuseIdentifier: EmptyCollectionReusableView.reuseIdentifier)
        
        contentInset = UIEdgeInsets(top: Constants.topInset, left: 0, bottom: 0, right: 0)
    }
    
    deinit {
        UIMenuController.shared.hideMenu()
    }
    
    func configure(withController controller: HomeViewController,
                   favoritesViewModel: FavoritesListInteracting,
                   appTPHomeViewModel: AnyObject?, // Set to AnyObject so that AppTP can be disabled easily
                   andTheme theme: Theme) {
        self.controller = controller
        renderers = HomeViewSectionRenderers(controller: controller, theme: theme)
        
        homePageConfiguration.components(favoritesViewModel: favoritesViewModel).forEach { component in
            switch component {
            case .navigationBarSearch(let fixed):
                renderers.install(renderer: NavigationSearchHomeViewSectionRenderer(fixed: fixed))
                
            case .favorites:
                let renderer = FavoritesHomeViewSectionRenderer(viewModel: favoritesViewModel)
                renderer.onFaviconMissing = { _ in
                    controller.faviconsFetcherOnboarding.presentOnboardingIfNeeded(from: controller)
                }
                renderers.install(renderer: renderer)

            case .homeMessage:
                renderers.install(renderer: HomeMessageViewSectionRenderer(homePageConfiguration: homePageConfiguration))

            case .appTrackingProtection:
#if APP_TRACKING_PROTECTION
                if let viewModel = appTPHomeViewModel as? AppTPHomeViewModel {
                    renderers.install(renderer: AppTPHomeViewSectionRenderer(appTPHomeViewModel: viewModel))
                } else {
                    fatalError("Failed to cast AppTP home view model to expected class")
                }
#else
                break
#endif
            }

        }
        
        dataSource = renderers
        delegate = renderers
        dropDelegate = renderers
        dragDelegate = renderers

        collectionViewReorderingGesture.delegate = self
        addGestureRecognizer(collectionViewReorderingGesture)
    }
    
    func launchNewSearch() {
        renderers.launchNewSearch()
    }

    func didAppear() {
        renderers.didAppear()
    }
 
    @objc func collectionViewReorderingGestureHandler(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            if let indexPath = indexPathForItem(at: gesture.location(in: self)) {
                UISelectionFeedbackGenerator().selectionChanged()
                UIMenuController.shared.hideMenu()
                beginInteractiveMovementForItem(at: indexPath)
            }
            
        case .changed:
            updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            
        case .ended:
            renderers.endReordering()
            endInteractiveMovement()
            UIImpactFeedbackGenerator().impactOccurred()
            if let indexPath = indexPathForItem(at: gesture.location(in: self)) {
                // needs to chance to settle in case the model has been updated
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.showMenu(at: indexPath)
                }
            }
            
        default:
            cancelInteractiveMovement()
        }
    }
    
    private func showMenu(at indexPath: IndexPath) {
        guard let menuView = cellForItem(at: indexPath) else { return }
        guard menuView.becomeFirstResponder() else { return }
        let renderer = renderers.rendererFor(section: indexPath.section)
        guard let menuItems = renderer.menuItemsFor(itemAt: indexPath.row) else { return }
        
        let menuController = UIMenuController.shared
        
        menuController.menuItems = menuItems
        menuController.showMenu(from: self, rect: menuView.frame)
    }
    
    func omniBarCancelPressed() {
        renderers.omniBarCancelPressed()
    }
    
    func openedAsNewTab(allowingKeyboard: Bool) {
        renderers.openedAsNewTab(allowingKeyboard: allowingKeyboard)
    }
    
    func viewDidTransition(to size: CGSize) {
        
        if let topIndexPath = topIndexPath {
            controller.collectionView.scrollToItem(at: topIndexPath, at: .top, animated: false)
        }
        controller.collectionView.reloadData()
    }

    func refreshHomeConfiguration() {
        homePageConfiguration.refresh()
        renderers.refresh()
    }
}

extension HomeCollectionView: Themable {

    func decorate(with theme: Theme) {
        renderers.decorate(with: theme)
        reloadData()
    }
    
}

extension HomeCollectionView: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == collectionViewReorderingGesture,
            let indexPath = indexPathForItem(at: gestureRecognizer.location(in: self)) {
            return renderers.rendererFor(section: indexPath.section).supportsReordering()
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
