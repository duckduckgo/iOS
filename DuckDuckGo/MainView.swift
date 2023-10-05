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

// swiftlint:disable line_length

class MainViewFactory {

    private let coordinator: MainViewCoordinator

    var superview: UIView {
        coordinator.superview
    }

    private init(_ superview: UIView) {
        coordinator = MainViewCoordinator(superview: superview)
    }

    static func createViewHierarchy(_ superview: UIView, addressBarPosition: AddressBarPosition) -> MainViewCoordinator {
        let factory = MainViewFactory(superview)

        factory.createViews()
        factory.disableAutoresizingOnViewAndImmediateSubviews(superview)
        factory.constrainViews()

        let coordinator = factory.coordinator
        coordinator.moveAddressBarToPosition(addressBarPosition)
        return coordinator
    }

    private func disableAutoresizingOnViewAndImmediateSubviews(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
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
        coordinator.navigationBarContainer = NavigationBarContainer()
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

        disableAutoresizingOnViewAndImmediateSubviews(coordinator.logoContainer)
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

        coordinator.constraints.navigationBarContainerTop = navigationBarContainer.constrainView(superview.safeAreaLayoutGuide, by: .top)
        coordinator.constraints.navigationBarContainerBottom = navigationBarContainer.constrainView(toolbar, by: .bottom, to: .top)

        NSLayoutConstraint.activate([
            navigationBarContainer.constrainView(superview, by: .centerX),
            navigationBarContainer.constrainView(superview, by: .width),
            coordinator.constraints.navigationBarContainerTop,
            navigationBarContainer.constrainAttribute(.height, to: 52),
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

        coordinator.constraints.contentContainerTop = contentContainer.constrainView(notificationBarContainer, by: .top, to: .bottom)

        NSLayoutConstraint.activate([
            contentContainer.constrainView(superview, by: .leading),
            contentContainer.constrainView(superview, by: .trailing),
            contentContainer.constrainView(toolbar, by: .bottom, to: .top),
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

    var logoContainer: UIView!
    var logo: UIImageView!
    var logoText: UIImageView!
    var toolbar: UIToolbar!
    var suggestionTrayContainer: UIView!
    var contentContainer: UIView!
    var notificationBarContainer: UIView!
    var statusBackground: UIView!
    var tabBarContainer: UIView!
    var navigationBarContainer: UIView!
    var progress: ProgressView!
    var toolbarBackButton: UIBarButtonItem!
    var toolbarForwardButton: UIBarButtonItem!
    var toolbarFireButton: UIBarButtonItem!
    var toolbarTabSwitcherButton: UIBarButtonItem!
    var lastToolbarButton: UIBarButtonItem!

    let constraints = Constraints()

    // The default after creating the hiearchy is top
    var addressBarPosition: AddressBarPosition = .top

    fileprivate init(superview: UIView) {
        self.superview = superview
    }

    func decorateWithTheme(_ theme: Theme) {
        superview.backgroundColor = theme.mainViewBackgroundColor
        logoText.tintColor = theme.ddgTextTintColor
    }

    func showToolbarSeparator() {
        // Setting the background 'resets' the toolbar
        toolbar.setBackgroundImage(nil, forToolbarPosition: .bottom, barMetrics: .default)
        toolbar.setShadowImage(nil, forToolbarPosition: .bottom)
    }

    func hideToolbarSeparator() {
        // The shadow image is what defines the separator, but we don't need to change the background here (in fact we want to keep it).
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .bottom)
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
        var progressBarTop: NSLayoutConstraint!
        var progressBarBottom: NSLayoutConstraint!
        var statusBackgroundToNavigationBarContainerBottom: NSLayoutConstraint!
        var statusBackgroundBottomToSafeAreaTop: NSLayoutConstraint!

    }

    func moveAddressBarToPosition(_ position: AddressBarPosition) {
        guard position != addressBarPosition else { return }
        switch position {
        case .top:
            moveAddressBarToTop()
        case .bottom:
            moveAddressBarToBottom()
        }

        addressBarPosition = position
    }

    func moveAddressBarToTop() {
        constraints.progressBarBottom.isActive = false
        constraints.navigationBarContainerBottom.isActive = false
        constraints.notificationContainerTopToStatusBackground.isActive = false
        constraints.statusBackgroundBottomToSafeAreaTop.isActive = false

        constraints.navigationBarContainerTop.isActive = true
        constraints.progressBarTop.isActive = true
        constraints.notificationContainerTopToNavigationBar.isActive = true
        constraints.statusBackgroundToNavigationBarContainerBottom.isActive = true
    }

    func moveAddressBarToBottom() {
        constraints.navigationBarContainerTop.isActive = false
        constraints.progressBarTop.isActive = false
        constraints.notificationContainerTopToNavigationBar.isActive = false
        constraints.statusBackgroundToNavigationBarContainerBottom.isActive = false

        constraints.progressBarBottom.isActive = true
        constraints.navigationBarContainerBottom.isActive = true
        constraints.notificationContainerTopToStatusBackground.isActive = true
        constraints.statusBackgroundBottomToSafeAreaTop.isActive = true
    }

    func toggleAddressBar(_ top: Bool) {
    }

}

// swiftlint:enable line_length
