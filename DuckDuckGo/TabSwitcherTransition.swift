//
//  TabSwitcherTransition.swift
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

class TabSwitcherTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    struct Constants {
        static let duration = 0.20
    }
    
    // Used to hide contents of the 'from' VC when animating.
    let solidBackground = UIView()
    // Container for the image, will clip subviews like tab switcher cell does.
    let imageContainer = UIView()
    // Image to display as a preview.
    let imageView = UIImageView()
    
    let tabSwitcherViewController: TabSwitcherViewController
    
    init(tabSwitcherViewController: TabSwitcherViewController) {
        self.tabSwitcherViewController = tabSwitcherViewController
    }
    
    func prepareSubviews(using transitionContext: UIViewControllerContextTransitioning) {
        
        transitionContext.containerView.addSubview(solidBackground)

        imageContainer.clipsToBounds = true
        imageContainer.addSubview(imageView)
        transitionContext.containerView.addSubview(imageContainer)
    }
    
    // MARK: UIViewControllerAnimatedTransitioning

    // Override - Abstract function
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        assertionFailure("You must implement this method")
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TabSwitcherTransition.Constants.duration
    }
    
    // MARK: Common logic
    
    func scrollIfOutsideViewport(collectionView: UICollectionView,
                                 rowIndex: Int,
                                 attributes: UICollectionViewLayoutAttributes) {
        // If cell is outside viewport, scroll while animating
        if attributes.frame.origin.y + attributes.frame.size.height < collectionView.contentOffset.y {
            collectionView.scrollToItem(at: IndexPath(row: rowIndex, section: 0),
                                        at: .top,
                                        animated: true)
        } else if attributes.frame.origin.y > collectionView.frame.height + collectionView.contentOffset.y {
            collectionView.scrollToItem(at: IndexPath(row: rowIndex, section: 0),
                                        at: .bottom,
                                        animated: true)
        }
    }
}

class TabSwitcherTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let mainVC = presenting as? MainViewController,
            let tabSwitcherVC = presented as? TabSwitcherViewController else {
            return nil
        }
        
        if mainVC.newTabPageViewController != nil {
            return FromHomeScreenTransition(mainViewController: mainVC,
                                            tabSwitcherViewController: tabSwitcherVC)
        }
        
        return FromWebViewTransition(mainViewController: mainVC,
                                     tabSwitcherViewController: tabSwitcherVC)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let tabSwitcherVC = dismissed as? TabSwitcherViewController else { return nil }
        
        if let tab = tabSwitcherVC.tabsModel.currentTab, tab.link == nil {
            return ToHomeScreenTransition(tabSwitcherViewController: tabSwitcherVC)
        }
        return ToWebViewTransition(tabSwitcherViewController: tabSwitcherVC)
    }
}
