//
//  DaxOnboardingViewController.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 12/05/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit

class DaxOnboardingViewController: UIViewController, Onboarding {
    
    weak var delegate: OnboardingDelegate?
    
    @IBAction func onDismiss() {
        delegate?.onboardingCompleted(controller: self)
    }
    
}
