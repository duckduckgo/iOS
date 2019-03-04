//
//  ShareFeedbackViewController.swift
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

class SubmitFeedbackViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var supplementaryText: UILabel!
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messagePlaceholderText: UILabel!
    
    @IBOutlet weak var submitFeedbackButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForKeyboardNotifications()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    func configureForPositiveSentiment() {
        headerImage.image = UIImage(named: "happyFace")
        headerText.text = "Share Feedback"
        supplementaryText.text = "Are there any details you’d like to share with the team?"
    }
    
    func configureForNegativeSentiment(headerText: String, detailsText: String) {
        headerImage.image = UIImage(named: "sadFace")
        self.headerText.text = headerText
        supplementaryText.text = detailsText
    }
    
    @IBAction func submitFeedbackPressed() {
        // TODO
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    private func refreshSubmitFeedbackButton() {
        submitFeedbackButton.isEnabled = !messageTextView.text.isEmpty
    }
    
    // MARK: Keyboard
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc private func keyboardDidShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardSize = keyboardFrame.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        guard messageTextView.isFirstResponder else { return }
        var rect = self.view.frame
        rect.size.height -= keyboardSize.height
        
        let messageViewFrame = messageTextView.frame
        let messageViewBottom = CGPoint(x: messageViewFrame.origin.x,
                                        y: messageViewFrame.origin.y + messageViewFrame.size.height)
        if !rect.contains(messageViewBottom) {
            scrollView.scrollRectToVisible(messageTextView.frame, animated: true)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}

extension SubmitFeedbackViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        messagePlaceholderText.isHidden = !textView.text.isEmpty
        refreshSubmitFeedbackButton()
    }
}

extension SubmitFeedbackViewController: Themable {
    
    func decorate(with theme: Theme) {
        view.backgroundColor = theme.backgroundColor
        
        headerText.textColor = theme.feedbackPrimaryTextColor
        supplementaryText.textColor = theme.feedbackSecondaryTextColor
        
        submitFeedbackButton.setTitleColor(UIColor.white, for: .normal)
        submitFeedbackButton.tintColor = theme.buttonTintColor
    }
    
}
