//
//  FeedbackNavigator.swift
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

class FeedbackNavigator {
    
    static func navigate(to nextStep: Feedback.NextStep,
                         from controller: UIViewController,
                         with model: Feedback.Model) {
        switch nextStep {
        case .presentEntries(let entries):
            navigateToFeedbackPicker(with: entries, model: model, from: controller)
        case .presentForm(let formType):
            navigateToFeedbackForm(of: formType, with: model, from: controller)
        }
    }
    
    private static func navigateToFeedbackPicker(with entries: [FeedbackEntry],
                                                 model: Feedback.Model,
                                                 from controller: UIViewController) {
        let pickerViewController = FeedbackPickerViewController.loadFromStoryboard()
        pickerViewController.configureFor(entries: entries, with: model)
        controller.navigationController?.pushViewController(pickerViewController, animated: true)
    }
    
    private static func navigateToFeedbackForm(of type: FeedbackFormViewController.FormType,
                                               with model: Feedback.Model,
                                               from controller: UIViewController) {
        let formViewController = FeedbackFormViewController.loadFromStoryboard()
        
        formViewController.configureForNegativeSentiment(for: type, with: model)
        controller.navigationController?.pushViewController(formViewController, animated: true)
    }
}
