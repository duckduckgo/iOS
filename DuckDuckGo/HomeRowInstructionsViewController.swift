//
//  HomeRowInstructionsViewController.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 29/04/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit

class HomeRowInstructionsViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.blur(style: .dark)
        
        for view in [containerView, button] {
            view?.layer.cornerRadius = 5
            view?.layer.masksToBounds = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        HomeRowOnboardingFeature().dismissed()
    }
 
    @IBAction func dismiss() {
        dismiss(animated: true)
    }
    
}
