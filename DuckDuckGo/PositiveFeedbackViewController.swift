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
    
    @IBOutlet weak var leaveFeedbackButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLabels()
        configureButtons()

        decorate()
    }
    
    private func configureLabels() {
        headerText.setAttributedTextString(UserText.feedbackPositiveHeader)
        
        leaveFeedbackButton.setTitle(UserText.feedbackPositiveShare, for: .normal)
        doneButton.setTitle(UserText.feedbackPositiveNoThanks, for: .normal)
    }
    
    private func configureButtons() {
        leaveFeedbackButton.layer.borderWidth = 1
    }
        
    @IBAction func doneButtonPressed() {
        FeedbackSubmitter().firePositiveSentimentPixel()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let feedbackForm = segue.destination as? FeedbackFormViewController else {
            return
        }
        
        feedbackForm.configureForPositiveSentiment()
    }
}

extension PositiveFeedbackViewController {
    
    private func decorate() {
        let theme = ThemeManager.shared.currentTheme
        view.backgroundColor = theme.backgroundColor
        
        headerText.textColor = theme.feedbackPrimaryTextColor
        
        leaveFeedbackButton.setTitleColor(theme.buttonTintColor, for: .normal)
        leaveFeedbackButton.layer.borderColor = theme.buttonTintColor.cgColor
        
        doneButton.setTitleColor(theme.buttonTintColor, for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            leaveFeedbackButton.layer.borderColor = ThemeManager.shared.currentTheme.buttonTintColor.cgColor
        }
    }
}
