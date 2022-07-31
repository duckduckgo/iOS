//
//  MainViewController+BrowsingMenu.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

extension MainViewController {
    
    func launchBrowsingMenu() {
        guard let tab = currentTab, browsingMenu == nil else { return }
        
        tab.buildBrowsingMenu { [weak self] entries in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                let controller = BrowsingMenuViewController(nibName: "BrowsingMenuViewController", bundle: nil)
                controller.attachTo(self.view) { [weak self, weak controller] in
                    guard let controller = controller else { return }
                    self?.presentedMenuButton.setState(.menuImage, animated: true)
                    self?.dismiss(controller)
                }
                self.addChild(controller)
                
                controller.setHeaderEntries(tab.buildBrowsingMenuHeaderContent())
                controller.setMenuEntries(entries)
            
                self.layoutAndPresent(controller)
                
                if self.canDisplayAddFavoriteVisualIndicator {
                    controller.highlightCell(atIndex: IndexPath(row: tab.favoriteEntryIndex, section: 0))
                }
                
                self.browsingMenu = controller
                
                self.presentedMenuButton.setState(.closeImage, animated: true)
                tab.didLaunchBrowsingMenu()
            }
        }
    }
    
    fileprivate func layoutAndPresent(_ controller: BrowsingMenuViewController) {
                
        if AppWidthObserver.shared.isLargeWidth {
            refreshConstraintsForTablet(browsingMenu: controller)
        } else {
            refreshConstraintsForPhone(browsingMenu: controller)
        }
        
        view.sendSubviewToBack(controller.view)
        view.layoutIfNeeded()
        
        let snapshot = controller.view.snapshotView(afterScreenUpdates: true)
        if let snapshot = snapshot {
            snapshot.frame = menuOriginFrameForAnimation(controller: controller)
            snapshot.alpha = 0
            view.addSubview(snapshot)
            
            BrowsingMenuViewController.applyShadowTo(view: snapshot, for: ThemeManager.shared.currentTheme)
        }
        
        controller.view.alpha = 0
        view.bringSubviewToFront(controller.view)
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
            // Reset to desired dimensions
            snapshot?.frame = controller.view.frame
            snapshot?.alpha = 1
        }, completion: { _ in
            controller.view.alpha = 1
            snapshot?.removeFromSuperview()
            controller.flashScrollIndicatorsIfNeeded()
        })
    }
        
    fileprivate func dismiss(_ controller: BrowsingMenuViewController) {
        
        guard let snapshot = controller.view.snapshotView(afterScreenUpdates: false) else {
            dismissBrowsingMenu(updateMenuButtonState: false)
            return
        }
        
        view.addSubview(snapshot)
        snapshot.frame = controller.view.frame
        
        BrowsingMenuViewController.applyShadowTo(view: snapshot, for: ThemeManager.shared.currentTheme)
        
        controller.removeGestureRecognizer()
        controller.view.alpha = 0
        
        UIView.animate(withDuration: 0.2, animations: {
            snapshot.alpha = 0
            snapshot.frame = self.menuOriginFrameForAnimation(controller: controller)
        }, completion: { _ in
            snapshot.removeFromSuperview()
            self.dismissBrowsingMenu(updateMenuButtonState: false)
        })
    }
    
    fileprivate func menuOriginFrameForAnimation(controller: BrowsingMenuViewController) -> CGRect {
        if AppWidthObserver.shared.isLargeWidth {
            let frame = controller.view.frame
            var rect = frame.offsetBy(dx: frame.width - 100, dy: 0)
            rect.size.width = 100
            rect.size.height = 100
            return rect
        } else {
            let frame = controller.view.frame
            var rect = frame.offsetBy(dx: frame.width - 100, dy: frame.height - 100)
            rect.size.width = 100
            rect.size.height = 100
            return rect
        }
    }
    
    func refreshConstraintsForPhone(browsingMenu: BrowsingMenuViewController) {
        guard let tab = currentTab else { return }
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: browsingMenu.view.trailingAnchor, constant: 10))
        
        if traitCollection.containsTraits(in: UITraitCollection(verticalSizeClass: .compact)) {
            // iPhone - landscape:
            
            // Move menu up, as bottom toolbar shrinks
            constraints.append(browsingMenu.view.bottomAnchor.constraint(equalTo: tab.webView.bottomAnchor, constant: -2))
            
            // Make it go above WebView
            constraints.append(browsingMenu.view.topAnchor.constraint(greaterThanOrEqualTo: tab.webView.topAnchor, constant: -10))
            
            // Flexible width
            constraints.append(browsingMenu.view.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 100))
        } else {
            // Regular sizing:
            constraints.append(browsingMenu.view.bottomAnchor.constraint(equalTo: tab.webView.bottomAnchor, constant: 10))
            constraints.append(browsingMenu.view.topAnchor.constraint(greaterThanOrEqualTo: tab.webView.topAnchor, constant: 10))
            
            // Constant width
            let constraint = browsingMenu.view.widthAnchor.constraint(equalToConstant: 280)
            constraint.identifier = "width"
            constraints.append(constraint)
        }
        
        NSLayoutConstraint.deactivate(browsingMenu.parentConstraits)
        NSLayoutConstraint.activate(constraints)
        browsingMenu.parentConstraits = constraints
    }
    
    func refreshConstraintsForTablet(browsingMenu: BrowsingMenuViewController) {
        guard let tab = currentTab else { return }
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: browsingMenu.view.trailingAnchor, constant: 67))
        let constraint = browsingMenu.view.widthAnchor.constraint(equalToConstant: 280)
        constraint.identifier = "width"
        constraints.append(constraint)
        
        constraints.append(browsingMenu.view.bottomAnchor.constraint(lessThanOrEqualTo: tab.webView.bottomAnchor, constant: -40))
        
        // Make it go above WebView
        constraints.append(browsingMenu.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 50))
        
        NSLayoutConstraint.deactivate(browsingMenu.parentConstraits)
        NSLayoutConstraint.activate(constraints)
        browsingMenu.parentConstraits = constraints
    }
    
    func refreshMenuButtonState() {
        let expectedState: MenuButton.State
        if homeController != nil {
            expectedState = .bookmarksImage
        } else if browsingMenu == nil {
            expectedState = .menuImage
        } else {
            expectedState = .closeImage
        }
        presentedMenuButton.decorate(with: ThemeManager.shared.currentTheme)
        presentedMenuButton.setState(expectedState, animated: false)
    }
    
    func dismissBrowsingMenu(updateMenuButtonState: Bool = true) {
        guard let controller = browsingMenu else { return }
        
        controller.detachFrom(view)
        controller.removeFromParent()
        
        browsingMenu = nil
        
        if updateMenuButtonState {
            refreshMenuButtonState()
        }
    }
    
}
