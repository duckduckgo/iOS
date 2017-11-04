//
//  ContentBlockerViewController.swift
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
import SafariServices
import Core

class ContentBlockerViewController: UITableViewController {

    @IBOutlet weak var siteRatingView: SiteRatingView!
    @IBOutlet weak var httpsBackground: UIImageView!
    @IBOutlet weak var httpsLabel: UILabel!
    @IBOutlet weak var blockCountCircle: UIImageView!
    @IBOutlet weak var blockCount: UILabel!
    @IBOutlet weak var blockThisDomainToggle: UISwitch!
    
    weak var delegate: ContentBlockerSettingsChangeDelegate?

    private var contentBlocker: ContentBlockerConfigurationStore!
    private var siteRating: SiteRating!
    
    static func loadFromStoryboard(withDelegate delegate: ContentBlockerSettingsChangeDelegate?, contentBlocker: ContentBlockerConfigurationStore, siteRating: SiteRating) -> ContentBlockerViewController {
        let storyboard = UIStoryboard(name: "ContentBlocker", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ContentBlockerViewController") as! ContentBlockerViewController
        controller.delegate = delegate
        controller.contentBlocker = contentBlocker
        controller.siteRating = siteRating
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        siteRatingView.update(siteRating: siteRating)
        refresh()
    }

    public func updateSiteRating(siteRating: SiteRating) {
        self.siteRating = siteRating
        siteRatingView.update(siteRating: siteRating)
        refresh()
    }

    private func refresh() {
        siteRatingView.refresh()
        refreshHttps()
        blockThisDomainToggle.isOn = !contentBlocker.whitelisted(domain: siteRating.domain)
        blockCount.text = blockCountText()
        blockCountCircle.tintColor = blockCountCircleTint()
    }
    
    private func refreshHttps() {
        if siteRating.https {
            // httpsBackground.tintColor = UIColor.monitoringPositiveTint
            httpsLabel.text = UserText.secureConnection
        } else {
            // httpsBackground.tintColor = UIColor.monitoringNeutralTint
            httpsLabel.text = UserText.unsecuredConnection
        }
    }
    
    private func blockCountText() -> String {
        if contentBlocker.whitelisted(domain: siteRating.domain) {
            return "!"
        }
        return "\(siteRating.uniqueTrackersBlocked)"
    }
    
    private func blockCountCircleTint() -> UIColor {
//        if contentBlocker.whitelisted(domain: siteRating.domain) {
//            return UIColor.monitoringNegativeTint
//        }
//        if siteRating.uniqueTrackersBlocked > 0 {
//            return UIColor.monitoringNeutralTint
//        }
//        return UIColor.monitoringPositiveTint
        return UIColor.monitoringInactiveTint
    }
    
    @IBAction func onBlockThisDomainToggled(_ sender: UISwitch) {

        if (contentBlocker.whitelisted(domain: siteRating.domain)) {
            contentBlocker.removeFromWhitelist(domain: siteRating.domain)
        } else {
            contentBlocker.addToWhitelist(domain: siteRating.domain)
        }

        refresh()
        delegate?.contentBlockerSettingsDidChange()
    }
}
