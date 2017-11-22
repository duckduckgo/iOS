//
//  PrivacyProtectionErrorController.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 22/11/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation
import UIKit

class PrivacyProtectionErrorController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!

    var errorText: String?

    override func viewDidLoad() {
        errorLabel.text = errorText
    }

}
