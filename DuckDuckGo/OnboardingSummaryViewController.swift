//
//  OnboardingSummaryViewController.swift
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

import UIKit
import Core

class OnboardingSummaryViewController: OnboardingContentViewController {
    
    @IBOutlet var bulletsStack: UIStackView!
    @IBOutlet var offsetY: NSLayoutConstraint!
    
    private var timedPixel: TimedPixel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bulletsStack.spacing = isSmall ? 8 : 12
        offsetY.constant = isSmall ? -2 : -27
        self.canContinue = true
        timedPixel = TimedPixel(.onboardingSummaryFinished)
    }
    
    override var continueButtonTitle: String {
        return UserText.onboardingStartBrowsing
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timedPixel?.fire()
    }
    
}
