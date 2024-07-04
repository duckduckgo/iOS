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
import UserNotifications

protocol Onboarding {
    
    var delegate: OnboardingDelegate? { get set }
    
}

protocol OnboardingContent {
    
    var subtitle: String? { get }
    var canContinue: Bool { get }
    var delegate: OnboardingContentDelegate? { get set }

    func onContinuePressed(navigationHandler: @escaping () -> Void)
    func onSkipPressed(navigationHandler: @escaping () -> Void)
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
    
    var header: String {
        return UserText.onboardingWelcomeHeader
    }
    
    var subtitle: String? {
        return title
    }
    
    var continueButtonTitle: String {
        return UserText.onboardingContinue
    }
    var skipButtonTitle: String {
        return UserText.onboardingSkip
    }
    
    func onContinuePressed(navigationHandler: @escaping () -> Void) {
        navigationHandler()
    }
    
    func onSkipPressed(navigationHandler: @escaping () -> Void) {
        navigationHandler()
    }
    
}
