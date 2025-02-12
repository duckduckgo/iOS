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
import BrowserServicesKit
import AIChat

class MainViewFactory {

    private let coordinator: MainViewCoordinator
    private let featureFlagger: FeatureFlagger
    private let omnibarDependencies: OmnibarDependencyProvider

    var superview: UIView {
        coordinator.superview
    }

    private init(superview: UIView, omnibarDependencies: OmnibarDependencyProvider, featureFlagger: FeatureFlagger) {
        coordinator = MainViewCoordinator(superview: superview)
        self.featureFlagger = featureFlagger
        self.omnibarDependencies = omnibarDependencies
    }

    static func createViewHierarchy(_ superview: UIView,
                                    aiChatSettings: AIChatSettingsProvider,
                                    voiceSearchHelper: VoiceSearchHelperProtocol,
                                    featureFlagger: FeatureFlagger) -> MainViewCoordinator {
        let omnibarDependencies = OmnibarDependencies(voiceSearchHelper: voiceSearchHelper,
                                                      featureFlagger: featureFlagger,
                                                      aiChatSettings: aiChatSettings)
        let factory = MainViewFactory(superview: superview, omnibarDependencies: omnibarDependencies, featureFlagger: featureFlagger)
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
        createTopSlideContainer()
        createStatusBackground()
        createTabBarContainer()
        createOmniBar()
        createToolbar()
        createNavigationBarContainer()
        createNavigationBarCollectionView()
        createProgressView()
    }
    
    private func createProgressView() {
        coordinator.progress = ProgressView()
        superview.addSubview(coordinator.progress)
    }

    private func createOmniBar() {
        coordinator.omniBar = OmniBar.loadFromXib(dependencies: omnibarDependencies)
        coordinator.omniBar.translatesAutoresizingMaskIntoConstraints = false
    }
    
    final class NavigationBarCollectionView: UICollectionView {
        
        var hitTestInsets = UIEdgeInsets.zero
        
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            return bounds.inset(by: hitTestInsets).contains(point)
        }
        
        // Don't allow the use to drag the scrollbar or the UI will glitch.
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            let view = super.hitTest(point, with: event)
            if view == self.subviews.first(where: { $0 is UIImageView }) {
                return nil
            }
            return view
        }
    }
    
    private func createNavigationBarCollectionView() {
        // Layout is replaced elsewhere, but required to construct the view.
        coordinator.navigationBarCollectionView = NavigationBarCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        // scrollview subclasses change the default to true, but we need this for the separator on the omnibar
        coordinator.navigationBarCollectionView.clipsToBounds = false
        
        coordinator.navigationBarCollectionView.translatesAutoresizingMaskIntoConstraints = false
        coordinator.navigationBarContainer.addSubview(coordinator.navigationBarCollectionView)
    }
    
    final class NavigationBarContainer: UIView { }
    private func createNavigationBarContainer() {
        coordinator.navigationBarContainer = NavigationBarContainer()
        superview.addSubview(coordinator.navigationBarContainer)
    }

    final class ContentContainer: UIView { }
    private func createContentContainer() {
        coordinator.contentContainer = ContentContainer()
        superview.addSubview(coordinator.contentContainer)
    }

    final class StatusBackgroundView: UIView { }
    private func createStatusBackground() {
        coordinator.statusBackground = StatusBackgroundView()
        superview.addSubview(coordinator.statusBackground)
    }

    final class TabBarContainer: UIView { }
    private func createTabBarContainer() {
        coordinator.tabBarContainer = TabBarContainer()
        superview.addSubview(coordinator.tabBarContainer)
    }

    final class SuggestionTrayContainer: UIView { }
    private func createSuggestionTrayContainer() {
        coordinator.suggestionTrayContainer = SuggestionTrayContainer()
        coordinator.suggestionTrayContainer.isHidden = true
        coordinator.suggestionTrayContainer.backgroundColor = .clear
        superview.addSubview(coordinator.suggestionTrayContainer)
    }

    private func createToolbar() {

        coordinator.toolbar = HitTestingToolbar()
        coordinator.toolbar.isTranslucent = false
        superview.addSubview(coordinator.toolbar)
        coordinator.toolbarHandler = ToolbarHandler(toolbar: coordinator.toolbar, featureFlagger: featureFlagger)
        coordinator.updateToolbarWithState(.newTab)
    }

    final class LogoBackgroundView: UIView { }
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

    final class TopSlideContainer: UIView { }
    private func createTopSlideContainer() {
        coordinator.topSlideContainer = TopSlideContainer()
        coordinator.topSlideContainer.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(coordinator.topSlideContainer)
    }

}

