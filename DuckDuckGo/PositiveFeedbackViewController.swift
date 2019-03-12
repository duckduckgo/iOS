//
//  PositiveFeedbackViewController.swift
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

class PositiveFeedbackViewController: UIViewController {
    
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var supplementaryText: UILabel!
    
    @IBOutlet weak var rateAppButton: UIButton!
    @IBOutlet weak var leaveFeedbackButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLabels()
        configureButtons()

        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    private func configureLabels() {
        headerText.setAttributedTextString(UserText.feedbackPositiveHeader)
        supplementaryText.setAttributedTextString(UserText.feedbackPositiveSupplementary)
        
        rateAppButton.setTitle(UserText.feedbackPositiveRate, for: .normal)
        leaveFeedbackButton.setTitle(UserText.feedbackPositiveShare, for: .normal)
        dismissButton.setTitle(UserText.feedbackPositiveNoThanks, for: .normal)
    }
    
    private func configureButtons() {
        leaveFeedbackButton.layer.borderWidth = 1
    }
    
    @IBAction func rateAppButtonPressed() {
        let urlStr = "itms://itunes.apple.com/us/app/duckduckgo-privacy-browser/id663592361"

        UIApplication.shared.open(URL(string: urlStr)!)
    }
    
    @IBAction func leaveFeedbackPressed() {
//        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension PositiveFeedbackViewController: Themable {
    
    func decorate(with theme: Theme) {
        view.backgroundColor = theme.backgroundColor
        
        headerText.textColor = theme.feedbackPrimaryTextColor
        supplementaryText.textColor = theme.feedbackSecondaryTextColor
        
        rateAppButton.setTitleColor(UIColor.white, for: .normal)
        rateAppButton.tintColor = theme.buttonTintColor
        
        leaveFeedbackButton.setTitleColor(theme.buttonTintColor, for: .normal)
        leaveFeedbackButton.layer.borderColor = theme.buttonTintColor.cgColor
        
        dismissButton.setTitleColor(theme.buttonTintColor, for: .normal)
    }
    
}
