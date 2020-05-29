//
//  DaxOnboardingPadViewController.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 29/05/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit

class DaxOnboardingPadViewController: UIViewController, Onboarding {

    weak var delegate: OnboardingDelegate?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let onboarding = segue.destination as? OnboardingViewController {
            onboarding.delegate = delegate
            onboarding.updateForDaxOnboarding()
        }
    }

}
