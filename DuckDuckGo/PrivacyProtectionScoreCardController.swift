//
//  PrivacyProtectionScoreCardController.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 13/11/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class PrivacyProtectionScoreCardController: UITableViewController {

    weak var siteRating: SiteRating!
    weak var contentBlocker: ContentBlockerConfigurationStore!
    weak var header: PrivacyProtectionHeaderController!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let header = segue.destination as? PrivacyProtectionHeaderController {
            header.using(siteRating: siteRating, contentBlocker: contentBlocker)
            self.header = header
        }

    }

    @IBAction func onBack() {
        navigationController?.popViewController(animated: true)
    }

}

extension PrivacyProtectionScoreCardController: PrivacyProtectionInfoDisplaying {

    func using(siteRating: SiteRating, contentBlocker: ContentBlockerConfigurationStore) {
        self.siteRating = siteRating
        self.contentBlocker = contentBlocker
    }

}
