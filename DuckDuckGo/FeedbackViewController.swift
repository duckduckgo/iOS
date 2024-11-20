//
//  FeedbackViewController.swift
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

class FeedbackViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIBarButtonItem!
    
    @IBOutlet weak var postitiveFeedbackButton: UIButton!
    @IBOutlet weak var negativeFeedbackButton: UIButton!
    
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var supplementaryText: UILabel!
    @IBOutlet weak var footerText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureLabels()
        configureButtons()
        decorate()
    }
    
    private func configureLabels() {
        headerText.setAttributedTextString(UserText.feedbackStartHeader)
        supplementaryText.setAttributedTextString(UserText.feedbackStartSupplementary)
        footerText.setAttributedTextString(UserText.feedbackStartFooter)
    }
    
    private func configureButtons() {
        applyShadow(to: postitiveFeedbackButton)
        applyShadow(to: negativeFeedbackButton)
    }
    
    private func applyShadow(to button: UIButton) {
        button.layer.cornerRadius = 8
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.12
        button.layer.shadowRadius = 3
    }
    
    @IBAction func onClosePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? FeedbackPickerViewController else {
            return
        }
        
        let isNavigatingToCategories = sender as? UIButton == negativeFeedbackButton
        if isNavigatingToCategories {
            controller.loadViewIfNeeded()
            controller.configure(with: Feedback.Category.allCases)
            return
        }
    }
}

extension FeedbackViewController {
    
    private func decorate() {
        let theme = ThemeManager.shared.currentTheme
        decorateNavigationBar()
        

        view.backgroundColor = theme.backgroundColor
        
        postitiveFeedbackButton.backgroundColor = theme.feedbackSentimentButtonBackgroundColor
        negativeFeedbackButton.backgroundColor = theme.feedbackSentimentButtonBackgroundColor
        
        headerText.textColor = theme.feedbackPrimaryTextColor
        supplementaryText.textColor = theme.feedbackSecondaryTextColor
        footerText.textColor = theme.feedbackSecondaryTextColor
    }
    
}
