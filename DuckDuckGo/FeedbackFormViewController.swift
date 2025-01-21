//
//  FeedbackFormViewController.swift
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
    
    enum FormType {
        case regular
        case brokenWebsite
    }
    
    private enum FormModel {
        case positive
        case negative(Feedback.Model)
    }
    
    private struct Constants {
        static let maxMessageLength = 500
        
        static let inputFieldFontSize: CGFloat = 14
        static let scrollToMargin: CGFloat = 15
        
        static let minimumMessageViewHeight: CGFloat = 60
        static let defaultMessageViewHeight: CGFloat = 150
    }
    
    @IBOutlet var headerToMessageView: NSLayoutConstraint!
    @IBOutlet var websiteFieldToMessageView: NSLayoutConstraint!
    
    @IBOutlet var messageViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var supplementaryText: UILabel!
    
    @IBOutlet weak var websiteTextField: UITextField!
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messagePlaceholderText: UILabel!
    
    @IBOutlet weak var submitFeedbackButton: UIButton!
    
    private var model: FormModel?

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
        
        decorate()
    }
    
    func configureForPositiveSentiment() {
        model = .positive
        
        loadViewIfNeeded()
        hideWebsiteField()
        
        headerImage.image = UIImage(named: "happyFace")
        
        headerText.setAttributedTextString(UserText.feedbackPositiveFormHeader)
        supplementaryText.setAttributedTextString(UserText.feedbackPositiveFormSupplementary)
        messagePlaceholderText.setAttributedTextString(UserText.feedbackPositiveFormPlaceholder)
        
        submitFeedbackButton.setTitle(UserText.feedbackFormSubmit, for: .normal)
    }
    
    func configureForNegativeSentiment(for type: FormType,
                                       with feedbackModel: Feedback.Model) {
        guard let category = feedbackModel.category else {
                fatalError("Feedback model is incomplete!")
        }
        model = .negative(feedbackModel)

        loadViewIfNeeded()
        
        headerImage.image = UIImage(named: "sadFace")
        self.headerText.text = FeedbackPresenter.title(for: category)
        
        switch type {
        case .regular:
            hideWebsiteField()
            
            if let subcategory = feedbackModel.subcategory {
                supplementaryText.setAttributedTextString(FeedbackPresenter.subtitle(for: subcategory))
            } else {
                supplementaryText.setAttributedTextString(FeedbackPresenter.subtitle(for: category))
            }
            
            messagePlaceholderText.setAttributedTextString(FeedbackPresenter.messagePlaceholder(for: feedbackModel.subcategory))
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
        ActionMessageView.present(message: UserText.feedbackSumbittedConfirmation)
        
        sendFeedback()
        dismiss(animated: true, completion: nil)
    }
    
    private func sendFeedback() {
        guard let model = model else {
            fatalError("Feedback form is mising model!")
        }
        
        let message = String(messageTextView.text.prefix(Constants.maxMessageLength))
        
        let feedbackSender = FeedbackSubmitter()
        switch model {
        case .positive:
            feedbackSender.firePositiveSentimentPixel()
            if message.trimmingWhitespace().isEmpty == false {
                feedbackSender.submitPositiveSentiment(message: message)
            }
        case .negative(let feedbackModel):
            feedbackSender.fireNegativeSentimentPixel(with: feedbackModel)
            if message.trimmingWhitespace().isEmpty == false {
                feedbackSender.submitNegativeSentiment(message: message,
                                                       url: websiteTextField.text,
                                                       model: feedbackModel)
            }
        }
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
        guard let isLocalUserInfoKey = notification.userInfo?[UIResponder.keyboardIsLocalUserInfoKey] as? NSNumber,
            isLocalUserInfoKey == true else {
                return
        }
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardSize = keyboardFrame.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        messageViewHeight.constant = Constants.defaultMessageViewHeight
        
        let interactionRect = interactionAreaForEditingMode()
        
        guard let rect = scrollView.desiredVisibleRect(forInteractionArea: interactionRect,
                                                       coveredBy: keyboardFrame) else {
                                                        return
        }
        // Note: scrollRectToVisible is not working properly in Modal view on iPad
        var offset = scrollView.contentOffset
        offset.y = rect.origin.y
        
        // Shrink message view if needed
        let visibleAreaBottom = rect.origin.y + rect.size.height
        let messageTextViewBottom = messageTextView.frame.origin.y + messageTextView.frame.size.height
        if visibleAreaBottom < messageTextViewBottom {
            messageViewHeight.constant -= (messageTextViewBottom - visibleAreaBottom) + Constants.scrollToMargin
            messageViewHeight.constant = max(Constants.minimumMessageViewHeight, messageViewHeight.constant)
            
            DispatchQueue.main.async {
                self.scrollView.setContentOffset(offset, animated: true)
                self.messageTextView.scrollRangeToVisible(self.messageTextView.selectedRange)
            }
        } else {
            // This is async to override ScrollView automatic offset setting for UITextField.
            // It caused inconsistency between how Message View and Website Text Field handled becoming a first responder.
            DispatchQueue.main.async {
                self.scrollView.setContentOffset(offset, animated: true)
            }
        }
    }
    
    /// Calculate the area that is most relevant to the user when typing a feedback message.
    private func interactionAreaForEditingMode() -> CGRect {
        let upperLeftInteractionArea: CGPoint
        if websiteTextField.isHidden == false {
            upperLeftInteractionArea = websiteTextField.frame.origin
        } else {
            upperLeftInteractionArea = messageTextView.frame.origin
        }
        var lowerRightInteractionArea = submitFeedbackButton.frame.origin
        lowerRightInteractionArea.x += submitFeedbackButton.frame.size.width
        lowerRightInteractionArea.y += submitFeedbackButton.frame.size.height
        
        return CGRect(x: upperLeftInteractionArea.x,
                      y: upperLeftInteractionArea.y,
                      width: lowerRightInteractionArea.x - upperLeftInteractionArea.x,
                      height: lowerRightInteractionArea.y - upperLeftInteractionArea.y)
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let isLocalUserInfoKey = notification.userInfo?[UIResponder.keyboardIsLocalUserInfoKey] as? NSNumber,
            isLocalUserInfoKey == true else {
                return
        }
        
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        messageViewHeight.constant = Constants.defaultMessageViewHeight
    }
}

