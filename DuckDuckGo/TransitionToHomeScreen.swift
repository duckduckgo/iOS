//
//  TransitionToHomeScreen.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

import Core

class TransitionToHomeScreen: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let tabSwitcherViewController: TabSwitcherViewController
    
    init(tabSwitcherViewController: TabSwitcherViewController) {
        self.tabSwitcherViewController = tabSwitcherViewController
    }
    
    // swiftlint:disable function_body_length
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let mainViewController = transitionContext.viewController(forKey: .to) as? MainViewController,
            let homeScreen = mainViewController.homeController,
            let tab = mainViewController.currentTab?.tabModel,
            let rowIndex = tabSwitcherViewController.tabsModel.indexOf(tab: tab),
            let layoutAttr = tabSwitcherViewController.collectionView.layoutAttributesForItem(at: IndexPath(row: rowIndex, section: 0))
            else {
                return
        }
        
        let theme = ThemeManager.shared.currentTheme
        mainViewController.view.alpha = 1
        
        let imageContainer = UIView()
        imageContainer.frame = sourceContainerFrame(for: layoutAttr)
        imageContainer.backgroundColor = theme.tabSwitcherCellBackgroundColor
        
        imageContainer.clipsToBounds = true
        imageContainer.layer.cornerRadius = TabViewCell.Constants.cellCornerRadius
        
        let snapshot = homeScreen.view.snapshotView(afterScreenUpdates: false)!
        snapshot.alpha = 0
        imageContainer.addSubview(snapshot)
        snapshot.center = CGPoint(x: imageContainer.bounds.midX, y: imageContainer.bounds.midY)
        
        let imageView = UIImageView()
        imageView.frame = sourceImageFrame(for: imageContainer.bounds.size)
        imageView.image = TabViewCell.logoImage
        imageView.contentMode = .center
        imageView.backgroundColor = .clear
        imageContainer.addSubview(imageView)
        transitionContext.containerView.addSubview(imageContainer)
        
        scrollIfOutsideViewport(collectionView: tabSwitcherViewController.collectionView, rowIndex: rowIndex, attributes: layoutAttr)
        
        UIView.animateKeyframes(withDuration: TabSwitcherTransition.Constants.duration, delay: 0, options: .calculationModeLinear, animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1.0) {
                imageContainer.frame = homeScreen.view.convert(homeScreen.collectionView.frame, to: nil)
                imageContainer.layer.cornerRadius = 0
                imageContainer.backgroundColor = theme.backgroundColor
                imageView.frame = CGRect(origin: .zero,
                                         size: imageContainer.bounds.size)
                snapshot.center = CGPoint(x: imageContainer.bounds.midX, y: imageContainer.bounds.midY)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3) {
                imageView.alpha = 0
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.3) {
                snapshot.alpha = 1
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3) {
                self.tabSwitcherViewController.view.alpha = 0
            }
            
        }, completion: { _ in
            imageContainer.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }
    // swiftlint:enable function_body_length
    
    private func scrollIfOutsideViewport(collectionView: UICollectionView,
                                         rowIndex: Int,
                                         attributes: UICollectionViewLayoutAttributes) {
        // If cell is outside viewport, scroll while animating
        let collectionView = tabSwitcherViewController.collectionView!
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
    
    private func sourceContainerFrame(for attributes: UICollectionViewLayoutAttributes) -> CGRect {
        var targetFrame = self.tabSwitcherViewController.collectionView.convert(attributes.frame,
                                                                                to: self.tabSwitcherViewController.view)
        
        targetFrame = targetFrame.insetBy(dx: TabViewCell.Constants.cellShadowMargin,
                            dy: TabViewCell.Constants.cellShadowMargin)
        targetFrame.origin.y += TabViewCell.Constants.cellHeaderHeight
        targetFrame.size.height -= TabViewCell.Constants.cellHeaderHeight
        return targetFrame
    }
    
    private func sourceImageFrame(for containerBounds: CGSize) -> CGRect {
        var targetFrame = CGRect(origin: .zero, size: containerBounds)
        targetFrame.origin.y -= TabViewCell.Constants.cellHeaderHeight
        targetFrame.size.height += TabViewCell.Constants.cellHeaderHeight
        return targetFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TabSwitcherTransition.Constants.duration
    }
}
