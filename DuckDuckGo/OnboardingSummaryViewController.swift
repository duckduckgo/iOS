//
//  OnboardingSummaryViewController.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 22/02/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import UIKit

class OnboardingSummaryViewController: UIViewController, Onboarding {
    
    weak var delegate: OnboardingDelegate?
    
    @IBAction func done() {
        delegate?.onboardingCompleted()
    }
    
}
