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

    private static let gradesOn: [Grade.Grading: UIImage] = [
        .a: #imageLiteral(resourceName: "PP Grade A On"),
        .bPlus: #imageLiteral(resourceName: "PP Grade B Plus On"),
        .b: #imageLiteral(resourceName: "PP Grade B On"),
        .cPlus: #imageLiteral(resourceName: "PP Grade C Plus On"),
        .c: #imageLiteral(resourceName: "PP Grade C On"),
        .d: #imageLiteral(resourceName: "PP Grade D On"),
        .dMinus: #imageLiteral(resourceName: "PP Grade D On")
        ]

    private static let gradesOff: [Grade.Grading: UIImage] = [
        .a: #imageLiteral(resourceName: "PP Grade A Off"),
        .bPlus: #imageLiteral(resourceName: "PP Grade B Plus Off"),
        .b: #imageLiteral(resourceName: "PP Grade B Off"),
        .cPlus: #imageLiteral(resourceName: "PP Grade C Plus Off"),
        .c: #imageLiteral(resourceName: "PP Grade C Off"),
        .d: #imageLiteral(resourceName: "PP Grade D Off"),
        .dMinus: #imageLiteral(resourceName: "PP Grade D Off")
        ]

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var gradeImage: UIImageView!
    @IBOutlet weak var siteTitleLabel: UILabel!
    @IBOutlet weak var privacyGradeLabel: UIView!
    @IBOutlet weak var protectionPausedLabel: UIView!
    @IBOutlet weak var protectionDisabledLabel: UIView!
    @IBOutlet weak var protectionUpgraded: ProtectionUpgradedView!

    private weak var siteRating: SiteRating!
    private weak var contentBlockerConfiguration: ContentBlockerConfigurationStore!

    override func viewDidLoad() {
        update()
    }

    private func update() {
        guard isViewLoaded else { return }

        let grades = siteRating.scores
        let protecting = contentBlockerConfiguration.protecting(domain: siteRating.domain)
        let grade =  protecting ? grades.enhanced.grade : grades.site.grade
        gradeImage.image = protecting ? PrivacyProtectionHeaderController.gradesOn[grade] : PrivacyProtectionHeaderController.gradesOff[grade]

        siteTitleLabel.text = siteRating.domain

        privacyGradeLabel.removeFromSuperview()
        protectionPausedLabel.removeFromSuperview()
        protectionDisabledLabel.removeFromSuperview()
        protectionUpgraded.removeFromSuperview()
        
        stackView.removeArrangedSubview(privacyGradeLabel)
        stackView.removeArrangedSubview(protectionPausedLabel)
        stackView.removeArrangedSubview(protectionDisabledLabel)
        stackView.removeArrangedSubview(protectionUpgraded)

        if !contentBlockerConfiguration.enabled {
            stackView.addArrangedSubview(protectionDisabledLabel)
        } else if contentBlockerConfiguration.domainWhitelist.contains(siteRating.domain ?? "") {
            stackView.addArrangedSubview(protectionPausedLabel)
        } else if siteRating.scores.enhanced != siteRating.scores.site {
            protectionUpgraded.update(with: siteRating)
            stackView.addArrangedSubview(protectionUpgraded)
        } else {
            stackView.addArrangedSubview(privacyGradeLabel)
        }
        
    }

}

extension PrivacyProtectionHeaderController: PrivacyProtectionInfoDisplaying {

    func using(siteRating: SiteRating, configuration: ContentBlockerConfigurationStore) {
        self.siteRating = siteRating
        self.contentBlockerConfiguration = configuration
        update()
    }

}
