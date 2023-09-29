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

protocol MainViewCoordinator {

    func decorateWithTheme(_ theme: Theme)

}

// swiftlint:disable line_length
class MainViewFactory {

    private let coordinator: Coordinator

    var superview: UIView {
        coordinator.superview
    }

    private init(_ superview: UIView) {
        coordinator = Coordinator(superview: superview)
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
//        coordinator.suggestionTrayContainer.backgroundColor = .clear
//        coordinator.suggestionTrayContainer.isHidden = true
        superview.addSubview(coordinator.suggestionTrayContainer)
    }

    private func createToolbar() {
        coordinator.toolbar = UIToolbar()
        superview.addSubview(coordinator.toolbar)
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
            .init(item: progress, attribute: .trailing, relatedBy: .equal, toItem: navigationBarContainer, attribute: .trailing, multiplier: 1, constant: 0),
            .init(item: progress, attribute: .leading, relatedBy: .equal, toItem: navigationBarContainer, attribute: .leading, multiplier: 1, constant: 0),
            .init(item: progress, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 3),
            .init(item: progress, attribute: .top, relatedBy: .equal, toItem: navigationBarContainer, attribute: .bottom, multiplier: 1, constant: 0),
        ])
    }

    private func constrainNavigationBarContainer() {
        let navigationBarContainer = coordinator.navigationBarContainer!
        NSLayoutConstraint.activate([
            .init(item: navigationBarContainer, attribute: .centerX, relatedBy: .equal, toItem: superview, attribute: .centerX, multiplier: 1, constant: 0),
            .init(item: navigationBarContainer, attribute: .width, relatedBy: .equal, toItem: superview, attribute: .width, multiplier: 1, constant: 0),
            .init(item: navigationBarContainer, attribute: .top, relatedBy: .equal, toItem: superview.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0),
            .init(item: navigationBarContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 52),
        ])
    }

    private func constrainTabsContainer() {
        let tabsContainer = coordinator.tabsContainer!
        NSLayoutConstraint.activate([
            .init(item: tabsContainer, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0),
            .init(item: tabsContainer, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0),
            .init(item: tabsContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 40),
            .init(item: tabsContainer, attribute: .top, relatedBy: .equal, toItem: superview.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0),
        ])
    }

    private func constrainStatusBackground() {
        let statusBackground = coordinator.statusBackground!
        let navigationBarContainer = coordinator.navigationBarContainer!
        NSLayoutConstraint.activate([
            .init(item: statusBackground, attribute: .width, relatedBy: .equal, toItem: superview, attribute: .width, multiplier: 1, constant: 0),
            .init(item: statusBackground, attribute: .centerX, relatedBy: .equal, toItem: superview, attribute: .centerX, multiplier: 1, constant: 0),
            .init(item: statusBackground, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1, constant: 0),
            .init(item: statusBackground, attribute: .bottom, relatedBy: .equal, toItem: navigationBarContainer, attribute: .bottom, multiplier: 1, constant: 0),
        ])
    }

    private func constrainNotificationBarContainer() {
        let notificationBarContainer = coordinator.notificationBarContainer!
        let contentContainer = coordinator.contentContainer!
        let navigationBarContainer = coordinator.navigationBarContainer!
        NSLayoutConstraint.activate([
            .init(item: notificationBarContainer, attribute: .width, relatedBy: .equal, toItem: superview, attribute: .width, multiplier: 1, constant: 0),
            .init(item: notificationBarContainer, attribute: .centerX, relatedBy: .equal, toItem: superview, attribute: .centerX, multiplier: 1, constant: 0),
            .init(item: notificationBarContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 5), // Initial height is zero
            .init(item: notificationBarContainer, attribute: .bottom, relatedBy: .equal, toItem: contentContainer, attribute: .top, multiplier: 1, constant: 0),
            .init(item: notificationBarContainer, attribute: .top, relatedBy: .equal, toItem: navigationBarContainer, attribute: .bottom, multiplier: 1, constant: 0),
        ])
    }

    private func constrainContentContainer() {
        let contentContainer = coordinator.contentContainer!
        let toolbar = coordinator.toolbar!
        let notificationBarContainer = coordinator.notificationBarContainer!
        NSLayoutConstraint.activate([
            .init(item: contentContainer, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0),
            .init(item: contentContainer, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0),
            .init(item: contentContainer, attribute: .bottom, relatedBy: .equal, toItem: toolbar, attribute: .top, multiplier: 1, constant: 0),
            .init(item: contentContainer, attribute: .top, relatedBy: .equal, toItem: notificationBarContainer, attribute: .bottom, multiplier: 1, constant: 0),
        ])
    }

    private func constrainToolbar() {
        let toolbar = coordinator.toolbar!
        NSLayoutConstraint.activate([
            .init(item: toolbar, attribute: .width, relatedBy: .equal, toItem: superview, attribute: .width, multiplier: 1, constant: 0),
            .init(item: toolbar, attribute: .centerX, relatedBy: .equal, toItem: superview, attribute: .centerX, multiplier: 1, constant: 0),
            .init(item: toolbar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 49),
            .init(item: toolbar, attribute: .bottom, relatedBy: .equal, toItem: superview.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0),
        ])
    }

    private func constrainSuggestionTrayContainer() {
        let suggestionTrayContainer = coordinator.suggestionTrayContainer!
        let contentContainer = coordinator.contentContainer!
        NSLayoutConstraint.activate([
            .init(item: suggestionTrayContainer, attribute: .width, relatedBy: .equal, toItem: contentContainer, attribute: .width, multiplier: 1, constant: 0),
            .init(item: suggestionTrayContainer, attribute: .height, relatedBy: .equal, toItem: contentContainer, attribute: .height, multiplier: 1, constant: 0),
            .init(item: suggestionTrayContainer, attribute: .centerX, relatedBy: .equal, toItem: contentContainer, attribute: .centerX, multiplier: 1, constant: 0),
            .init(item: suggestionTrayContainer, attribute: .centerY, relatedBy: .equal, toItem: contentContainer, attribute: .centerY, multiplier: 1, constant: 0),
        ])
    }

    private func constrainLogoBackground() {
        let logoContainer = coordinator.logoContainer!
        let logo = coordinator.logo!
        let text = coordinator.logoText!
        NSLayoutConstraint.activate([
            .init(item: logoContainer, attribute: .height, relatedBy: .equal, toItem: superview, attribute: .height, multiplier: 1, constant: 0),
            .init(item: logoContainer, attribute: .width, relatedBy: .equal, toItem: superview, attribute: .width, multiplier: 1, constant: 0),
            .init(item: logoContainer, attribute: .centerX, relatedBy: .equal, toItem: superview, attribute: .centerX, multiplier: 1, constant: 0),
            .init(item: logoContainer, attribute: .centerY, relatedBy: .equal, toItem: superview, attribute: .centerY, multiplier: 1, constant: 0),
            .init(item: logo, attribute: .centerX, relatedBy: .equal, toItem: logoContainer, attribute: .centerX, multiplier: 1, constant: 0),
            .init(item: logo, attribute: .centerY, relatedBy: .equal, toItem: logoContainer, attribute: .centerY, multiplier: 1, constant: -72),
            .init(item: logo, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 96),
            .init(item: logo, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 96),
            .init(item: text, attribute: .top, relatedBy: .equal, toItem: logo, attribute: .bottom, multiplier: 1, constant: 12),
            .init(item: text, attribute: .centerX, relatedBy: .equal, toItem: logo, attribute: .centerX, multiplier: 1, constant: 0),
        ])
    }

}
// swiftlint:enable line_length

private class Coordinator: MainViewCoordinator {

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

    init(superview: UIView) {
        self.superview = superview
    }

    func decorateWithTheme(_ theme: Theme) {
        superview.backgroundColor = theme.mainViewBackgroundColor
        logoText.tintColor = theme.ddgTextTintColor
    }

}
