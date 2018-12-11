//
//  HomeCollectionView.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 11/12/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit

class HomeCollectionView: UICollectionView {
    
    private var renderers: HomeViewSectionRenderers!
    
    private lazy var collectionViewReorderingGesture =
        UILongPressGestureRecognizer(target: self, action: #selector(self.collectionViewReorderingGestureHandler(gesture:)))
    
    private lazy var homePageConfiguration = AppDependencyProvider.shared.homePageConfiguration

    func configure(withController controller: HomeViewController, andTheme theme: Theme) {
        renderers = HomeViewSectionRenderers(controller: controller, theme: theme)
        
        homePageConfiguration.components.forEach { component in
            switch component {
            case .navigationBarSearch:
                renderers.install(renderer: NavigationSearchHomeViewSectionRenderer())
                
            case .centeredSearch:
                renderers.install(renderer: CenteredSearchHomeViewSectionRenderer())
                
            case .favorites:
                renderers.install(renderer: FavoritesHomeViewSectionRenderer())
            }
        }
        
        dataSource = renderers
        delegate = renderers
        addGestureRecognizer(collectionViewReorderingGesture)
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
        guard let menuItems = renderer.menuItemsFor?(itemAt: indexPath.row) else { return }
        
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

}

extension HomeCollectionView: Themable {

    func decorate(with theme: Theme) {
        renderers.decorate(with: theme)
        reloadData()
    }
    
}
