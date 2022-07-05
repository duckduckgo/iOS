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

final class JSAlertController: UIViewController {

    @IBOutlet var alertView: UIView!
    @IBOutlet var alertOutOfScreenConstraint: NSLayoutConstraint!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var okButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var blockButton: UIButton!
    @IBOutlet var textField: UITextField!

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
        self.backgroundView.alpha = 0.0

        self.alertOutOfScreenConstraint.isActive = true
        self.alertView.superview?.layoutSubviews()

        UIView.animate(withDuration: 0.3) {
            self.alertView.alpha = 1.0
            self.backgroundView.alpha = 1.0

            self.alertOutOfScreenConstraint.isActive = false
            self.alertView.superview?.layoutSubviews()
        } completion: { _ in
            Pixel.fire(pixel: .jsAlertShown)
        }
    }

    override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        guard animated else {
            self.alert = nil
            self.view.superview?.isHidden = true
            completion?()
            return
        }

        UIView.animate(withDuration: 0.3) {
            self.backgroundView.alpha = 0.0
            self.alertView.alpha = 0.0

            self.alertOutOfScreenConstraint.isActive = true
            self.alertView.superview?.layoutSubviews()
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
        cancelButton.setTitle(UserText.webJSAlertCancelButton, for: .normal)
        blockButton.isHidden = true

        messageLabel.text = alert.message

        if let text = alert.text {
            textField.placeholder = text
            textField.text = text
            textField.isHidden = false
        } else {
            textField.isHidden = true
        }

        cancelButton.isHidden = !alert.isConfirm
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

    @IBAction func backgroundTapAction(_ sender: UITapGestureRecognizer) {
        Pixel.fire(pixel: .jsAlertBackgroundTap)
        cancelAction(sender)
    }

}
