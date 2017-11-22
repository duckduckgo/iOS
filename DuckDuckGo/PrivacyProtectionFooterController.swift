//
//  PrivacyProtectionFooterController.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 21/11/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation
import UIKit
import Core

class PrivacyProtectionFooterController: UIViewController {

    @IBOutlet weak var privacyProtectionView: UIView!
    @IBOutlet weak var privacyProtectionSwitch: UISwitch!
    @IBOutlet weak var leaderboard: TrackerNetworkLeaderboard!

    var contentBlocker: ContentBlockerConfigurationStore = ContentBlockerConfigurationUserDefaults()

    override func viewDidLoad() {
        leaderboard.didLoad()
        update()
    }

    override func viewDidAppear(_ animated: Bool) {
        update()
    }

    @IBAction func toggleProtection() {
        let contentBlockingOn = privacyProtectionSwitch.isOn
        self.contentBlocker.enabled = contentBlockingOn
        update()
    }

    private func update() {
        guard isViewLoaded else { return }
        leaderboard.update()
        updateProtectionToggle()
    }

    private func updateProtectionToggle() {
        privacyProtectionSwitch.isOn = contentBlocker.enabled
        privacyProtectionView.backgroundColor = contentBlocker.enabled ? UIColor.ppGreen : UIColor.ppGray
    }

}

class TrackerNetworkLeaderboard: UIView {

    @IBOutlet weak var firstPill: TrackerNetworkPillView!
    @IBOutlet weak var secondPill: TrackerNetworkPillView!
    @IBOutlet weak var thirdPill: TrackerNetworkPillView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var forwardArrow: UIImageView!

    var leaderboard = NetworkLeaderboard.shared

    func didLoad() {
        message.adjustKern(1.7)
        firstPill.didLoad()
        secondPill.didLoad()
        thirdPill.didLoad()
    }

    func update() {
        let networksDetected = leaderboard.networksDetected()

        let hasTop3 = networksDetected.count >= 3

        firstPill.isHidden = !hasTop3
        secondPill.isHidden = !hasTop3
        thirdPill.isHidden = !hasTop3
        forwardArrow.isHidden = !hasTop3
        message.isHidden = hasTop3

        if hasTop3 {
            let sitesVisited = leaderboard.sitesVisited()
            firstPill.update(network: networksDetected[0], sitesVisited: sitesVisited)
            secondPill.update(network: networksDetected[1], sitesVisited: sitesVisited)
            thirdPill.update(network: networksDetected[2], sitesVisited: sitesVisited)
        }

    }

}

class TrackerNetworkPillView: UIView {

    @IBOutlet weak var networkImage: UIImageView!
    @IBOutlet weak var percentageLabel: UILabel!

    func didLoad() {
        layer.cornerRadius = frame.size.height / 2
        percentageLabel.adjustKern(1.2)
    }

    func update(network: PPTrackerNetwork, sitesVisited: Int) {
        let percent = 100 * Int(truncating: network.detectedOnCount ?? 0) / sitesVisited
        let percentText = "\(percent)%"
        let image = network.image

        networkImage.image = image
        percentageLabel.text = percentText
    }

}

fileprivate extension PPTrackerNetwork {

    var image: UIImage {
        let imageName = "PP Pill \(name!.lowercased())"
        return UIImage(named: imageName) ?? #imageLiteral(resourceName: "PP Pill Generic")
    }

}

