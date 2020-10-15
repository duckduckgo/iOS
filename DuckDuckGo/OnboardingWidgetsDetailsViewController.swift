//
//  OnboardingWidgetsDetailsViewController.swift
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

class OnboardingWidgetsDetailsViewController: UIViewController {
    
    var navigationHandler: (() -> Void)?
    
    @IBOutlet weak var secondInstructionsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        if  let image = UIImage(named: "OnboardingWidgetInstructionsLabelImage"),
            let string = secondInstructionsLabel.text?.attributedString(
                withPlaceholder: "%@",
                replacedByImage: image,
                horizontalPadding: 3.0,
                verticalOffset: -5.0) {
            secondInstructionsLabel.attributedText = string
        }

        navigationController?.navigationBar.tintColor = .cornflowerBlue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func ctaPressed(_ sender: Any) {
        navigationHandler?()
    }
}