/// Add constraint functions
extension MainViewFactory {

    private func constrainViews() {
        constrainLogoBackground()
        constrainTopSlideContainer()
        constrainContentContainer()
        constrainSuggestionTrayContainer()
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
        let container = coordinator.navigationBarContainer!
        let toolbar = coordinator.toolbar!
        let navigationBarCollectionView = coordinator.navigationBarCollectionView!

        coordinator.constraints.navigationBarContainerTop = container.constrainView(superview.safeAreaLayoutGuide, by: .top)
        coordinator.constraints.navigationBarContainerBottom = container.constrainView(toolbar, by: .bottom, to: .top)
        coordinator.constraints.navigationBarContainerHeight = container.constrainAttribute(.height, to: 52, relatedBy: .equal)

        NSLayoutConstraint.activate([
            coordinator.constraints.navigationBarContainerTop,
            container.constrainView(superview, by: .leading),
            container.constrainView(superview, by: .trailing),
            coordinator.constraints.navigationBarContainerHeight,
            navigationBarCollectionView.constrainAttribute(.height, to: 52),
            navigationBarCollectionView.constrainView(container, by: .top),
            navigationBarCollectionView.constrainView(container, by: .leading),
            navigationBarCollectionView.constrainView(container, by: .trailing),
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

        coordinator.constraints.statusBackgroundToNavigationBarContainerBottom
            = statusBackground.constrainView(navigationBarContainer, by: .bottom)

        coordinator.constraints.statusBackgroundBottomToSafeAreaTop
            = statusBackground.constrainView(coordinator.superview.safeAreaLayoutGuide, by: .bottom, to: .top)

        NSLayoutConstraint.activate([
            statusBackground.constrainView(superview, by: .width),
            statusBackground.constrainView(superview, by: .centerX),
            statusBackground.constrainView(superview, by: .top),
            coordinator.constraints.statusBackgroundToNavigationBarContainerBottom,
        ])
    }

    private func constrainContentContainer() {
        let contentContainer = coordinator.contentContainer!
        let toolbar = coordinator.toolbar!
        let navigationBarContainer = coordinator.navigationBarContainer!

        coordinator.constraints.contentContainerTop = contentContainer.constrainView(coordinator.topSlideContainer!, by: .top, to: .bottom)
        coordinator.constraints.contentContainerBottomToToolbarTop = contentContainer.constrainView(toolbar, by: .bottom, to: .top)
        coordinator.constraints.contentContainerBottomToNavigationBarContainerTop
            = contentContainer.constrainView(navigationBarContainer, by: .bottom, to: .top)

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

    private func constrainTopSlideContainer() {
        let topSlideContainer = coordinator.topSlideContainer!
        let navigationBarContainer = coordinator.navigationBarContainer!
        let statusBackground = coordinator.statusBackground!

        coordinator.constraints.topSlideContainerTopToNavigationBar = topSlideContainer.constrainView(navigationBarContainer, by: .top, to: .bottom)
        coordinator.constraints.topSlideContainerTopToStatusBackground = topSlideContainer.constrainView(statusBackground, by: .top, to: .bottom)

        coordinator.constraints.topSlideContainerBottomToNavigationBarBottom = topSlideContainer.constrainView(navigationBarContainer, by: .bottom)
        coordinator.constraints.topSlideContainerBottomToStatusBackgroundBottom = topSlideContainer.constrainView(statusBackground, by: .bottom)

        coordinator.constraints.topSlideContainerHeight = topSlideContainer.constrainAttribute(.height, to: 0, relatedBy: .greaterThanOrEqual)

        NSLayoutConstraint.activate([
            topSlideContainer.constrainView(superview, by: .width),
            topSlideContainer.constrainView(superview, by: .centerX),
            coordinator.constraints.topSlideContainerHeight,
            coordinator.constraints.topSlideContainerBottomToNavigationBarBottom,
        ])
    }

}
