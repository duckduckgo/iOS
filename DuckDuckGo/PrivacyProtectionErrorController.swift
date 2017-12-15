//
//  PrivacyProtectionErrorController.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

protocol PrivacyProtectionErrorDelegate: class {

    func canTryAgain(controller: PrivacyProtectionErrorController) -> Bool

    func tryAgain(controller: PrivacyProtectionErrorController)

}

class PrivacyProtectionErrorController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!

    var errorText: String?

    weak var delegate: PrivacyProtectionErrorDelegate?

    override func viewDidLoad() {
        button.layer.cornerRadius = 5
        errorLabel.text = errorText
        resetTryAgain()
    }

    func resetTryAgain() {
        button?.isHidden = !(delegate?.canTryAgain(controller: self) ?? false)
        activity?.isHidden = true
    }

    @IBAction func onTapTryAgain() {
        activity.isHidden = false
        button.isHidden = true
        delegate?.tryAgain(controller: self)
    }

}
