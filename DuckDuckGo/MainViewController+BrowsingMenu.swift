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
        
        let entries = tab.buildBrowsingMenu()
        let controller = BrowsingMenuViewController(nibName: "BrowsingMenuViewController", bundle: nil)
        controller.loadViewIfNeeded()
        controller.setHeaderEntires(tab.buildBrowsingMenuHeaderContent())
        controller.setMenuEntires(entries)
        
        controller.view.alpha = 0
        UIView.animate(withDuration: 0.3) {
            controller.attachTo(self.view) { [weak self] in
                self?.presentedMenuButton.setState(.menuImage, animated: true)
                UIView.animate(withDuration: 0.2, animations: {
                    controller.view.alpha = 0
                }, completion: { _ in
                    self?.dismissBrowsingMenu()
                })
            }
            controller.view.alpha = 1
        }
        
        if AppWidthObserver.shared.isLargeWidth {
            refreshConstraintsForTablet(browsingMenu: controller)
        } else {
            refreshConstraintsForPhone(browsingMenu: controller)
        }
        
        addChild(controller)
        
        browsingMenu = controller
        presentedMenuButton.setState(.closeImage, animated: true)
        tab.didLaunchBrowsingMenu()
    }
    
    func refreshConstraintsForPhone(browsingMenu: BrowsingMenuViewController) {
        guard let tab = currentTab else { return }
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: browsingMenu.view.trailingAnchor, constant: 10))
        
        if traitCollection.containsTraits(in: UITraitCollection(verticalSizeClass: .compact)) {
            // iPhone - landscape:
            
            // Move menu up, as bottom toolbar shrinks
            constraints.append(browsingMenu.view.bottomAnchor.constraint(equalTo: tab.webView.bottomAnchor, constant: 0))
            
            // Make it go above WebView
            constraints.append(browsingMenu.view.topAnchor.constraint(greaterThanOrEqualTo: tab.webView.topAnchor, constant: -10))
            
            // Flexible width
            constraints.append(browsingMenu.view.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 100))
        } else {
            // Reguar sizing:
            constraints.append(browsingMenu.view.bottomAnchor.constraint(equalTo: tab.webView.bottomAnchor, constant: 10))
            constraints.append(browsingMenu.view.topAnchor.constraint(greaterThanOrEqualTo: tab.webView.topAnchor, constant: 10))
            
            // Constant width
            constraints.append(browsingMenu.view.widthAnchor.constraint(equalToConstant: 280))
        }
        
        NSLayoutConstraint.deactivate(browsingMenu.parentConstraits)
        NSLayoutConstraint.activate(constraints)
        browsingMenu.parentConstraits = constraints
    }
    
    func refreshConstraintsForTablet(browsingMenu: BrowsingMenuViewController) {
        guard let tab = currentTab else { return }
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: browsingMenu.view.trailingAnchor, constant: 67))
        constraints.append(browsingMenu.view.widthAnchor.constraint(equalToConstant: 280))
        
        constraints.append(browsingMenu.view.bottomAnchor.constraint(lessThanOrEqualTo: tab.webView.bottomAnchor, constant: -40))
        
        // Make it go above WebView
        constraints.append(browsingMenu.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 50))
        
        NSLayoutConstraint.deactivate(browsingMenu.parentConstraits)
        NSLayoutConstraint.activate(constraints)
        browsingMenu.parentConstraits = constraints
    }
    
    func refreshMenuButtonState() {
        let expectedState: MenuButton.State = browsingMenu == nil ? .menuImage : .closeImage
        presentedMenuButton.setState(expectedState, animated: false)
    }
    
    func dismissBrowsingMenu() {
        guard let controller = browsingMenu else { return }
        
        controller.detachFrom(view)
        browsingMenu = nil
    }
    
}
