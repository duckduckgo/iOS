//
//  PrivacyProtectionHeaderController.swift
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

import UIKit
import Core

class PrivacyProtectionHeaderController: UIViewController {

    private static let gradesOn = [
        SiteGrade.a: #imageLiteral(resourceName: "PP Grade A On"),
        SiteGrade.b: #imageLiteral(resourceName: "PP Grade B On"),
        SiteGrade.c: #imageLiteral(resourceName: "PP Grade C On"),
        SiteGrade.d: #imageLiteral(resourceName: "PP Grade D On"),
        ]

    private static let gradesOff = [
        SiteGrade.a: #imageLiteral(resourceName: "PP Grade A Off"),
        SiteGrade.b: #imageLiteral(resourceName: "PP Grade B Off"),
        SiteGrade.c: #imageLiteral(resourceName: "PP Grade C Off"),
        SiteGrade.d: #imageLiteral(resourceName: "PP Grade D Off"),
        ]

    @IBOutlet weak var gradeImage: UIImageView!
    @IBOutlet weak var siteTitleLabel: UILabel!
    @IBOutlet weak var protectionPausedLabel: UILabel!
    @IBOutlet weak var protectionDisabledLabel: UILabel!
    @IBOutlet weak var protectionUpgraded: ProtectionUpgradedView!

    private weak var siteRating: SiteRating!
    private weak var contentBlocker: ContentBlockerConfigurationStore!

    override func viewDidLoad() {
        update()
    }

    private func update() {
        guard isViewLoaded else { return }

        let grades = siteRating.siteGrade()
        let protecting = contentBlocker.protecting(domain: siteRating.domain)
        let grade =  protecting ? grades.after : grades.before
        gradeImage.image = protecting ? PrivacyProtectionHeaderController.gradesOn[grade] : PrivacyProtectionHeaderController.gradesOff[grade]

        siteTitleLabel.text = siteRating.domain

        protectionPausedLabel.isHidden = true
        protectionDisabledLabel.isHidden = true
        protectionUpgraded.isHidden = true

        if !contentBlocker.enabled {
            protectionDisabledLabel.isHidden = false
        } else if contentBlocker.domainWhitelist.contains(siteRating.domain) {
            protectionPausedLabel.isHidden = false
        } else {
            protectionUpgraded.isHidden = false
            protectionUpgraded.update(with: siteRating)
        }
    }

}

extension PrivacyProtectionHeaderController: PrivacyProtectionInfoDisplaying {

    func using(siteRating: SiteRating, contentBlocker: ContentBlockerConfigurationStore) {
        self.siteRating = siteRating
        self.contentBlocker = contentBlocker
        update()
    }

}

