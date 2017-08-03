//
//  ContentBlockerPopover.swift
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

class ContentBlockerPopover: UITableViewController {

    @IBOutlet weak var blockCountCircle: UIImageView!
    @IBOutlet weak var blockCount: UILabel!
    @IBOutlet weak var blockingEnabledToggle: UISwitch!
    @IBOutlet weak var blockThisDomainToggle: UISwitch!
    
    private weak var contentBlocker: ContentBlocker!
    private(set) var domain: String!
    
    static func loadFromStoryboard(withContentBlocker contentBlocker: ContentBlocker, domain: String) -> ContentBlockerPopover {
        let storyboard = UIStoryboard.init(name: "ContentBlockerPopover", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! ContentBlockerPopover
        controller.contentBlocker = contentBlocker
        controller.domain = domain
        return controller
    }
    
    override func viewDidLoad() {
        refresh()
    }
    
    public func refresh() {
        blockingEnabledToggle.isOn = contentBlocker.enabled
        blockThisDomainToggle.isOn = contentBlocker.enabled(forDomain: domain)
        blockThisDomainToggle.isEnabled = blockingEnabledToggle.isOn
        blockCount.text = blockCountText()
        blockCountCircle.tintColor = blockCountCircleTint()
    }
 
    private func blockCountText() -> String {
        if !contentBlocker.enabled {
            return "!"
        }
        if !contentBlocker.enabled(forDomain: domain) {
            return "!"
        }
        return "\(contentBlocker.uniqueItemsBlocked)"
    }
    
    private func blockCountCircleTint() -> UIColor {
        if !contentBlocker.enabled {
            return UIColor.contentBlockerCompletelyDisabledTint
        }
        if !contentBlocker.enabled(forDomain: domain) {
            return UIColor.contentBlockerCompletelyDisabledTint
        }
        if contentBlocker.uniqueItemsBlocked > 0 {
            return UIColor.contentBlockerActiveDirtySiteTint
        }
        return UIColor.contentBlockerActiveCleanSiteTint
    }
    
    @IBAction func onBlockingEnabledToggle(_ sender: UISwitch) {
        contentBlocker.enabled = sender.isOn
        blockThisDomainToggle.isEnabled = sender.isOn
        refresh()
        reloadContentBlockerExtension()
    }
    
    @IBAction func onBlockThisDomainToggled(_ sender: UISwitch) {
        contentBlocker.whitelist(!sender.isOn, domain: domain)
        refresh()
        reloadContentBlockerExtension()
    }

    private func reloadContentBlockerExtension() {
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: "com.duckduckgo.DuckDuckGo.ContentBlockerExtension") { (error) in
            if let error = error {
                Logger.log(text: "Could not reload content blocker in Safari due to \(error)")
                return
            }
            Logger.log(text: "Content blocker rules for Safari reloaded")
        }
    }
}
