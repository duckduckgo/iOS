//
//  TabSwitcherTransitioningIn.swift
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

class TabSwitcherTransitioningIn: NSObject, UIViewControllerAnimatedTransitioning {
    
    struct Constants {
        static let duration = 0.7
    }
    
    private let mainViewController: MainViewController
    private let tabSwitcherViewController: TabSwitcherViewController

    init(mainViewController: MainViewController,
         tabSwitcherViewController: TabSwitcherViewController) {
        self.mainViewController = mainViewController
        self.tabSwitcherViewController = tabSwitcherViewController
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        tabSwitcherViewController.prepareForPresentation()
        
        guard let webView = mainViewController.currentTab!.webView,
            let tab = mainViewController.currentTab?.tabModel,
        let rowIndex = tabSwitcherViewController.tabsModel.indexOf(tab: tab),
        let layoutAttr = tabSwitcherViewController.collectionView.layoutAttributesForItem(at: IndexPath(row: rowIndex, section: 0)),
        let preview = tabSwitcherViewController.previewsSource.preview(for: tab)
            else {
                return }
        
        let theme = ThemeManager.shared.currentTheme
        let webViewFrame = webView.convert(webView.bounds, to: nil)
        
        let solidBackground = UIView()
        solidBackground.backgroundColor = theme.backgroundColor
        solidBackground.frame = webViewFrame
        transitionContext.containerView.addSubview(solidBackground)
        
        tabSwitcherViewController.view.alpha = 0
        transitionContext.containerView.addSubview(tabSwitcherViewController.view)
        tabSwitcherViewController.view.frame = transitionContext.finalFrame(for: tabSwitcherViewController)
        
        let imageContainer = UIView()
        imageContainer.frame = webViewFrame
        imageContainer.clipsToBounds = true
        let imageView = UIImageView()
        imageView.frame = imageContainer.bounds
        imageView.image = preview
        imageContainer.addSubview(imageView)
        transitionContext.containerView.addSubview(imageContainer)
        
        UIView.animateKeyframes(withDuration: Constants.duration, delay: 0, options: .calculationModeLinear, animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1.0) {
                let containerFrame = self.targetContainerFrame(for: layoutAttr)
                imageContainer.frame = containerFrame
                imageContainer.layer.cornerRadius = TabViewCell.Constants.cellCornerRadius
                imageView.frame = self.targetImageFrame(for: containerFrame.size,
                                                   preview: preview,
                                                   attributes: layoutAttr)
                
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
    
    private func targetContainerFrame(for attributes: UICollectionViewLayoutAttributes) -> CGRect {
        var targetFrame = self.tabSwitcherViewController.collectionView.convert(attributes.frame,
                                                                                to: self.tabSwitcherViewController.view)
        
        targetFrame = targetFrame.insetBy(dx: TabViewCell.Constants.cellShadowMargin,
                                          dy: TabViewCell.Constants.cellShadowMargin)
        return targetFrame
    }
    
    private func targetImageFrame(for containerSize: CGSize,
                                  preview: UIImage,
                                  attributes: UICollectionViewLayoutAttributes) -> CGRect {
        
        let previewHeight = containerSize.width * (preview.size.height / preview.size.width)
        let targetFrame = CGRect(x: 0,
                                 y: TabViewCell.Constants.cellHeaderHeight,
                                 width: containerSize.width,
                                 height: previewHeight)
        return targetFrame
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Constants.duration
    }
}
