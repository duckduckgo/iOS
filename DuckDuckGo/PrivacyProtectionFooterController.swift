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

    fileprivate var domain: String?
    fileprivate var contentBlockerConfiguration: ContentBlockerConfigurationStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leaderboard.didLoad()
    }
    
    @IBAction func toggleProtection() {
        guard let domain = domain else { return }
        let whitelisted = !privacyProtectionSwitch.isOn
        
        let window = UIApplication.shared.keyWindow
        window?.hideAllToasts()
        
        if whitelisted {
            contentBlockerConfiguration.addToWhitelist(domain: domain)
            
            window?.showBottomToast("\(domain) added to whitelist", duration: 1)
        } else {
            contentBlockerConfiguration.removeFromWhitelist(domain: domain)
            
            window?.showBottomToast("\(domain) removed from whitelist", duration: 1)
        }
        update()
        Pixel.fire(pixel: whitelisted ? .privacyDashboardWhitelistAdd : .privacyDashboardWhitelistRemove)
    }

    private func update() {
        guard isViewLoaded else { return }
        leaderboard.update()
        updateProtectionToggle()
    }

    private func updateProtectionToggle() {
        guard let domain = domain else { return }
        let isWhitelisted = contentBlockerConfiguration.whitelisted(domain: domain)
        privacyProtectionSwitch.isOn = !isWhitelisted
        privacyProtectionView.backgroundColor = isWhitelisted ? UIColor.ppGray : UIColor.ppGreen
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let whitelistController = segue.destination as? WhitelistViewController {
            prepareforSegue(to: whitelistController)
            return
        }
        if segue.destination is SiteFeedbackViewController {
            Pixel.fire(pixel: .privacyDashboardReportBrokenSite)
            return
        }
    }
    
    private func prepareforSegue(to whitelistController: WhitelistViewController) {
        whitelistController.enforceLightTheme = true
        if isPad {
            whitelistController.showBackButton = true
        }
        Pixel.fire(pixel: .privacyDashboardManageWhitelist)
    }
}

extension PrivacyProtectionFooterController: PrivacyProtectionInfoDisplaying {

    func using(siteRating: SiteRating, configuration: ContentBlockerConfigurationStore) {
        self.domain = siteRating.domain
        self.contentBlockerConfiguration = configuration
        update()
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
        let name = TrackerDataManager.shared.findEntity(byName: self.name ?? "")?.displayName ?? ""
        let imageName = "PP Pill \(name.lowercased())"
        return UIImage(named: imageName) ?? #imageLiteral(resourceName: "PP Pill Generic")
    }

}
