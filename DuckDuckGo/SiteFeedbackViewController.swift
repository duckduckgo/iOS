//
//  SiteFeedbackViewController.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

import Foundation

import UIKit
import Core
import ToastSwiftFramework

class SiteFeedbackViewController: UIViewController {

    private struct ViewConstants {
        static let urlTextHeight: CGFloat = 38
        static let urlTextPadding: CGFloat = 4
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var domainDescriptionLabel: UILabel!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messagePlaceholderText: UILabel!
    @IBOutlet weak var submitButton: UIButton!

    private var feedbackModel = SiteFeedbackModel()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationCapturesStatusBarAppearance = true
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        view.blur(style: .dark)
        loadModel()
        configureViews()
        registerForKeyboardNotifications()
        refreshButton()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }

    func prepareForSegue(url: String?) {
        feedbackModel.url = url
    }

    private func loadModel() {
        if let message = feedbackModel.message {
            messageTextView.attributedText = messageTextView.attributedText?.withText(message)
        }
        
        if let url = feedbackModel.url {
            urlTextField.attributedText = urlTextField.attributedText?.withText(url)
        }
    }

    private func configureViews() {
        urlTextField.layer.borderWidth = 1
        urlTextField.layer.borderColor = UIColor.mercury.cgColor
        urlTextField.placeholder = UserText.siteFeedbackURLPlaceholder
        
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.borderColor = UIColor.mercury.cgColor
        
        messagePlaceholderText.setAttributedTextString(UserText.siteFeedbackMessagePlaceholder)
        
        titleLabel.text = UserText.siteFeedbackTitle
        subtitleLabel.text = UserText.siteFeedbackSubtitle
        domainDescriptionLabel.text = UserText.siteFeedbackDomainInfo
    }

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
        
        let interactionRect = interactionAreaForEditingMode()
        guard let rect = scrollView.desiredVisibleRect(forInteractionArea: interactionRect,
                                                       coveredBy: keyboardFrame) else {
                                                        return
        }
        
        // Note: scrollRectToVisible is not working properly in Modal view on iPad
        var offset = scrollView.contentOffset
        offset.y = rect.origin.y
        
        DispatchQueue.main.async {
            self.scrollView.setContentOffset(offset, animated: true)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    /// Calculate the area that is most relevant to the user when typing a feedback message.
    private func interactionAreaForEditingMode() -> CGRect {
        let urlFieldOrigin = urlTextField.convert(CGPoint.zero, to: scrollView)
        let submitButtonOrigin = submitButton.convert(CGPoint.zero, to: scrollView)
        let upperLeftInteractionArea = urlFieldOrigin
        var lowerRightInteractionArea = submitButtonOrigin
        lowerRightInteractionArea.x += submitButton.frame.size.width
        lowerRightInteractionArea.y += submitButton.frame.size.height
        
        return CGRect(x: upperLeftInteractionArea.x,
                      y: upperLeftInteractionArea.y,
                      width: lowerRightInteractionArea.x - upperLeftInteractionArea.x,
                      height: lowerRightInteractionArea.y - upperLeftInteractionArea.y)
    }
    
    @IBAction func onTapped(_ sender: Any) {
        firstResponder()?.resignFirstResponder()
    }

    private func firstResponder() -> UIView? {
        if urlTextField.isFirstResponder {
            return urlTextField
        }
        if messageTextView.isFirstResponder {
            return messageTextView
        }
        return nil
    }

    private func updateMessagePlaceholder(withText text: String) {
        messagePlaceholderText.setAttributedTextString(text)
    }

    @IBAction func onUrlChanged(_ sender: UITextField) {
        feedbackModel.url = sender.text
        refreshButton()
    }

    private func showMessagePlaceholder() {
        messagePlaceholderText.isHidden = false
    }

    private func hideMessagePlaceholder() {
        messagePlaceholderText.isHidden = true
    }

    private func refreshButton() {
        submitButton.isEnabled = feedbackModel.canSubmit()
        submitButton.backgroundColor = submitButton.isEnabled ? UIColor.cornflowerBlue : UIColor.mercury
    }

    @IBAction func onClosePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onSubmitPressed(_ sender: Any) {
        feedbackModel.submit()
        view.window?.makeToast(UserText.feedbackSumbittedConfirmation)
        dismiss(animated: true, completion: nil)
    }
}

extension SiteFeedbackViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        paragraphStyle.firstLineHeadIndent = 3
        paragraphStyle.lineHeightMultiple = 1.35
        
        let font = UIFont.appFont(ofSize: 14)
        
        let attributes = [ NSAttributedString.Key.font: font,
                           NSAttributedString.Key.foregroundColor: UIColor.black,
                           NSAttributedString.Key.paragraphStyle: paragraphStyle]
        textView.typingAttributes = attributes
    }

    func textViewDidChange(_ textView: UITextView) {
        messagePlaceholderText.isHidden = !textView.text.isEmpty
        feedbackModel.message = textView.text
        refreshButton()
    }
}

extension SiteFeedbackViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        messageTextView.becomeFirstResponder()
        return false
    }
}

extension SiteFeedbackViewController: Themable {
    
    func decorate(with theme: Theme) {
        urlTextField.keyboardAppearance = theme.keyboardAppearance
        messageTextView.keyboardAppearance = theme.keyboardAppearance
    }
}
