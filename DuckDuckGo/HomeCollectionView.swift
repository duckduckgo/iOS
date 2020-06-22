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

class HomeCollectionView: UICollectionView {
    
    struct Constants {
        static let topInset: CGFloat = 79
    }
    
    private weak var controller: HomeViewController!
    
    private(set) var renderers: HomeViewSectionRenderers!
    
    private lazy var collectionViewReorderingGesture =
        UILongPressGestureRecognizer(target: self, action: #selector(self.collectionViewReorderingGestureHandler(gesture:)))
    
    private lazy var homePageConfiguration = AppDependencyProvider.shared.homePageConfiguration

    var centeredSearch: UIView? {
        guard let renderer = renderers.rendererFor(section: 0) as? CenteredSearchHomeViewSectionRenderer else { return nil }
        return renderer.centeredSearch
    }
    
    private var topIndexPath: IndexPath? {
        for section in 0..<renderers.numberOfSections(in: self) {
            if numberOfItems(inSection: section) > 0 {
                return IndexPath(row: 0, section: section)
            }
        }
        return nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        register(UINib(nibName: "FavoriteHomeCell", bundle: nil),
                 forCellWithReuseIdentifier: "favorite")
        register(UINib(nibName: "PrivacyProtectionHomeCell", bundle: nil),
                 forCellWithReuseIdentifier: "PrivacyHomeCell")
        register(UINib(nibName: "ExtraContentHomeCell", bundle: nil),
                 forCellWithReuseIdentifier: "extraContent")
        
        register(EmptyCollectionReusableView.self,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                 withReuseIdentifier: EmptyCollectionReusableView.reuseIdentifier)
        register(EmptyCollectionReusableView.self,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                 withReuseIdentifier: EmptyCollectionReusableView.reuseIdentifier)
        
        contentInset = UIEdgeInsets(top: Constants.topInset, left: 0, bottom: 0, right: 0)
    }
    
    deinit {
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }
    
    func configure(withController controller: HomeViewController, andTheme theme: Theme) {
        self.controller = controller
        renderers = HomeViewSectionRenderers(controller: controller, theme: theme)
        
        homePageConfiguration.components().forEach { component in
            switch component {
            case .navigationBarSearch(let fixed):
                renderers.install(renderer: NavigationSearchHomeViewSectionRenderer(fixed: fixed))
                
            case .centeredSearch(let fixed):
                if controller.homeScreenMessage == nil {
                    renderers.install(renderer: CenteredSearchHomeViewSectionRenderer(fixed: fixed))
                } else {
                    renderers.install(renderer: NavigationSearchHomeViewSectionRenderer(fixed: fixed))
                }
                
            case .extraContent:
                renderers.install(renderer: ExtraContentHomeSectionRenderer())
                
            case .favorites:
                renderers.install(renderer: FavoritesHomeViewSectionRenderer())

            case .padding:
                renderers.install(renderer: PaddingHomeViewSectionRenderer())

            }

        }
        
        dataSource = renderers
        delegate = renderers
        collectionViewReorderingGesture.delegate = self
        addGestureRecognizer(collectionViewReorderingGesture)
    }
    
    func launchNewSearch() {
        renderers.launchNewSearch()
    }
 
    @objc func collectionViewReorderingGestureHandler(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            if let indexPath = indexPathForItem(at: gesture.location(in: self)) {
                UISelectionFeedbackGenerator().selectionChanged()
                UIMenuController.shared.setMenuVisible(false, animated: true)
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
        
        menuController.setTargetRect(menuView.frame, in: self)
        menuController.menuItems = menuItems
        menuController.setMenuVisible(true, animated: true)
    }
    
    func omniBarCancelPressed() {
        renderers.omniBarCancelPressed()
    }
    
    func openedAsNewTab() {
        renderers.openedAsNewTab()
    }
    
    func viewDidTransition(to size: CGSize) {
        
        if let topIndexPath = topIndexPath {
            controller.collectionView.scrollToItem(at: topIndexPath, at: .top, animated: false)
        }
        controller.collectionView.reloadData()
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
