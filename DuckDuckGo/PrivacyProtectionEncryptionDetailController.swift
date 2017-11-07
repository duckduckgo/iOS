//
//  PrivacyProtectionEncryptionDetailController.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 01/11/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class PrivacyProtectionEncryptionDetailController: UIViewController {

    @IBOutlet weak var label: UILabel!

    weak var siteRating: SiteRating!

    override func viewDidLoad() {
        label.text = String(describing: siteRating)
    }

    @IBAction func onBack() {
        navigationController?.popViewController(animated: true)
    }

}

extension PrivacyProtectionEncryptionDetailController: PrivacyProtectionInfoDisplaying {

    func using(_ siteRating: SiteRating) {
        self.siteRating = siteRating
    }

}
