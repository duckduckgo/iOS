//
//  JSAlertController.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import Core

private extension UIImage {
    static let highlightedAlertButtonTint = UIImage(named: "AlertButtonHighlightedTint")
}

final class JSAlertController: UIViewController {

    private enum Constants {
        static let appearAnimationDuration = 0.2
        static let dismissAnimationDuration = 0.3
        static let keyboardAnimationDuration = 0.3
    }

    @IBOutlet var alertView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var keyboardConstraint: NSLayoutConstraint!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var okButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var textField: UITextField!
    @IBOutlet var textFieldBox: UIView!

    private var alert: WebJSAlert? {
        didSet {
            reloadData()
        }
    }

    var isShown: Bool {
        alert != nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()

        self.alertView.alpha = 0.0
        self.backgroundView.alpha = 0.0

        self.keyboardConstraint.constant = 0
        self.registerForKeyboardNotifications()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // hide container view
        if alert == nil {
            self.view.superview?.isHidden = true
        }
    }

    func present(_ alert: WebJSAlert) {
        self.alert = alert

        self.view.superview?.isHidden = false
        self.alertView.alpha = 0.0
        self.alertView.transform = .init(scaleX: 1.15, y: 1.15)
        self.backgroundView.alpha = 0.0

        UIView.animate(withDuration: Constants.appearAnimationDuration, delay: 0, options: .curveEaseOut) {
            self.alertView.alpha = 1.0
            self.alertView.transform = .identity
            self.backgroundView.alpha = 1.0
        } completion: { _ in

            if !self.textFieldBox.isHidden {
                self.textField.becomeFirstResponder()
            }
            Pixel.fire(pixel: .jsAlertShown)
        }
    }

    override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        if self.textField.isFirstResponder {
            self.textField.resignFirstResponder()
        }
        guard animated else {
            self.alert = nil
            self.view.superview?.isHidden = true
            completion?()
            return
        }

        UIView.animate(withDuration: Constants.dismissAnimationDuration) {
            self.backgroundView.alpha = 0.0
            self.alertView.alpha = 0.0

        } completion: { [alert=self.alert] _ in
            if self.alert === alert {
                self.alert = nil
            }
            self.view.superview?.isHidden = true
            completion?()

            // if another alert was requested while dismissing
            if let alert = self.alert {
                self.present(alert)
            }
        }
    }

    private func reloadData() {
        guard isViewLoaded,
            let alert = alert
        else { return }

        okButton.setTitle(UserText.webJSAlertOKButton, for: .normal)
        okButton.setBackgroundImage(.highlightedAlertButtonTint, for: .highlighted)
        cancelButton.setTitle(UserText.webJSAlertCancelButton, for: .normal)
        cancelButton.setBackgroundImage(.highlightedAlertButtonTint, for: .highlighted)
        titleLabel.text = String(format: UserText.webJSAlertWebsiteMessageFormat, alert.domain)
        messageLabel.text = alert.message

        if let text = alert.text {
            textField.placeholder = text
            textField.text = text
            textFieldBox.isHidden = false
        } else {
            textFieldBox.isHidden = true
        }

        cancelButton.isHidden = alert.isSimpleAlert
    }

    @IBAction func okAction(_ sender: UIButton) {
        dismiss(animated: true) { [alert=self.alert, text=self.textField.text] in
            alert?.complete(with: true, text: text)
        }
    }

    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true) { [alert=self.alert] in
            alert?.complete(with: false, text: nil)
        }
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
        guard let isLocalUserInfoKey = notification.userInfo?[UIResponder.keyboardIsLocalUserInfoKey] as? NSNumber,
              isLocalUserInfoKey == true,
              let intersection = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?
                  .intersection(self.view.convert(view.bounds, to: view.window)),
              self.keyboardConstraint.constant != intersection.height
        else {
            return
        }

        UIView.animate(withDuration: Constants.keyboardAnimationDuration) {
            self.keyboardConstraint.constant = intersection.height
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let isLocalUserInfoKey = notification.userInfo?[UIResponder.keyboardIsLocalUserInfoKey] as? NSNumber,
              isLocalUserInfoKey == true,
              self.keyboardConstraint.constant != 0
        else {
            return
        }

        UIView.animate(withDuration: Constants.keyboardAnimationDuration) {
            self.keyboardConstraint.constant = 0
            self.view.layoutSubviews()
        }
    }

}
