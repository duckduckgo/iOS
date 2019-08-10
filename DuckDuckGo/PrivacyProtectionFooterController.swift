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

    let configuration: ContentBlockerConfigurationStore = AppDependencyProvider.shared.storageCache.current.configuration

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
        self.configuration.enabled = contentBlockingOn
        update()
        Pixel.fire(pixel: contentBlockingOn ? .privacyDashboardToggleProtectionOn : .privacyDashboardToggleProtectionOff)
    }

    private func update() {
        guard isViewLoaded else { return }
        leaderboard.update()
        updateProtectionToggle()
    }

    private func updateProtectionToggle() {
        privacyProtectionSwitch.isOn = configuration.enabled
        privacyProtectionView.backgroundColor = configuration.enabled ? UIColor.ppGreen : UIColor.ppGray
    }

}

class TrackerNetworkLeaderboardView: UIView {

    @IBOutlet weak var gatheringView: UIView!
    @IBOutlet weak var scoresView: UIView!

    @IBOutlet weak var firstPill: TrackerNetworkPillView!
    @IBOutlet weak var secondPill: TrackerNetworkPillView!
    @IBOutlet weak var thirdPill: TrackerNetworkPillView!

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
            let pagesVisited = leaderboard.pagesVisited()
            firstPill.update(network: networksDetected[0], pagesVisited: pagesVisited)
            secondPill.update(network: networksDetected[1], pagesVisited: pagesVisited)
            thirdPill.update(network: networksDetected[2], pagesVisited: pagesVisited)
        }
    }

}

class TrackerNetworkPillView: UIView {

    @IBOutlet weak var networkImage: UIImageView!
    @IBOutlet weak var percentageLabel: UILabel!

    func didLoad() {
        layer.cornerRadius = frame.size.height / 2
    }

    func update(network: PPTrackerNetwork, pagesVisited: Int) {
        let percent = 100 * Int(network.detectedOnCount) / pagesVisited
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
