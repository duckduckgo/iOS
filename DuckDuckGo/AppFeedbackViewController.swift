//
//  AppFeedbackViewController.swift
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

class AppFeedbackViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIBarButtonItem!
    
    @IBOutlet weak var postitiveFeedbackButton: UIButton!
    @IBOutlet weak var negativeFeedbackButton: UIButton!
    
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var supplementaryText: UILabel!
    @IBOutlet weak var footerText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureButtons()
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    private func configureButtons() {
        postitiveFeedbackButton.round(corners: .allCorners, radius: 8)
        negativeFeedbackButton.round(corners: .allCorners, radius: 8)
    }
    
    @IBAction func onClosePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? CategorizedFeedbackViewController else {
            return
        }
        
        let isNavigatingToCategories = sender as? UIButton == negativeFeedbackButton
        if isNavigatingToCategories {
            controller.loadViewIfNeeded()
            controller.configure(with: DisambiguatedFeedbackCategory.allCases)
            controller.setSelectionHandler { [weak self, controller] categoryString in
                if let category = DisambiguatedFeedbackCategory(rawValue: categoryString) {
                    if category == .otherIssues {
                        controller.performSegue(withIdentifier: "PresentSubmitFeedback", sender: nil)
                        return
                    }
                    
                    if category == .websiteLoadingIssues {
                        return
                    }
                }
                
                self?.performSegue(withIdentifier: "PresentCategories", sender: controller)
            }
            return
        }
        
        if let senderVC = sender as? CategorizedFeedbackViewController {
            guard let selectedCategoryString = senderVC.selectedCategory,
                let category = DisambiguatedFeedbackCategory(rawValue: selectedCategoryString) else {
                return
            }

            controller.loadViewIfNeeded()
            controller.configureForSubcategories(with: category)
            controller.setSelectionHandler { [weak controller] _ in
                controller?.performSegue(withIdentifier: "PresentSubmitFeedback", sender: nil)
            }
        }
        
    }
}

extension AppFeedbackViewController {
    
    func presentSubcategories(for category: DisambiguatedFeedbackCategory) {
        
    }
    
    func presentFeedbackForm(for category: DisambiguatedFeedbackCategory, subcategory: String) {
        
    }
}

extension AppFeedbackViewController: Themable {
    
    func decorate(with theme: Theme) {
        decorateNavigationBar(with: theme)
        
        view.backgroundColor = theme.backgroundColor
        
        postitiveFeedbackButton.backgroundColor = theme.feedbackSentimentButtonBackgroundColor
        negativeFeedbackButton.backgroundColor = theme.feedbackSentimentButtonBackgroundColor
        
        headerText.textColor = theme.feedbackPrimaryTextColor
        supplementaryText.textColor = theme.feedbackSecondaryTextColor
        footerText.textColor = theme.feedbackSecondaryTextColor
    }
    
}
