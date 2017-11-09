//
//  PrivacyProtectionOverviewController.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 31/10/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class PrivacyProtectionOverviewController: UITableViewController {

    @IBOutlet var margins: [NSLayoutConstraint]!
    @IBOutlet var requiresKernAdjustment: [UILabel]!

    @IBOutlet weak var privacyGrade: PrivacyGradeCell!
    @IBOutlet weak var encryptionCell: SummaryCell!
    @IBOutlet weak var trackersCell: SummaryCell!
    @IBOutlet weak var majorTrackersCell: SummaryCell!
    @IBOutlet weak var privacyPracticesCell: SummaryCell!
    @IBOutlet weak var privacyProtectionCell: UITableViewCell!
    @IBOutlet weak var privacyProtectionSwitch: UISwitch!
    @IBOutlet weak var leaderboard: TrackerNetworkLeaderboardCell!

    fileprivate var popRecognizer: InteractivePopRecognizer!

    lazy var contentBlocker: ContentBlockerConfigurationStore = ContentBlockerConfigurationUserDefaults()
    weak var siteRating: SiteRating!

    override func viewDidLoad() {
        super.viewDidLoad()

        leaderboard.didLoad()
        initPopRecognizer()
        adjustMargins()
        adjustKerns()

        updateSiteRating(siteRating)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let displayInfo = segue.destination as? PrivacyProtectionInfoDisplaying {
            displayInfo.using(siteRating)
        }
    }

    @IBAction func toggleProtection() {
        let contentBlockingOn = privacyProtectionSwitch.isOn
        self.contentBlocker.enabled = contentBlockingOn
        updateSiteRating(siteRating)
    }

    func updateSiteRating(_ siteRating: SiteRating) {
        self.siteRating = siteRating

        // not keen on this, but there seems to be a race condition when the site rating is updated and the controller hasn't be loaded yet
        guard isViewLoaded else { return }

        updatePrivacyGrade()
        updateEncryption()
        updateTrackersBlocked()
        updateMajorTrackersBlocked()
        updatePrivacyPractices()
        updateProtectionToggle()
        updateLeaderBoard()
    }

    private func updatePrivacyGrade() {
        privacyGrade.update(with: siteRating, and: contentBlocker)
    }

    private func updateEncryption() {

        if !siteRating.https {
            encryptionCell.summaryLabel.text = UserText.privacyProtectionEncryptionBadConnection
        } else if !siteRating.hasOnlySecureContent {
            encryptionCell.summaryLabel.text = UserText.privacyProtectionEncryptionMixedConnection
        } else {
            encryptionCell.summaryLabel.text = UserText.privacyProtectionEncryptionGoodConnection
        }

        encryptionCell.summaryImage.image = protecting() ? #imageLiteral(resourceName: "PP Icon Connection On") : #imageLiteral(resourceName: "PP Icon Connection Off")
    }

    private func updateTrackersBlocked() {
        trackersCell.summaryImage.image = protecting() ? #imageLiteral(resourceName: "PP Icon Blocked On") : #imageLiteral(resourceName: "PP Icon Blocked Off")
        trackersCell.summaryLabel.text = protecting() ?
            String(format: UserText.privacyProtectionTrackersBlocked, siteRating.uniqueTrackersBlocked) :
            String(format: UserText.privacyProtectionTrackersFound, siteRating.uniqueTrackersDetected)
    }

    private func updateMajorTrackersBlocked() {
        majorTrackersCell.summaryImage.image = protecting() ? #imageLiteral(resourceName: "PP Icon Major Networks On") : #imageLiteral(resourceName: "PP Icon Major Networks Off")
        majorTrackersCell.summaryLabel.text = protecting() ?
            String(format: UserText.privacyProtectionMajorTrackersBlocked, siteRating.uniqueMajorTrackerNetworksBlocked) :
            String(format: UserText.privacyProtectionMajorTrackersFound, siteRating.uniqueMajorTrackerNetworksDetected)
    }

    private func updatePrivacyPractices() {
        privacyPracticesCell.summaryImage.image = protecting() ? #imageLiteral(resourceName: "PP Icon Bad Privacy On") : #imageLiteral(resourceName: "PP Icon Bad Privacy Off")
        privacyPracticesCell.summaryLabel.text = UserText.privacyProtectionTOSUnknown

        guard siteRating.termsOfService != nil else { return }

        let score = siteRating.termsOfServiceScore

        switch (score) {
        case _ where(score < 0):
            privacyPracticesCell.summaryLabel.text = UserText.privacyProtectionTOSGood
            privacyPracticesCell.summaryImage.image = protecting() ? #imageLiteral(resourceName: "PP Icon Good Privacy On") : #imageLiteral(resourceName: "PP Icon Good Privacy Off")

        case 0 ... 1:
            privacyPracticesCell.summaryLabel.text = UserText.privacyProtectionTOSMixed

        default:
            privacyPracticesCell.summaryLabel.text = UserText.privacyProtectionTOSPoor
        }
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

class PrivacyGradeCell: UITableViewCell {

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

    func update(with siteRating: SiteRating, and contentBlocking: ContentBlockerConfigurationStore) {

        let grades = siteRating.siteGrade()
        let protecting = contentBlocking.protecting(domain: siteRating.domain)
        let grade =  protecting ? grades.after : grades.before
        gradeImage.image = protecting ? PrivacyGradeCell.gradesOn[grade] : PrivacyGradeCell.gradesOff[grade]

        siteTitleLabel.text = siteRating.domain

        protectionPausedLabel.isHidden = true
        protectionDisabledLabel.isHidden = true
        protectionUpgraded.isHidden = true

        if !contentBlocking.enabled {
            protectionDisabledLabel.isHidden = false
        } else if contentBlocking.domainWhitelist.contains(siteRating.domain) {
            protectionPausedLabel.isHidden = false
        } else {
            protectionUpgraded.isHidden = false
            protectionUpgraded.update(with: siteRating)
        }
    }

}

class SummaryCell: UITableViewCell {

    @IBOutlet weak var summaryImage: UIImageView!
    @IBOutlet weak var summaryLabel: UILabel!

}

class ProtectionUpgradedView: UIView {

    static let grades = [
        SiteGrade.a: #imageLiteral(resourceName: "PP Inline A"),
        SiteGrade.b: #imageLiteral(resourceName: "PP Inline B"),
        SiteGrade.c: #imageLiteral(resourceName: "PP Inline C"),
        SiteGrade.d: #imageLiteral(resourceName: "PP Inline D")
    ]

    @IBOutlet weak var fromImage: UIImageView!
    @IBOutlet weak var toImage: UIImageView!

    func update(with siteRating: SiteRating) {
        let grades = siteRating.siteGrade()

        let fromGrade = grades.before
        let toGrade = grades.after

        isHidden = fromGrade == toGrade

        fromImage.image = image(for: fromGrade)
        toImage.image = image(for: toGrade)
    }

    private func image(for grade: SiteGrade) -> UIImage? {
        return ProtectionUpgradedView.grades[grade]
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

