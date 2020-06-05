//
//  TransitionFromHomeScreen.swift
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

class TransitionFromHomeScreen: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let mainViewController: MainViewController
    private let tabSwitcherViewController: TabSwitcherViewController

    init(mainViewController: MainViewController,
         tabSwitcherViewController: TabSwitcherViewController) {
        self.mainViewController = mainViewController
        self.tabSwitcherViewController = tabSwitcherViewController
    }
    
    // swiftlint:disable function_body_length
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        tabSwitcherViewController.prepareForPresentation()
        
        guard let homeScreen = mainViewController.homeController,
            let tab = mainViewController.currentTab?.tabModel,
        let rowIndex = tabSwitcherViewController.tabsModel.indexOf(tab: tab),
        let layoutAttr = tabSwitcherViewController.collectionView.layoutAttributesForItem(at: IndexPath(row: rowIndex, section: 0))
            else {
                return
        }
        
        let theme = ThemeManager.shared.currentTheme
        
        let solidBackground = UIView()
        solidBackground.backgroundColor = theme.backgroundColor
        solidBackground.frame = homeScreen.view.convert(homeScreen.collectionView.frame, to: nil)
        transitionContext.containerView.addSubview(solidBackground)
        
        tabSwitcherViewController.view.alpha = 0
        transitionContext.containerView.addSubview(tabSwitcherViewController.view)
        tabSwitcherViewController.view.frame = transitionContext.finalFrame(for: tabSwitcherViewController)
        
        let imageContainer = UIView()
        imageContainer.frame = solidBackground.frame
        imageContainer.clipsToBounds = true
        imageContainer.backgroundColor = theme.backgroundColor
        
        let viewToShanpshot: UIView
        if homeScreen.logo.isHidden {
            viewToShanpshot = homeScreen.collectionView
        } else {
            viewToShanpshot = homeScreen.logoContainer
        }
        
        let snapshot = viewToShanpshot.snapshotView(afterScreenUpdates: false)!
        snapshot.frame = CGRect(origin: .zero, size: imageContainer.bounds.size)
        imageContainer.addSubview(snapshot)
        
        let imageView = UIImageView()
        imageView.frame = snapshot.frame
        imageView.image = TabViewCell.logoImage
        imageView.alpha = 0
        imageView.contentMode = .center
        imageContainer.addSubview(imageView)
        transitionContext.containerView.addSubview(imageContainer)
        
        UIView.animateKeyframes(withDuration: TabSwitcherTransition.Constants.duration, delay: 0, options: .calculationModeLinear, animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1.0) {
                let containerFrame = self.targetContainerFrame(for: layoutAttr)
                imageContainer.frame = containerFrame
                imageContainer.layer.cornerRadius = TabViewCell.Constants.cellCornerRadius
                imageContainer.backgroundColor = theme.tabSwitcherCellBackgroundColor
                imageView.frame = self.targetPreviewFrame(for: imageContainer.bounds.size)
                snapshot.center = CGPoint(x: containerFrame.width / 2, y: containerFrame.height / 2)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) {
                snapshot.alpha = 0
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.3) {
                imageView.alpha = 1
            }

            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.7) {
                self.tabSwitcherViewController.view.alpha = 1
            }
        }, completion: { _ in
            solidBackground.removeFromSuperview()
            imageContainer.removeFromSuperview()
            transitionContext.completeTransition(true)
        })

    }
    // swiftlint:enable function_body_length
    
    private func targetContainerFrame(for attributes: UICollectionViewLayoutAttributes) -> CGRect {
        var targetFrame = self.tabSwitcherViewController.collectionView.convert(attributes.frame,
                                                                                to: self.tabSwitcherViewController.view)
        
        targetFrame = targetFrame.insetBy(dx: TabViewCell.Constants.cellShadowMargin,
                            dy: TabViewCell.Constants.cellShadowMargin)
        targetFrame.origin.y += TabViewCell.Constants.cellHeaderHeight
        targetFrame.size.height -= TabViewCell.Constants.cellHeaderHeight
        return targetFrame
    }
    
    private func targetPreviewFrame(for containerBounds: CGSize) -> CGRect {
        var targetFrame = CGRect(origin: .zero, size: containerBounds)
        targetFrame.origin.y -= TabViewCell.Constants.cellHeaderHeight
        targetFrame.size.height += TabViewCell.Constants.cellHeaderHeight
        return targetFrame
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TabSwitcherTransition.Constants.duration
    }
}
