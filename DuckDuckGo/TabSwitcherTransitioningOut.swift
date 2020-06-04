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
        static let duration = 0.7
    }
    
    private let tabSwitcherViewController: TabSwitcherViewController

    init(tabSwitcherViewController: TabSwitcherViewController) {
        self.tabSwitcherViewController = tabSwitcherViewController
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let mainViewController = transitionContext.viewController(forKey: .to) as? MainViewController,
            let webView = mainViewController.currentTab!.webView,
            let tab = mainViewController.currentTab?.tabModel,
        let row = tabSwitcherViewController.tabsModel.indexOf(tab: tab),
        let selectedCell = tabSwitcherViewController.collectionView.cellForItem(at: IndexPath(row: row, section: 0)) as? TabViewCell
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
        imageContainer.frame = selectedCell.convert(selectedCell.background.frame,
                                                                                to: nil)
        imageContainer.clipsToBounds = true
        imageContainer.layer.cornerRadius = TabViewCell.Constants.cellCornerRadius
        let imageView = UIImageView()
        imageView.frame = selectedCell.preview.frame
        imageView.image = selectedCell.preview.image
        imageContainer.addSubview(imageView)
        transitionContext.containerView.addSubview(imageContainer)
        
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

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Constants.duration
    }
}