extension FeedbackFormViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        paragraphStyle.firstLineHeadIndent = 3
        paragraphStyle.lineHeightMultiple = 1.35
        
        let font = UIFont.appFont(ofSize: Constants.inputFieldFontSize)
        
        let attributes = [ NSAttributedString.Key.font: font,
                           NSAttributedString.Key.foregroundColor: ThemeManager.shared.currentTheme.textFieldFontColor,
                           NSAttributedString.Key.paragraphStyle: paragraphStyle]
        textView.typingAttributes = attributes
    }
    
    func textViewDidChange(_ textView: UITextView) {
        messagePlaceholderText.isHidden = !textView.text.isEmpty
        refreshSubmitFeedbackButton()
    }
}

extension FeedbackFormViewController {
    
    private func decorate() {
        let theme = ThemeManager.shared.currentTheme
        view.backgroundColor = theme.backgroundColor
        
        headerText.textColor = theme.feedbackPrimaryTextColor
        supplementaryText.textColor = theme.feedbackSecondaryTextColor
        
        messagePlaceholderText.textColor = ThemeManager.shared.currentTheme.placeholderColor
        
        messageTextView.backgroundColor = theme.textFieldBackgroundColor
        messageTextView.keyboardAppearance = theme.keyboardAppearance
        websiteTextField.backgroundColor = theme.textFieldBackgroundColor
        websiteTextField.textColor = theme.textFieldFontColor
        websiteTextField.keyboardAppearance = theme.keyboardAppearance
        configureWebsiteField(with: websiteTextField.placeholder ?? "")
        
        submitFeedbackButton.setTitleColor(UIColor.white, for: .normal)
        submitFeedbackButton.tintColor = theme.buttonTintColor
    }
    
}
