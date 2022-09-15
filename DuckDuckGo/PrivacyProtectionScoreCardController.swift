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
import BrowserServicesKit

class PrivacyProtectionScoreCardController: UITableViewController {

    @IBOutlet weak var connectionCell: PrivacyProtectionScoreCardCell!
    @IBOutlet weak var networksCell: PrivacyProtectionScoreCardCell!
    @IBOutlet weak var majorNetworksCell: PrivacyProtectionScoreCardCell!
    @IBOutlet weak var privacyPracticesCell: PrivacyProtectionScoreCardCell!
    @IBOutlet weak var privacyGradeCell: PrivacyProtectionScoreCardCell!
    @IBOutlet weak var enhancedGradeCell: PrivacyProtectionScoreCardCell!
    @IBOutlet weak var isMajorNetworkCell: PrivacyProtectionScoreCardCell!

    @IBOutlet var onHeaderCellTapped: UITapGestureRecognizer!
    
    private var siteRating: SiteRating!
    private var privacyConfig: PrivacyConfiguration = ContentBlocking.shared.privacyConfigurationManager.privacyConfig

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Pixel.fire(pixel: .privacyDashboardScorecard)
        
        tableView.register(UINib(nibName: "PrivacyProtectionHeaderCell", bundle: nil),
                           forCellReuseIdentifier: "PPHeaderCell")
        
        update()
    }

    @IBAction func onBack() {
        navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        return cell.isHidden ? 0 : UITableView.automaticDimension
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
        networksCell.isHidden = siteRating.isMajorTrackerNetwork
        let found = siteRating.trackerNetworksDetected > 0
        networksCell.update(message: siteRating.networksText(found: found), image: found ? #imageLiteral(resourceName: "PP Icon Result Fail") : #imageLiteral(resourceName: "PP Icon Result Success"))
    }

    private func updateMajorNetworksCell() {
        let found = siteRating.majorTrackerNetworksDetected > 0
        majorNetworksCell.update(message: siteRating.majorNetworksText(found: found), image: found ? #imageLiteral(resourceName: "PP Icon Result Fail") : #imageLiteral(resourceName: "PP Icon Result Success"))
    }

    private func updatePrivacyPractices() {
        let success = siteRating.privacyPracticesSummary() == .good
        privacyPracticesCell.update(message: siteRating.privacyPracticesText() ?? "", image: success ? #imageLiteral(resourceName: "PP Icon Result Success") : #imageLiteral(resourceName: "PP Icon Result Fail"))
    }

    private func updatePrivacyGradeCells() {
        let gradeImages = siteRating.siteGradeImages()
        privacyGradeCell.iconImage.image = gradeImages.from
        enhancedGradeCell.iconImage.image = gradeImages.to
        enhancedGradeCell.isHidden = !siteRating.protecting(privacyConfig) || gradeImages.from == gradeImages.to
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row == 0 else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PPHeaderCell", for: indexPath) as? PrivacyProtectionHeaderCell else {
            fatalError("Missing Header cell")
        }
        
        PrivacyProtectionHeaderConfigurator.configure(cell: cell, siteRating: siteRating, config: privacyConfig)
        cell.disclosureImage.isHidden = true
        cell.backImage.isHidden = !AppWidthObserver.shared.isLargeWidth
        cell.addGestureRecognizer(onHeaderCellTapped)
        
        return cell
    }
}

extension PrivacyProtectionScoreCardController: PrivacyProtectionInfoDisplaying {

    func using(siteRating: SiteRating, config: PrivacyConfiguration) {
        self.siteRating = siteRating
        self.privacyConfig = config
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
