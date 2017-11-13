//
//  PrivacyProtectionHeaderController.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 13/11/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

