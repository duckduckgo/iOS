//
//  OnboardingSummaryViewController.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 10/04/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import UIKit

class OnboardingSummaryViewController: OnboardingContentViewController {
    
    @IBOutlet var bulletsStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bulletsStack.spacing = isSmall ? 8 : 12
    }
    
}
