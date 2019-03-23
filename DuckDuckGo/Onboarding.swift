//
//  Onboarding.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

import Foundation
import Core

protocol OnboardingDelegate: NSObjectProtocol {
    
    func onboardingCompleted(controller: UIViewController)
 
    func customizeSettings(controller: UIViewController)
    
    func explorePrivacyFeatures(controller: UIViewController)
    
}

protocol Onboarding {
    
    var delegate: OnboardingDelegate? { get set }
    
}

extension MainViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startOnboardingFlowIfNotSeenBefore()
    }
    
    func startOnboardingFlowIfNotSeenBefore() {
        
        let settings = DefaultTutorialSettings()
        guard !settings.hasSeenOnboarding else { return }
        
        let onboardingFlow: String
        let modalTransitionStyle: UIModalTransitionStyle
        
        if DefaultVariantManager().isSupported(feature: .onboardingSummary) {
            modalTransitionStyle = .coverVertical
            onboardingFlow = isPad ? "OnboardingSummary-iPad" : "OnboardingSummary"
        } else {
            modalTransitionStyle = .flipHorizontal
            onboardingFlow = "Onboarding"
        }
        
        guard let controller = UIStoryboard(name: onboardingFlow, bundle: nil).instantiateInitialViewController() else {
            fatalError("instantiateInitialViewController for \(onboardingFlow)")
        }

        if var onboarding = controller as? Onboarding {
            onboarding.delegate = self
        }
        
        controller.modalTransitionStyle = modalTransitionStyle
        present(controller, animated: true)
        homeController?.resetHomeRowCTAAnimations()
    }
    
}

extension MainViewController: OnboardingDelegate {
    
    static var onboardingSettingsPixelFired = false
    
    func customizeSettings(controller: UIViewController) {
        if !MainViewController.onboardingSettingsPixelFired {
            Pixel.fire(pixel: .onboardingCustomizeSettings)
            MainViewController.onboardingSettingsPixelFired = true
        }

        let settingsContainer = SettingsViewController.loadFromStoryboard()
        guard let settings = settingsContainer.children[0] as? SettingsViewController else {
            fatalError("Failed to find \(SettingsViewController.self)")
        }
        settings.homePageSettingsDelegate = self

        controller.present(settingsContainer, animated: true)
    }
    
    func explorePrivacyFeatures(controller: UIViewController) {
        Pixel.fire(pixel: .onboardingExplorePrivacy)

        let webContainer = WebContainerNavigationController.load(
            url: URL(string: "https://duckduckgo.com/app_info#scrollpos")!,
            withTitle: UserText.privacyFeatures)

        controller.present(webContainer, animated: true)
    }
    
    func onboardingCompleted(controller: UIViewController) {
        markOnboardingSeen()
        if DefaultVariantManager().isSupported(feature: .onboardingSummary) {
            controller.modalTransitionStyle = .crossDissolve
        } else {
            controller.modalTransitionStyle = .flipHorizontal
        }
        controller.dismiss(animated: true)
        homeController?.resetHomeRowCTAAnimations()
    }
    
    func markOnboardingSeen() {
        var settings = DefaultTutorialSettings()
        settings.hasSeenOnboarding = true
    }
    
}
