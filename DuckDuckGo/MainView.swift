//
//  MainView.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

// swiftlint:disable file_length
// swiftlint:disable line_length

class MainViewFactory {

    private let coordinator: MainViewCoordinator

    var superview: UIView {
        coordinator.superview
    }

    private init(_ superview: UIView) {
        coordinator = MainViewCoordinator(superview: superview)
    }

    static func createViewHierarchy(_ superview: UIView) -> MainViewCoordinator {
        let factory = MainViewFactory(superview)
        factory.createViews()
        factory.disableAutoresizingOnImmediateSubviews(superview)
        factory.constrainViews()
        return factory.coordinator
    }

    private func disableAutoresizingOnImmediateSubviews(_ view: UIView) {
        view.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

}

/// Create functions.  The lightweight subclases of UIView make it easier to debug to the UI.
extension MainViewFactory {

    private func createViews() {
        createLogoBackground()
        createContentContainer()
        createSuggestionTrayContainer()
        createNotificationBarContainer()
        createStatusBackground()
        createTabBarContainer()
        createNavigationBarContainer()
        createProgressView()
        createToolbar()
    }

    private func createProgressView() {
        coordinator.progress = ProgressView()
        superview.addSubview(coordinator.progress)
    }

    class NavigationBarContainer: UIView { }
    private func createNavigationBarContainer() {
        coordinator.omniBar = OmniBar.loadFromXib()
        coordinator.omniBar.translatesAutoresizingMaskIntoConstraints = false
        coordinator.navigationBarContainer = NavigationBarContainer()
        coordinator.navigationBarContainer.addSubview(coordinator.omniBar)
        superview.addSubview(coordinator.navigationBarContainer)
    }

    class NotificationBarContainer: UIView { }
    private func createNotificationBarContainer() {
        coordinator.notificationBarContainer = NotificationBarContainer()
        superview.addSubview(coordinator.notificationBarContainer)
    }

    class ContentContainer: UIView { }
    private func createContentContainer() {
        coordinator.contentContainer = ContentContainer()
        superview.addSubview(coordinator.contentContainer)
    }

    class StatusBackgroundView: UIView { }
    private func createStatusBackground() {
        coordinator.statusBackground = StatusBackgroundView()
        superview.addSubview(coordinator.statusBackground)
    }

    class TabBarContainer: UIView { }
    private func createTabBarContainer() {
        coordinator.tabBarContainer = TabBarContainer()
        superview.addSubview(coordinator.tabBarContainer)
    }

    class SuggestionTrayContainer: UIView { }
    private func createSuggestionTrayContainer() {
        coordinator.suggestionTrayContainer = SuggestionTrayContainer()
        coordinator.suggestionTrayContainer.isHidden = true
        coordinator.suggestionTrayContainer.backgroundColor = .clear
        superview.addSubview(coordinator.suggestionTrayContainer)
    }

    private func createToolbar() {

        coordinator.toolbar = HitTestingToolbar()
        coordinator.toolbar.isTranslucent = false

        coordinator.toolbarBackButton = UIBarButtonItem(title: UserText.keyCommandBrowserBack, image: UIImage(named: "BrowsePrevious"))
        coordinator.toolbarForwardButton = UIBarButtonItem(title: UserText.keyCommandBrowserForward, image: UIImage(named: "BrowseNext"))
        coordinator.toolbarFireButton = UIBarButtonItem(title: UserText.actionForgetAll, image: UIImage(named: "Fire"))
        coordinator.toolbarTabSwitcherButton = UIBarButtonItem(title: UserText.tabSwitcherAccessibilityLabel, image: UIImage(named: "Add-24"))
        coordinator.lastToolbarButton = UIBarButtonItem(title: UserText.actionOpenBookmarks, image: UIImage(named: "Book-24"))
        superview.addSubview(coordinator.toolbar)

        coordinator.toolbar.setItems([
            coordinator.toolbarBackButton!,
            .flexibleSpace(),
            coordinator.toolbarForwardButton!,
            .flexibleSpace(),
            coordinator.toolbarFireButton!,
            .flexibleSpace(),
            coordinator.toolbarTabSwitcherButton!,
            .flexibleSpace(),
            coordinator.lastToolbarButton!,
        ], animated: true)
    }

