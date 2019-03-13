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

class FeedbackFormViewController: UIViewController {
    
    private struct Constants {
        static let inputFieldFontSize: CGFloat = 14
    }
    
    @IBOutlet var headerToMessageView: NSLayoutConstraint!
    @IBOutlet var websiteFieldToMessageView: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var supplementaryText: UILabel!
    
    @IBOutlet weak var websiteTextField: UITextField!
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messagePlaceholderText: UILabel!
    
    @IBOutlet weak var submitFeedbackButton: UIButton!
    
    static func loadFromStoryboard() -> FeedbackFormViewController {
        let storyboard = UIStoryboard(name: "Feedback", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "FeedbackForm") as? FeedbackFormViewController else {
            fatalError("Failed to load view controller for Feedback Form")
        }
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForKeyboardNotifications()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    func configureForPositiveSentiment() {
        loadViewIfNeeded()
        hideWebsiteField()
        
        headerImage.image = UIImage(named: "happyFace")
        
        headerText.setAttributedTextString(UserText.feedbackPositiveFormHeader)
        supplementaryText.setAttributedTextString(UserText.feedbackPositiveFormSupplementary)
        messagePlaceholderText.setAttributedTextString(UserText.feedbackPositiveFormPlaceholder)
        
        submitFeedbackButton.setTitle(UserText.feedbackFormSubmit, for: .normal)
    }
    
    func configureForNegativeSentiment(for type: Feedback.SubmitFormType,
                                       with model: Feedback.Model) {
        guard let category = model.category else {
                fatalError("Feedback model is incomplete!")
        }
        
        loadViewIfNeeded()
        
        headerImage.image = UIImage(named: "sadFace")
        self.headerText.text = FeedbackPresenter.title(for: category)
        
        switch type {
        case .regular:
            hideWebsiteField()
            
            if let subcategory = model.subcategory {
                if subcategory.isGeneric {
                    supplementaryText.setAttributedTextString(UserText.feedbackFormCaption)
                    messagePlaceholderText.setAttributedTextString(UserText.feedbackNegativeFormGenericPlaceholder)
                } else {
                    supplementaryText.setAttributedTextString(subcategory.userText)
                    messagePlaceholderText.setAttributedTextString(UserText.feedbackNegativeFormPlaceholder)
                }
            } else {
                supplementaryText.setAttributedTextString(FeedbackPresenter.subtitle(for: category))
                messagePlaceholderText.setAttributedTextString(UserText.feedbackNegativeFormGenericPlaceholder)
            }
        case .brokenWebsite:
            supplementaryText.setAttributedTextString(UserText.websiteLoadingIssuesFormSupplementary)
            configureWebsiteField(with: UserText.websiteLoadingIssuesFormURLPlaceholder)
            messagePlaceholderText.setAttributedTextString(UserText.websiteLoadingIssuesFormPlaceholder)
        }
    }
    
    private func hideWebsiteField() {
        websiteTextField.isHidden = true
        websiteFieldToMessageView.isActive = false
        headerToMessageView.isActive = true
        
        view.layoutIfNeeded()
    }
    
    private func configureWebsiteField(with placeholder: String) {
        let font = UIFont.appFont(ofSize: Constants.inputFieldFontSize)
        let placeholderAttributes = [ NSAttributedString.Key.font: font,
                           NSAttributedString.Key.foregroundColor: ThemeManager.shared.currentTheme.placeholderColor]

        websiteTextField.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                                    attributes: placeholderAttributes)
    }
    
    @IBAction func submitFeedbackPressed() {
        view.window?.makeToast(UserText.feedbackSumbittedConfirmation)
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

extension FeedbackFormViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        paragraphStyle.firstLineHeadIndent = 3
        
        let font = UIFont.appFont(ofSize: Constants.inputFieldFontSize)
        
        let attributes = [ NSAttributedString.Key.font: font,
                                      NSAttributedString.Key.foregroundColor: UIColor.black,
                                      NSAttributedString.Key.paragraphStyle: paragraphStyle]
        textView.typingAttributes = attributes
    }
    
    func textViewDidChange(_ textView: UITextView) {
        messagePlaceholderText.isHidden = !textView.text.isEmpty
        refreshSubmitFeedbackButton()
    }
}

extension FeedbackFormViewController: Themable {
    
    func decorate(with theme: Theme) {
        view.backgroundColor = theme.backgroundColor
        
        headerText.textColor = theme.feedbackPrimaryTextColor
        supplementaryText.textColor = theme.feedbackSecondaryTextColor
        
        configureWebsiteField(with: websiteTextField.placeholder ?? "")
        messagePlaceholderText.textColor = ThemeManager.shared.currentTheme.placeholderColor
        
        submitFeedbackButton.setTitleColor(UIColor.white, for: .normal)
        submitFeedbackButton.tintColor = theme.buttonTintColor
    }
    
}
