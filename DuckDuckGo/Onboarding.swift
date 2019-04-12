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

protocol Onboarding {
    
    var delegate: OnboardingDelegate? { get set }
    
}

protocol OnboardingContent {
    
    var subtitle: String? { get }
    var canContinue: Bool { get }
    var delegate: OnboardingContentDelegate? { get set }

    /// Called when continue is pressed
    func finished()
    
}

protocol OnboardingDelegate: NSObjectProtocol {
    
    func onboardingCompleted(controller: UIViewController)
    
}

protocol OnboardingContentDelegate: NSObjectProtocol {
    
    func setContinueEnabled(_ enabled: Bool)
    
}

class OnboardingContentViewController: UIViewController, OnboardingContent {

    var canContinue: Bool = true
    weak var delegate: OnboardingContentDelegate?
    
    var subtitle: String? {
        return title
    }
    
    func finished() {        
    }
    
}

extension MainViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startOnboardingFlowIfNotSeenBefore()
    }
    
    func startOnboardingFlowIfNotSeenBefore() {
        
        let settings = DefaultTutorialSettings()
        guard !settings.hasSeenOnboarding else { return }
        
        // Only show tips if the user is a new one, ie they've not seen onboarding yet
        DefaultContextualTipsStorage().isEnabled = true
        
        let onboardingFlow: String
        let modalTransitionStyle: UIModalTransitionStyle
        
        modalTransitionStyle = .coverVertical
        onboardingFlow = isPad ? "Onboarding-iPad" : "Onboarding"
        
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
        
    func onboardingCompleted(controller: UIViewController) {
        markOnboardingSeen()
        controller.modalTransitionStyle = .crossDissolve
        controller.dismiss(animated: true)
        homeController?.resetHomeRowCTAAnimations()

        if AppUserDefaults().currentThemeName != ThemeManager.shared.currentTheme.name {
            reloadTheme()
        }
        
    }
    
    func markOnboardingSeen() {
        var settings = DefaultTutorialSettings()
        settings.hasSeenOnboarding = true
    }
    
}
