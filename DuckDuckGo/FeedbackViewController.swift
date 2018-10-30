//
//  FeedbackViewController.swift
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

class FeedbackViewController: UIViewController {

    private struct ViewConstants {
        static let urlTextHeight: CGFloat = 38
        static let urlTextPadding: CGFloat = 4
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var brokenSiteSwitch: UISwitch!
    @IBOutlet weak var urlTextFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messagePlaceholderText: UILabel!
    @IBOutlet weak var submitButton: UIButton!

    private var feedbackModel = FeedbackModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.blur(style: .dark)
        loadModel()
        configureViews()
        registerForKeyboardNotifications()
        refreshMode()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }

    func prepareForSegue(isBrokenSite: Bool, url: String?) {
        feedbackModel.isBrokenSite = isBrokenSite
        feedbackModel.url = url
    }

    private func loadModel() {
        brokenSiteSwitch.isOn = feedbackModel.isBrokenSite
        messageTextView.text = feedbackModel.message
        urlTextField.text = feedbackModel.url
    }

    private func configureViews() {
        urlTextField.layer.borderWidth = 1
        urlTextField.layer.borderColor = UIColor.mercury.cgColor
        urlTextField.layer.sublayerTransform = CATransform3DMakeTranslation(ViewConstants.urlTextPadding, 0, 0)
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.borderColor = UIColor.mercury.cgColor
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

        guard let firstResponder = firstResponder() else { return }
        var rect = self.view.frame
        rect.size.height -= keyboardSize.height
        if !rect.contains(firstResponder.frame.origin) {
            scrollView.scrollRectToVisible(firstResponder.frame, animated: true)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
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

    @IBAction func onBrokenSiteChanged(_ sender: UISwitch) {
        feedbackModel.isBrokenSite = sender.isOn
        refreshMode()
    }

    private func refreshMode() {
        feedbackModel.isBrokenSite ? showBrokenSite() : hideBrokenSite()
        refreshButton()
    }

    private func showBrokenSite() {
        urlTextFieldHeight.constant = ViewConstants.urlTextHeight
        urlTextField.isHidden = false
        if messageTextView.isFirstResponder && urlTextField.text?.isEmpty ?? true {
            urlTextField.becomeFirstResponder()
        }
        updateMessagePlaceholder(withText: UserText.feedbackBrokenSitePlaceholder)
    }

    private func hideBrokenSite() {
        urlTextFieldHeight.constant = 0
        urlTextField.isHidden = true
        updateMessagePlaceholder(withText: UserText.feedbackGeneralPlaceholder)
        if urlTextField.isFirstResponder {
            messageTextView.becomeFirstResponder()
        }
    }

    private func updateMessagePlaceholder(withText text: String) {
        let attributes = messagePlaceholderText!.attributedText!.attributes(at: 0, effectiveRange: nil)
        messagePlaceholderText.attributedText = NSAttributedString(string: text, attributes: attributes)
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

extension FeedbackViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        messagePlaceholderText.isHidden = !textView.text.isEmpty
        feedbackModel.message = textView.text
        refreshButton()
    }
}

extension FeedbackViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        messageTextView.becomeFirstResponder()
        return false
    }
}

extension FeedbackViewController: Themable {
    
    func decorate(with theme: Theme) {
        let keyboardAppearance: UIKeyboardAppearance
        switch theme.currentImageSet {
        case .light:
            keyboardAppearance = .light
        case .dark:
            keyboardAppearance = .dark
        }
        urlTextField.keyboardAppearance = keyboardAppearance
        messageTextView.keyboardAppearance = keyboardAppearance
    }
}
