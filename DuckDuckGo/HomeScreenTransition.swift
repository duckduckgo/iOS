//
//  HomeScreenTransition.swift
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

protocol HomeScreenTransitionSource: AnyObject {
    var snapshotView: UIView { get }
    var rootContainerView: UIView { get }
}

class HomeScreenTransition: TabSwitcherTransition {
    
    fileprivate var homeScreenSnapshot: UIView?
    fileprivate var settingsButtonSnapshot: UIView?
    
    fileprivate let tabSwitcherSettings: TabSwitcherSettings = DefaultTabSwitcherSettings()
    
    fileprivate func prepareSnapshots(with transitionSource: HomeScreenTransitionSource,
                                      transitionContext: UIViewControllerContextTransitioning) {
        let viewToSnapshot = transitionSource.snapshotView
        let frameToSnapshot = transitionSource.rootContainerView.convert(transitionSource.rootContainerView.bounds, to: viewToSnapshot)

        if let snapshot = viewToSnapshot.resizableSnapshotView(from: frameToSnapshot,
                                                               afterScreenUpdates: false,
                                                               withCapInsets: .zero) {
            imageContainer.addSubview(snapshot)
            snapshot.frame = imageContainer.bounds
            homeScreenSnapshot = snapshot
        }
    }

    fileprivate func tabSwitcherCellFrame(for attributes: UICollectionViewLayoutAttributes) -> CGRect {
        var targetFrame = self.tabSwitcherViewController.collectionView.convert(attributes.frame,
                                                                                to: self.tabSwitcherViewController.view)
        
        guard tabSwitcherSettings.isGridViewEnabled else {
            return targetFrame
        }
        
        targetFrame.origin.y += TabViewCell.Constants.cellHeaderHeight
        targetFrame.size.height -= TabViewCell.Constants.cellHeaderHeight
        return targetFrame
    }
    
    fileprivate func previewFrame(for cellBounds: CGSize) -> CGRect {
        guard tabSwitcherSettings.isGridViewEnabled else {
            return CGRect(origin: .zero, size: cellBounds)
        }
        
        var targetFrame = CGRect(origin: .zero, size: cellBounds)
        targetFrame.origin.y -= TabViewCell.Constants.cellHeaderHeight
        targetFrame.size.height += TabViewCell.Constants.cellHeaderHeight
        return targetFrame
    }
    
}

class FromHomeScreenTransition: HomeScreenTransition {
    
    private let mainViewController: MainViewController
    
    init(mainViewController: MainViewController,
         tabSwitcherViewController: TabSwitcherViewController) {
        self.mainViewController = mainViewController

        super.init(tabSwitcherViewController: tabSwitcherViewController)
    }

    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        prepareSubviews(using: transitionContext)
        
        tabSwitcherViewController.view.alpha = 0
        transitionContext.containerView.insertSubview(tabSwitcherViewController.view, belowSubview: imageContainer)
        tabSwitcherViewController.view.frame = transitionContext.finalFrame(for: tabSwitcherViewController)
        tabSwitcherViewController.prepareForPresentation()
        
        guard let homeScreen = mainViewController.newTabPageViewController,
              let tab = mainViewController.tabManager.model.currentTab,
              let rowIndex = tabSwitcherViewController.tabsModel.indexOf(tab: tab),
              let layoutAttr = tabSwitcherViewController.collectionView.layoutAttributesForItem(at: IndexPath(row: rowIndex, section: 0))
        else {
            tabSwitcherViewController.view.alpha = 1
            transitionContext.completeTransition(true)
            return
        }

        let theme = ThemeManager.shared.currentTheme
        
        solidBackground.frame = homeScreen.view.convert(homeScreen.rootContainerView.frame, to: nil)
        solidBackground.backgroundColor = theme.backgroundColor
        
        imageContainer.frame = solidBackground.frame
        imageContainer.backgroundColor = theme.backgroundColor
        
        prepareSnapshots(with: homeScreen, transitionContext: transitionContext)
        
        imageView.alpha = 0
        imageView.frame = imageContainer.bounds
        imageView.contentMode = .center
        if tabSwitcherSettings.isGridViewEnabled {
            imageView.image = TabViewCell.logoImage
        }
        
