//
//  PrivacyProtectionFooterController.swift
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

import Foundation
import UIKit
import Core

class PrivacyProtectionFooterController: UIViewController {

    @IBOutlet weak var privacyProtectionView: UIView!
    @IBOutlet weak var privacyProtectionSwitch: UISwitch!
    @IBOutlet weak var leaderboard: TrackerNetworkLeaderboardView!

    var contentBlocker: ContentBlockerConfigurationStore = ContentBlockerConfigurationUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        leaderboard.didLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        preferredContentSize = CGSize(width: view.frame.size.width, height: leaderboard.requiredHeight + privacyProtectionView.frame.height)
    }

    private func updateProtectionToggle() {
        privacyProtectionSwitch.isOn = contentBlocker.enabled
        privacyProtectionView.backgroundColor = contentBlocker.enabled ? UIColor.ppGreen : UIColor.ppGray
    }

}

class TrackerNetworkLeaderboardView: UIView {

    @IBOutlet weak var gatheringView: UIView!
    @IBOutlet weak var scoresView: UIView!

    @IBOutlet weak var firstPill: TrackerNetworkPillView!
    @IBOutlet weak var secondPill: TrackerNetworkPillView!
    @IBOutlet weak var thirdPill: TrackerNetworkPillView!

    var requiredHeight: CGFloat {
        return gatheringView.isHidden ? scoresView.frame.size.height : gatheringView.frame.size.height
    }

    var leaderboard = NetworkLeaderboard.shared

    func didLoad() {
        firstPill.didLoad()
        secondPill.didLoad()
        thirdPill.didLoad()
    }

    func update() {
        let networksDetected = leaderboard.networksDetected()
        let shouldShow = leaderboard.shouldShow()
        gatheringView.isHidden = shouldShow
        scoresView.isHidden = !shouldShow

        if shouldShow {
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