    class LogoBackgroundView: UIView { }
    private func createLogoBackground() {
        coordinator.logoContainer = LogoBackgroundView()
        coordinator.logo = UIImageView(image: UIImage(named: "Logo"))
        coordinator.logoText = UIImageView(image: UIImage(named: "TextDuckDuckGo"))

        coordinator.logoContainer.backgroundColor = .clear
        coordinator.logoContainer.addSubview(coordinator.logo)
        coordinator.logoContainer.addSubview(coordinator.logoText)
        superview.addSubview(coordinator.logoContainer)

        disableAutoresizingOnImmediateSubviews(coordinator.logoContainer)
    }

}

/// Add constraint functions
extension MainViewFactory {

    private func constrainViews() {
        constrainLogoBackground()
        constrainContentContainer()
        constrainSuggestionTrayContainer()
        constrainNotificationBarContainer()
        constrainStatusBackground()
        constrainTabBarContainer()
        constrainNavigationBarContainer()
        constrainProgress()
        constrainToolbar()
    }

    private func constrainProgress() {
        let progress = coordinator.progress!
        let navigationBarContainer = coordinator.navigationBarContainer!

        coordinator.constraints.progressBarTop = progress.constrainView(navigationBarContainer, by: .top, to: .bottom)
        coordinator.constraints.progressBarBottom = progress.constrainView(navigationBarContainer, by: .bottom, to: .top)

        NSLayoutConstraint.activate([
            progress.constrainView(navigationBarContainer, by: .trailing),
            progress.constrainView(navigationBarContainer, by: .leading),
            progress.constrainAttribute(.height, to: 3),
            coordinator.constraints.progressBarTop,
        ])
    }

    private func constrainNavigationBarContainer() {
        let navigationBarContainer = coordinator.navigationBarContainer!
        let toolbar = coordinator.toolbar!
        let omniBar = coordinator.omniBar!

        coordinator.constraints.navigationBarContainerTop = navigationBarContainer.constrainView(superview.safeAreaLayoutGuide, by: .top)
        coordinator.constraints.navigationBarContainerBottom = navigationBarContainer.constrainView(toolbar, by: .bottom, to: .top)
        coordinator.constraints.omniBarBottom = omniBar.constrainView(navigationBarContainer, by: .bottom, relatedBy: .greaterThanOrEqual)

        NSLayoutConstraint.activate([
            coordinator.constraints.navigationBarContainerTop,
            navigationBarContainer.constrainView(superview, by: .centerX),
            navigationBarContainer.constrainView(superview, by: .width),
            navigationBarContainer.constrainAttribute(.height, to: 52, relatedBy: .greaterThanOrEqual),
            omniBar.constrainAttribute(.height, to: 52),
            omniBar.constrainView(navigationBarContainer, by: .top),
            omniBar.constrainView(navigationBarContainer, by: .leading),
            omniBar.constrainView(navigationBarContainer, by: .trailing),
            coordinator.constraints.omniBarBottom,
        ])
    }

    private func constrainTabBarContainer() {
        let tabBarContainer = coordinator.tabBarContainer!
        
        coordinator.constraints.tabBarContainerTop = tabBarContainer.constrainView(superview.safeAreaLayoutGuide, by: .top)

        NSLayoutConstraint.activate([
            tabBarContainer.constrainView(superview, by: .leading),
            tabBarContainer.constrainView(superview, by: .trailing),
            tabBarContainer.constrainAttribute(.height, to: 40),
            coordinator.constraints.tabBarContainerTop,
        ])
    }

    private func constrainStatusBackground() {
        let statusBackground = coordinator.statusBackground!
        let navigationBarContainer = coordinator.navigationBarContainer!

        coordinator.constraints.statusBackgroundToNavigationBarContainerBottom = statusBackground.constrainView(navigationBarContainer, by: .bottom)

        coordinator.constraints.statusBackgroundBottomToSafeAreaTop = statusBackground.constrainView(coordinator.superview.safeAreaLayoutGuide, by: .bottom, to: .top)

        NSLayoutConstraint.activate([
            statusBackground.constrainView(superview, by: .width),
            statusBackground.constrainView(superview, by: .centerX),
            statusBackground.constrainView(superview, by: .top),
            coordinator.constraints.statusBackgroundToNavigationBarContainerBottom,
        ])
    }