        UIView.animateKeyframes(withDuration: TabSwitcherTransition.Constants.duration, delay: 0, options: .calculationModeLinear, animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1.0) {
                let containerFrame = self.tabSwitcherCellFrame(for: layoutAttr)
                self.imageContainer.frame = containerFrame
                self.imageContainer.layer.cornerRadius = TabViewCell.Constants.cellCornerRadius
                self.imageContainer.backgroundColor = theme.tabSwitcherCellBackgroundColor
                self.imageView.frame = self.previewFrame(for: self.imageContainer.bounds.size)
                self.homeScreenSnapshot?.frame = self.imageContainer.bounds
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) {
                self.homeScreenSnapshot?.alpha = 0
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.7) {
                self.tabSwitcherViewController.view.alpha = 1
            }
            
            if self.tabSwitcherSettings.isGridViewEnabled {
                UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.3) {
                    self.imageView.alpha = 1
                    self.settingsButtonSnapshot?.alpha = 0
                }
            } else {
                UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3) {
                    self.imageContainer.alpha = 0
                    self.settingsButtonSnapshot?.alpha = 0
                }
            }

        }, completion: { _ in
            self.solidBackground.removeFromSuperview()
            self.imageContainer.removeFromSuperview()
            self.settingsButtonSnapshot?.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }
}

class ToHomeScreenTransition: HomeScreenTransition {

    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        prepareSubviews(using: transitionContext)
        
        guard let mainViewController = transitionContext.viewController(forKey: .to) as? MainViewController,
              let homeScreen = mainViewController.newTabPageViewController,
              let tab = mainViewController.tabManager.model.currentTab,
              let rowIndex = tabSwitcherViewController.tabsModel.indexOf(tab: tab),
              let layoutAttr = tabSwitcherViewController.collectionView.layoutAttributesForItem(at: IndexPath(row: rowIndex, section: 0))
        else {
            transitionContext.completeTransition(true)
            return
        }

        mainViewController.view.alpha = 1
        
        let theme = ThemeManager.shared.currentTheme
        imageContainer.frame = tabSwitcherCellFrame(for: layoutAttr)
        imageContainer.backgroundColor = theme.tabSwitcherCellBackgroundColor
        imageContainer.layer.cornerRadius = TabViewCell.Constants.cellCornerRadius
        
        prepareSnapshots(with: homeScreen, transitionContext: transitionContext)
        homeScreenSnapshot?.alpha = 0
        settingsButtonSnapshot?.alpha = 0
        
        imageView.frame = previewFrame(for: imageContainer.bounds.size)
        imageView.contentMode = .center
        if tabSwitcherSettings.isGridViewEnabled {
            imageView.image = TabViewCell.logoImage
            imageView.alpha = tab.viewed ? 1 : 0
        }
        imageView.backgroundColor = .clear
        
        scrollIfOutsideViewport(collectionView: tabSwitcherViewController.collectionView, rowIndex: rowIndex, attributes: layoutAttr)
        
        UIView.animateKeyframes(withDuration: TabSwitcherTransition.Constants.duration, delay: 0, options: .calculationModeLinear, animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1.0) {
                self.imageContainer.frame = homeScreen.view.convert(homeScreen.rootContainerView.frame, to: nil)
                self.imageContainer.layer.cornerRadius = 0
                self.imageContainer.backgroundColor = theme.backgroundColor
                self.imageView.frame = CGRect(origin: .zero,
                                              size: self.imageContainer.bounds.size)
                self.homeScreenSnapshot?.frame = self.imageContainer.bounds
            }
            
            if tab.viewed {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3) {
                    self.imageView.alpha = 0
                    self.imageContainer.alpha = 1
                }
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.3) {
                self.homeScreenSnapshot?.alpha = 1
                self.settingsButtonSnapshot?.alpha = 1
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3) {
                self.tabSwitcherViewController.view.alpha = 0
            }
            
        }, completion: { _ in
            self.imageContainer.removeFromSuperview()
            self.settingsButtonSnapshot?.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }
}
