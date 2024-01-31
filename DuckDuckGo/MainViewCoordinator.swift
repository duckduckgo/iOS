//
//  MainViewCoordinator.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

class MainViewCoordinator {

    let superview: UIView

    var contentContainer: UIView!
    var lastToolbarButton: UIBarButtonItem!
    var logo: UIImageView!
    var logoContainer: UIView!
    var logoText: UIImageView!
    var navigationBarContainer: UIView!
    var navigationBarCollectionView: MainViewFactory.NavigationBarCollectionView!
    var notificationBarContainer: UIView!
    var omniBar: OmniBar!
    var progress: ProgressView!
    var statusBackground: UIView!
    var suggestionTrayContainer: UIView!
    var tabBarContainer: UIView!
    var toolbar: UIToolbar!
    var toolbarBackButton: UIBarButtonItem!
    var toolbarFireButton: UIBarButtonItem!
    var toolbarForwardButton: UIBarButtonItem!
    var toolbarTabSwitcherButton: UIBarButtonItem!

    let constraints = Constraints()

    // The default after creating the hiearchy is top
    var addressBarPosition: AddressBarPosition = .top

    /// STOP - why are you instanciating this?
    init(superview: UIView) {
        self.superview = superview
    }
    
    func showToolbarSeparator() {
        toolbar.setShadowImage(nil, forToolbarPosition: .any)
    }

    func hideToolbarSeparator() {
        self.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
    }

    class Constraints {

        var navigationBarContainerTop: NSLayoutConstraint!
        var navigationBarContainerBottom: NSLayoutConstraint!
        var navigationBarCollectionViewBottom: NSLayoutConstraint!
        var toolbarBottom: NSLayoutConstraint!
        var contentContainerTop: NSLayoutConstraint!
        var tabBarContainerTop: NSLayoutConstraint!
        var notificationContainerTopToNavigationBar: NSLayoutConstraint!
        var notificationContainerTopToStatusBackground: NSLayoutConstraint!
        var notificationContainerHeight: NSLayoutConstraint!
        var progressBarTop: NSLayoutConstraint!
        var progressBarBottom: NSLayoutConstraint!
        var statusBackgroundToNavigationBarContainerBottom: NSLayoutConstraint!
        var statusBackgroundBottomToSafeAreaTop: NSLayoutConstraint!
        var contentContainerBottomToToolbarTop: NSLayoutConstraint!
        var contentContainerBottomToNavigationBarContainerTop: NSLayoutConstraint!

    }

    func moveAddressBarToPosition(_ position: AddressBarPosition) {
        guard position != addressBarPosition else { return }
        switch position {
        case .top:
            setAddressBarBottomActive(false)
            setAddressBarTopActive(true)

        case .bottom:
            setAddressBarTopActive(false)
            setAddressBarBottomActive(true)
        }

        addressBarPosition = position
    }

    func hideNavigationBarWithBottomPosition() {
        guard addressBarPosition.isBottom else {
            return
        }

        // Hiding the container won't suffice as it still defines the contentContainer.bottomY through constraints
        navigationBarContainer.isHidden = true

        constraints.contentContainerBottomToNavigationBarContainerTop.isActive = false
        constraints.contentContainerBottomToToolbarTop.isActive = true
    }

    func showNavigationBarWithBottomPosition() {
        guard addressBarPosition.isBottom else {
            return
        }

        constraints.contentContainerBottomToToolbarTop.isActive = false
        constraints.contentContainerBottomToNavigationBarContainerTop.isActive = true

        navigationBarContainer.isHidden = false
    }

    func setAddressBarTopActive(_ active: Bool) {
        constraints.contentContainerBottomToToolbarTop.isActive = active
        constraints.navigationBarContainerTop.isActive = active
        constraints.progressBarTop.isActive = active
        constraints.notificationContainerTopToNavigationBar.isActive = active
        constraints.statusBackgroundToNavigationBarContainerBottom.isActive = active
    }

    func setAddressBarBottomActive(_ active: Bool) {
        constraints.contentContainerBottomToNavigationBarContainerTop.isActive = active
        constraints.progressBarBottom.isActive = active
        constraints.navigationBarContainerBottom.isActive = active
        constraints.notificationContainerTopToStatusBackground.isActive = active
        constraints.statusBackgroundBottomToSafeAreaTop.isActive = active
    }

}

extension MainViewCoordinator: Themable {
    
    func decorate(with theme: Theme) {
        superview.backgroundColor = theme.mainViewBackgroundColor
        logoText.tintColor = theme.ddgTextTintColor
        omniBar.decorate(with: theme)
    }

}
