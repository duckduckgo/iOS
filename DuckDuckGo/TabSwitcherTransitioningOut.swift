//
//  TabSwitcherTransitioningOut.swift
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

class TabSwitcherTransitioningOut: NSObject, UIViewControllerAnimatedTransitioning {
    
    struct Constants {
        static let duration = 0.5
    }
    
    private let tabSwitcherViewController: TabSwitcherViewController

    init(tabSwitcherViewController: TabSwitcherViewController) {
        self.tabSwitcherViewController = tabSwitcherViewController
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let mainViewController = transitionContext.viewController(forKey: .to) as? MainViewController,
            let webView = mainViewController.currentTab!.webView,
            let tab = mainViewController.currentTab?.tabModel,
            let rowIndex = tabSwitcherViewController.tabsModel.indexOf(tab: tab),
            let layoutAttr = tabSwitcherViewController.collectionView.layoutAttributesForItem(at: IndexPath(row: rowIndex, section: 0))
            else {
                return
        }
                
        let theme = ThemeManager.shared.currentTheme
        let webViewFrame = webView.convert(webView.bounds, to: nil)
        mainViewController.view.alpha = 1
        
        let solidBackground = UIView()
        solidBackground.backgroundColor = theme.backgroundColor
        solidBackground.frame = webView.bounds
        webView.addSubview(solidBackground)
        
        let imageContainer = UIView()
        imageContainer.frame = sourceContainerFrame(for: layoutAttr)
        
        imageContainer.clipsToBounds = true
        imageContainer.layer.cornerRadius = TabViewCell.Constants.cellCornerRadius
        
        let preview = tabSwitcherViewController.previewsSource.preview(for: tab)
        let imageView = UIImageView()
        imageView.frame = sourceImageFrame(for: imageContainer.bounds.size,
                                           preview: preview,
                                           attributes: layoutAttr)
        imageView.image = preview
        imageContainer.addSubview(imageView)
        transitionContext.containerView.addSubview(imageContainer)
        
        scrollIfOutsideViewport(collectionView: tabSwitcherViewController.collectionView, rowIndex: rowIndex, attributes: layoutAttr)
        
        UIView.animate(withDuration: Constants.duration, animations: {
            imageContainer.frame = webViewFrame
            imageContainer.layer.cornerRadius = 0
            imageView.frame = imageContainer.bounds
            
            solidBackground.alpha = 1
            self.tabSwitcherViewController.view.alpha = 0
        }, completion: { _ in
            solidBackground.removeFromSuperview()
            imageContainer.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }
    
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
        return targetFrame
    }
    
    private func sourceImageFrame(for containerSize: CGSize,
                                  preview: UIImage?,
                                  attributes: UICollectionViewLayoutAttributes) -> CGRect {
        let previewHeight: CGFloat
        if let preview = preview {
            previewHeight = containerSize.width * (preview.size.height / preview.size.width)
        } else {
            previewHeight = containerSize.height
        }
        
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
