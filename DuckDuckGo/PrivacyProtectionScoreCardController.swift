//
//  PrivacyProtectionScoreCardController.swift
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

class PrivacyProtectionScoreCardController: UITableViewController {

    @IBOutlet weak var connectionCell: PrivacyProtectionScoreCardCell!
    @IBOutlet weak var networksCell: PrivacyProtectionScoreCardCell!
    @IBOutlet weak var majorNetworksCell: PrivacyProtectionScoreCardCell!
    @IBOutlet weak var privacyPracticesCell: PrivacyProtectionScoreCardCell!
    @IBOutlet weak var privacyGradeCell: PrivacyProtectionScoreCardCell!
    @IBOutlet weak var enhancedGradeCell: PrivacyProtectionScoreCardCell!
    @IBOutlet weak var isMajorNetworkCell: PrivacyProtectionScoreCardCell!
    @IBOutlet weak var backButton: UIButton!

    private var siteRating: SiteRating!
    private var contentBlockerConfiguration = AppDependencyProvider.shared.storageCache.current.configuration
    weak var header: PrivacyProtectionHeaderController!

    override func viewDidLoad() {
        
        Pixel.fire(pixel: .privacyDashboardScorecard)
        initBackButton()
        update()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let header = segue.destination as? PrivacyProtectionHeaderController {
            header.using(siteRating: siteRating, configuration: contentBlockerConfiguration)
            self.header = header
        }

    }

    @IBAction func onBack() {
        navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        return cell.isHidden ? 0 : super.tableView(tableView, heightForRowAt: indexPath)
    }

    private func initBackButton() {
        backButton.isHidden = !isPad
    }

    private func update() {
        guard isViewLoaded else { return }

        updateConnectionCell()
        updateNetworksCell()
        updateMajorNetworksCell()
        updateIsMajorNetworkCell()
        updatePrivacyPractices()
        updatePrivacyGradeCells()
        tableView.reloadData()
    }

    private func updateIsMajorNetworkCell() {
        isMajorNetworkCell.isHidden = !siteRating.isMajorTrackerNetwork
    }

    private func updateConnectionCell() {
        let success = siteRating.encryptedConnectionSuccess()
        connectionCell.update(message: siteRating.encryptedConnectionText(), image: success ? #imageLiteral(resourceName: "PP Icon Result Success") : #imageLiteral(resourceName: "PP Icon Result Fail"))
    }

    private func updateNetworksCell() {
        let success = siteRating.networksSuccess(configuration: contentBlockerConfiguration)
        networksCell.update(message: siteRating.networksText(configuration: contentBlockerConfiguration), image: success ? #imageLiteral(resourceName: "PP Icon Result Success") : #imageLiteral(resourceName: "PP Icon Result Fail"))
    }

    private func updateMajorNetworksCell() {
        let success = siteRating.majorNetworksSuccess(configuration: contentBlockerConfiguration)
        majorNetworksCell.update(message: siteRating.majorNetworksText(configuration: contentBlockerConfiguration), image: success ? #imageLiteral(resourceName: "PP Icon Result Success") : #imageLiteral(resourceName: "PP Icon Result Fail"))
    }

    private func updatePrivacyPractices() {
        let success = siteRating.privacyPracticesSummary() == .good
        privacyPracticesCell.update(message: siteRating.privacyPracticesText() ?? "", image: success ? #imageLiteral(resourceName: "PP Icon Result Success") : #imageLiteral(resourceName: "PP Icon Result Fail"))
    }

    private func updatePrivacyGradeCells() {
        let gradeImages = siteRating.siteGradeImages()
        privacyGradeCell.iconImage.image = gradeImages.from
        enhancedGradeCell.iconImage.image = gradeImages.to
        enhancedGradeCell.isHidden = !siteRating.protecting(contentBlockerConfiguration) || gradeImages.from == gradeImages.to
    }

}

extension PrivacyProtectionScoreCardController: PrivacyProtectionInfoDisplaying {

    func using(siteRating: SiteRating, configuration: ContentBlockerConfigurationStore) {
        self.siteRating = siteRating
        self.contentBlockerConfiguration = configuration
        update()
    }

}

class PrivacyProtectionScoreCardCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!

    func update(message: String, image: UIImage) {
        messageLabel.text = message
        iconImage.image = image
    }

}
