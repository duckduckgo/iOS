//
//  OnboardingWidgetsViewController.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

import UIKit
import Core

class OnboardingWidgetsViewController: OnboardingContentViewController {
    
    override var header: String {
        return UserText.onboardingWidgetsHeader
    }
    
    override var continueButtonTitle: String {
        return UserText.onboardingWidgetsContinueButtonText
    }
    
    override var skipButtonTitle: String {
        return UserText.onboardingWidgetsSkipButtonText
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackground(notification:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
    }
    
    override func onContinuePressed(navigationHandler: @escaping () -> Void) {
        Pixel.fire(pixel: .widgetsOnboardingCTAPressed)
        
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "onboardingWidgetDetails")
                as? OnboardingWidgetsDetailsViewController
        else {
                fatalError("Unable to load widget details view controller")
        }
        controller.navigationHandler = {
            super.onContinuePressed(navigationHandler: navigationHandler)
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func onSkipPressed(navigationHandler: @escaping () -> Void) {
        super.onSkipPressed(navigationHandler: navigationHandler)
        Pixel.fire(pixel: .widgetsOnboardingDeclineOptionPressed)
    }
    
    @objc func didEnterBackground(notification: NSNotification) {
        Pixel.fire(pixel: .widgetsOnboardingMovedToBackground)
    }
}
