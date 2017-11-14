//
//  PrivacyProtectionOverviewController.swift
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

class PrivacyProtectionOverviewController: UITableViewController {

    @IBOutlet var margins: [NSLayoutConstraint]!
    @IBOutlet var requiresKernAdjustment: [UILabel]!

    @IBOutlet weak var encryptionCell: SummaryCell!
    @IBOutlet weak var trackersCell: SummaryCell!
    @IBOutlet weak var majorTrackersCell: SummaryCell!
    @IBOutlet weak var privacyPracticesCell: SummaryCell!
    @IBOutlet weak var privacyProtectionCell: UITableViewCell!
    @IBOutlet weak var privacyProtectionSwitch: UISwitch!
    @IBOutlet weak var leaderboard: TrackerNetworkLeaderboardCell!

    fileprivate var popRecognizer: InteractivePopRecognizer!

    private weak var siteRating: SiteRating!
    private weak var contentBlocker: ContentBlockerConfigurationStore!
    private weak var header: PrivacyProtectionHeaderController!

    override func viewDidLoad() {
        super.viewDidLoad()

        leaderboard.didLoad()
        initPopRecognizer()
        adjustMargins()
        adjustKerns()

        update()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let displayInfo = segue.destination as? PrivacyProtectionInfoDisplaying {
            displayInfo.using(siteRating: siteRating, contentBlocker: contentBlocker)
        }

        if let header = segue.destination as? PrivacyProtectionHeaderController {
            self.header = header
        }
    }

    @IBAction func toggleProtection() {
        let contentBlockingOn = privacyProtectionSwitch.isOn
        self.contentBlocker.enabled = contentBlockingOn
        update()
    }

    private func update() {
        // not keen on this, but there seems to be a race condition when the site rating is updated and the controller hasn't be loaded yet
        guard isViewLoaded else { return }

        header.using(siteRating: siteRating, contentBlocker: contentBlocker)
        updateEncryption()
        updateTrackersBlocked()
        updateMajorTrackersBlocked()
        updatePrivacyPractices()
        updateProtectionToggle()
        updateLeaderBoard()
    }

    private func updateEncryption() {
        encryptionCell.summaryLabel.text = siteRating.encryptedConnectionText()
        encryptionCell.summaryImage.image = protecting() ? #imageLiteral(resourceName: "PP Icon Connection On") : #imageLiteral(resourceName: "PP Icon Connection Off")
    }

    private func updateTrackersBlocked() {
        trackersCell.summaryImage.image = protecting() ? #imageLiteral(resourceName: "PP Icon Blocked On") : #imageLiteral(resourceName: "PP Icon Blocked Off")
        trackersCell.summaryLabel.text = siteRating.trackersText(contentBlocker: contentBlocker)
    }

    private func updateMajorTrackersBlocked() {
        majorTrackersCell.summaryImage.image = protecting() ? #imageLiteral(resourceName: "PP Icon Major Networks On") : #imageLiteral(resourceName: "PP Icon Major Networks Off")
        majorTrackersCell.summaryLabel.text = siteRating.majorTrackersText(contentBlocker: contentBlocker)
    }

    private func updatePrivacyPractices() {
        privacyPracticesCell.summaryImage.image = protecting() ? #imageLiteral(resourceName: "PP Icon Bad Privacy On") : #imageLiteral(resourceName: "PP Icon Bad Privacy Off")
        privacyPracticesCell.summaryLabel.text = siteRating.privacyPracticesText()
    }

    private func updateLeaderBoard() {
        leaderboard.isHidden = true
        // TODO update leaderboard later
    }

    private func updateProtectionToggle() {
        privacyProtectionSwitch.isOn = contentBlocker.enabled
        privacyProtectionCell.backgroundColor = protecting() ? UIColor.ppGreen : UIColor.ppGray
    }

    private func protecting() -> Bool {
        return contentBlocker.protecting(domain: siteRating.domain)
    }

    // see https://stackoverflow.com/a/41248703
    private func initPopRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }

    private func adjustMargins() {
        if #available(iOS 10, *) {
            for margin in margins {
                margin.constant = 0
            }
        }
    }

    private func adjustKerns() {
        for label in requiresKernAdjustment {
            label.adjustKern(1.7)
        }
    }

}


extension PrivacyProtectionOverviewController: PrivacyProtectionInfoDisplaying {

    func using(siteRating: SiteRating, contentBlocker: ContentBlockerConfigurationStore) {
        self.siteRating = siteRating
        self.contentBlocker = contentBlocker
        update()
    }

}

class SummaryCell: UITableViewCell {

    @IBOutlet weak var summaryImage: UIImageView!
    @IBOutlet weak var summaryLabel: UILabel!

}

class ProtectionUpgradedView: UIView {

    @IBOutlet weak var fromImage: UIImageView!
    @IBOutlet weak var toImage: UIImageView!

    func update(with siteRating: SiteRating) {
        let siteGradeImages = siteRating.siteGradeImages()
        isHidden = siteGradeImages.from == siteGradeImages.to
        fromImage.image = siteGradeImages.from
        toImage.image = siteGradeImages.to
    }

}

class TrackerNetworkLeaderboardCell: UITableViewCell {

    @IBOutlet weak var firstPill: TrackerNetworkPillView!
    @IBOutlet weak var secondPill: TrackerNetworkPillView!
    @IBOutlet weak var thirdPill: TrackerNetworkPillView!

    func didLoad() {
        firstPill.didLoad()
        secondPill.didLoad()
        thirdPill.didLoad()
    }

}

class TrackerNetworkPillView: UIView {

    @IBOutlet weak var networkImage: UIImageView!
    @IBOutlet weak var percentageLabel: UILabel!

    func didLoad() {
        layer.cornerRadius = frame.size.height / 2
        percentageLabel.adjustKern(1.2)
    }

}

fileprivate class InteractivePopRecognizer: NSObject, UIGestureRecognizerDelegate {

    var navigationController: UINavigationController

    init(controller: UINavigationController) {
        self.navigationController = controller
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController.viewControllers.count > 1
    }

    // This is necessary because without it, subviews of your top controller can
    // cancel out your gesture recognizer on the edge.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

fileprivate extension UIColor {

    fileprivate static var ppGray: UIColor {
        return UIColor(red: 149.0 / 255.0, green: 149.0 / 255.0, blue: 149.0 / 255.0, alpha: 1.0)
    }

    fileprivate static var ppGreen: UIColor {
        return UIColor(red: 63.0 / 255.0, green: 161.0 / 255.0, blue: 64.0 / 255.0, alpha: 1.0)
    }

}

