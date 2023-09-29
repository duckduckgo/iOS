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

    static func createViewHierarchy(_ superview: UIView) -> MainViewCoordinator {
        let factory = MainViewFactory(superview)

        factory.createViews()
        factory.disableAutoresizingOnViewAndSubviews(superview)
        factory.constrainViews()

        return factory.coordinator
    }

    private func disableAutoresizingOnViewAndSubviews(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

}

/// Create functions
extension MainViewFactory {

    private func createViews() {
        createLogoBackground()
        createContentContainer()
        createSuggestionTrayContainer()
        createNotificationBarContainer()
        createStatusBackground()
        createTabsContainer()
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

    class TabsContainer: UIView { }
    private func createTabsContainer() {
        coordinator.tabsContainer = TabsContainer()
        superview.addSubview(coordinator.tabsContainer)
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
        coordinator.toolbarBackButton = UIBarButtonItem(title: "Browse Back", image: UIImage(named: "BrowsePrevious"), primaryAction: nil, menu: nil)
        coordinator.toolbarForwardButton = UIBarButtonItem(title: "Browse Forward", image: UIImage(named: "BrowseNext"), primaryAction: nil, menu: nil)
        coordinator.toolbarFireButton = UIBarButtonItem(title: "Close all tabs and clear data", image: UIImage(named: "Fire"), primaryAction: nil, menu: nil)
        coordinator.toolbarTabSwitcherButton = UIBarButtonItem(title: "Tab Switcher", image: UIImage(named: "Add-24"), primaryAction: nil, menu: nil)
        coordinator.toolbarBookmarksButton = UIBarButtonItem(title: "Bookmarks", image: UIImage(named: "Book-24"), primaryAction: nil, menu: nil)
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
            coordinator.toolbarBookmarksButton!,
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

        disableAutoresizingOnViewAndSubviews(coordinator.logoContainer)
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
        constrainTabsContainer()
        constrainNavigationBarContainer()
        constrainProgress()
        constrainToolbar()
    }

    private func constrainProgress() {
        let progress = coordinator.progress!
        let navigationBarContainer = coordinator.navigationBarContainer!
        NSLayoutConstraint.activate([
            progress.constrainView(navigationBarContainer, by: .trailing),
            progress.constrainView(navigationBarContainer, by: .leading),
            progress.constrainAttribute(.height, to: 3),
            progress.constrainView(navigationBarContainer, by: .top, to: .bottom),
        ])
    }

    private func constrainNavigationBarContainer() {
        let navigationBarContainer = coordinator.navigationBarContainer!
        NSLayoutConstraint.activate([
            navigationBarContainer.constrainView(superview, by: .centerX),
            navigationBarContainer.constrainView(superview, by: .width),
            navigationBarContainer.constrainView(superview.safeAreaLayoutGuide, by: .top),
            navigationBarContainer.constrainAttribute(.height, to: 52),
        ])
    }

    private func constrainTabsContainer() {
        let tabsContainer = coordinator.tabsContainer!
        NSLayoutConstraint.activate([
            tabsContainer.constrainView(superview, by: .leading),
            tabsContainer.constrainView(superview, by: .trailing),
            tabsContainer.constrainAttribute(.height, to: 40),
            tabsContainer.constrainView(superview.safeAreaLayoutGuide, by: .top),
        ])
    }

    private func constrainStatusBackground() {
        let statusBackground = coordinator.statusBackground!
        let navigationBarContainer = coordinator.navigationBarContainer!
        NSLayoutConstraint.activate([
            statusBackground.constrainView(superview, by: .width),
            statusBackground.constrainView(superview, by: .centerX),
            statusBackground.constrainView(superview, by: .top),
            statusBackground.constrainView(navigationBarContainer, by: .bottom),
        ])
    }

    private func constrainNotificationBarContainer() {
        let notificationBarContainer = coordinator.notificationBarContainer!
        let contentContainer = coordinator.contentContainer!
        let navigationBarContainer = coordinator.navigationBarContainer!
        NSLayoutConstraint.activate([
            notificationBarContainer.constrainView(superview, by: .width),
            notificationBarContainer.constrainView(superview, by: .centerX),
            notificationBarContainer.constrainAttribute(.height, to: 0),
            notificationBarContainer.constrainView(contentContainer, by: .bottom, to: .top),
            notificationBarContainer.constrainView(navigationBarContainer, by: .top, to: .bottom),
        ])
    }

    private func constrainContentContainer() {
        let contentContainer = coordinator.contentContainer!
        let toolbar = coordinator.toolbar!
        let notificationBarContainer = coordinator.notificationBarContainer!
        NSLayoutConstraint.activate([
            contentContainer.constrainView(superview, by: .leading),
            contentContainer.constrainView(superview, by: .trailing),
            contentContainer.constrainView(toolbar, by: .bottom, to: .top),
            contentContainer.constrainView(notificationBarContainer, by: .top, to: .bottom),
        ])
    }

    private func constrainToolbar() {
        let toolbar = coordinator.toolbar!
        NSLayoutConstraint.activate([
            toolbar.constrainView(superview, by: .width),
            toolbar.constrainView(superview, by: .centerX),
            toolbar.constrainAttribute(.height, to: 49),
            toolbar.constrainView(superview.safeAreaLayoutGuide, by: .bottom),
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
            logoContainer.constrainView(superview, by: .height),
            logoContainer.constrainView(superview, by: .width),
            logoContainer.constrainView(superview, by: .centerX),
            logoContainer.constrainView(superview, by: .centerY),
            logo.constrainView(logoContainer, by: .centerX),
            logo.constrainView(logoContainer, by: .centerY, constant: -72),
            logo.constrainAttribute(.width, to: 96),
            logo.constrainAttribute(.height, to: 96),
            text.constrainView(logo, by: .top, to: .bottom),
            text.constrainView(logo, by: .centerX),
        ])
    }

}
// swiftlint:enable line_length

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
    var tabsContainer: UIView!
    var navigationBarContainer: UIView!
    var progress: UIView!
    var toolbarBackButton: UIBarButtonItem!
    var toolbarForwardButton: UIBarButtonItem!
    var toolbarFireButton: UIBarButtonItem!
    var toolbarTabSwitcherButton: UIBarButtonItem!
    var toolbarBookmarksButton: UIBarButtonItem!

    init(superview: UIView) {
        self.superview = superview
    }

    func decorateWithTheme(_ theme: Theme) {
        superview.backgroundColor = theme.mainViewBackgroundColor
        logoText.tintColor = theme.ddgTextTintColor
    }

    func hideSuggestionTray() {
        suggestionTrayContainer.isHidden = true
        suggestionTrayContainer.backgroundColor = .clear
    }

}
