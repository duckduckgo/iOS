//
//  PrivacyProtectionOverviewController.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 31/10/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

class PrivacyProtectionOverviewController: UITableViewController {

    @IBOutlet var margins: [NSLayoutConstraint]!

    override func viewDidLoad() {
        super.viewDidLoad()

        initMargins()
    }

    private func initMargins() {
        if #available(iOS 10, *) {
            for margin in margins {
                margin.constant = 0
            }
        }
    }

}
