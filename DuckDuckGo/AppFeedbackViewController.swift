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
            controller.setSelectionHandler { [weak self, controller] model in
                self?.categoriesScreen(controller, didFinishSelection: model)
            }
            return
        }
        
        if let model = sender as? DisambiguatedFeedbackModel {
            controller.loadViewIfNeeded()
            controller.configureForSubcategories(with: model)
            controller.setSelectionHandler { [weak controller] model in
                controller?.performSegue(withIdentifier: "PresentSubmitFeedback", sender: model)
            }
        }
        
    }
}

extension AppFeedbackViewController {
    
    func categoriesScreen(_ controller: UIViewController, didFinishSelection model: DisambiguatedFeedbackModel) {
        if model.category == .otherIssues {
            controller.performSegue(withIdentifier: "PresentSubmitFeedback", sender: model)
            return
        }
        
        if model.category == .websiteLoadingIssues {
            controller.performSegue(withIdentifier: "PresentBrokenSiteForm", sender: model)
            return
        }
        
        performSegue(withIdentifier: "PresentCategories", sender: model)
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