    private func constrainNotificationBarContainer() {
        let notificationBarContainer = coordinator.notificationBarContainer!
        let contentContainer = coordinator.contentContainer!
        let navigationBarContainer = coordinator.navigationBarContainer!
        let statusBackground = coordinator.statusBackground!

        coordinator.constraints.notificationContainerTopToNavigationBar = notificationBarContainer.constrainView(navigationBarContainer, by: .top, to: .bottom)
        coordinator.constraints.notificationContainerTopToStatusBackground = notificationBarContainer.constrainView(statusBackground, by: .top, to: .bottom)
        coordinator.constraints.notificationContainerHeight = notificationBarContainer.constrainAttribute(.height, to: 0)

        NSLayoutConstraint.activate([
            notificationBarContainer.constrainView(superview, by: .width),
            notificationBarContainer.constrainView(superview, by: .centerX),
            coordinator.constraints.notificationContainerHeight,
            notificationBarContainer.constrainView(contentContainer, by: .bottom, to: .top),
            coordinator.constraints.notificationContainerTopToNavigationBar,
        ])
    }

    private func constrainContentContainer() {
        let contentContainer = coordinator.contentContainer!
        let toolbar = coordinator.toolbar!
        let notificationBarContainer = coordinator.notificationBarContainer!
        let navigationBarContainer = coordinator.navigationBarContainer!

        coordinator.constraints.contentContainerTop = contentContainer.constrainView(notificationBarContainer, by: .top, to: .bottom)
        coordinator.constraints.contentContainerBottomToToolbarTop = contentContainer.constrainView(toolbar, by: .bottom, to: .top)
        coordinator.constraints.contentContainerBottomToNavigationBarContainerTop = contentContainer.constrainView(navigationBarContainer, by: .bottom, to: .top)

        NSLayoutConstraint.activate([
            contentContainer.constrainView(superview, by: .leading),
            contentContainer.constrainView(superview, by: .trailing),
            coordinator.constraints.contentContainerBottomToToolbarTop,
            coordinator.constraints.contentContainerTop,
        ])
    }

    private func constrainToolbar() {
        let toolbar = coordinator.toolbar!
        coordinator.constraints.toolbarBottom = toolbar.constrainView(superview.safeAreaLayoutGuide, by: .bottom)
        NSLayoutConstraint.activate([
            toolbar.constrainView(superview, by: .width),
            toolbar.constrainView(superview, by: .centerX),
            toolbar.constrainAttribute(.height, to: 49),
            coordinator.constraints.toolbarBottom,
        ])
    }

    private func constrainSuggestionTrayContainer() {
        let suggestionTrayContainer = coordinator.suggestionTrayContainer!
        let contentContainer = coordinator.contentContainer!
        NSLayoutConstraint.activate([
            suggestionTrayContainer.constrainView(contentContainer, by: .width),
            suggestionTrayContainer.constrainView(contentContainer, by: .height),
            suggestionTrayContainer.constrainView(contentContainer, by: .centerX),
            suggestionTrayContainer.constrainView(contentContainer, by: .centerY),
        ])
    }

    private func constrainLogoBackground() {
        let logoContainer = coordinator.logoContainer!
        let logo = coordinator.logo!
        let text = coordinator.logoText!
        NSLayoutConstraint.activate([
            logoContainer.constrainView(superview, by: .width),
            logoContainer.constrainView(superview, by: .height),
            logoContainer.constrainView(superview, by: .centerX),
            logoContainer.constrainView(superview, by: .centerY),
            logo.constrainView(logoContainer, by: .centerX),
            logo.constrainView(logoContainer, by: .centerY, constant: -72),
            logo.constrainAttribute(.width, to: 96),
            logo.constrainAttribute(.height, to: 96),
            text.constrainView(logo, by: .top, to: .bottom, constant: 12),
            text.constrainView(logo, by: .centerX),
        ])
    }

}

class MainViewCoordinator {

    let superview: UIView

    var contentContainer: UIView!
    var lastToolbarButton: UIBarButtonItem!
    var logo: UIImageView!
    var logoContainer: UIView!
    var logoText: UIImageView!
    var navigationBarContainer: UIView!
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

    fileprivate init(superview: UIView) {
        self.superview = superview
    }

    func decorateWithTheme(_ theme: Theme) {
        superview.backgroundColor = theme.mainViewBackgroundColor
        logoText.tintColor = theme.ddgTextTintColor
        omniBar.decorate(with: theme)
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
        var toolbarBottom: NSLayoutConstraint!
        var contentContainerTop: NSLayoutConstraint!
        var tabBarContainerTop: NSLayoutConstraint!
        var notificationContainerTopToNavigationBar: NSLayoutConstraint!
        var notificationContainerTopToStatusBackground: NSLayoutConstraint!
        var notificationContainerHeight: NSLayoutConstraint!
        var omniBarBottom: NSLayoutConstraint!
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

// swiftlint:enable line_length
// swiftlint:enable file_length
