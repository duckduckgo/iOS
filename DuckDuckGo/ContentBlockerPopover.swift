//
//  ContentBlockerPopover.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 15/06/2017.
//  Copyright (c) 2015 Edinburgh International Science Festival. All rights reserved.
//

import UIKit
import SafariServices
import Core

class ContentBlockerPopover: UITableViewController {
    
    private lazy var contentBlockerStore = ContentBlockerConfigurationUserDefaults()
    
    @IBOutlet weak var advertisingCountCircle: UIImageView!
    @IBOutlet weak var advertisingCount: UILabel!
    @IBOutlet weak var blockAdvertisingToggle: UISwitch!
    
    @IBOutlet weak var analyticsCountCircle: UIImageView!
    @IBOutlet weak var analyticsCount: UILabel!
    @IBOutlet weak var blockAnalyticsToggle: UISwitch!
    
    @IBOutlet weak var socialCountCircle: UIImageView!
    @IBOutlet weak var socialCount: UILabel!
    @IBOutlet weak var blockSocialToggle: UISwitch!
    
    private weak var monitor: ContentBlockerMonitor?
    
    static func loadFromStoryboard(withMonitor monitor: ContentBlockerMonitor) -> ContentBlockerPopover {
        let storyboard = UIStoryboard.init(name: "ContentBlockerPopover", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! ContentBlockerPopover
        controller.monitor = monitor
        return controller
    }
    
    override func viewDidLoad() {
        configureToggles()
        refresh()
    }
    
    private func configureToggles() {
        blockAdvertisingToggle.isOn = contentBlockerStore.blockAdvertisers
        blockAnalyticsToggle.isOn = contentBlockerStore.blockAnalytics
        blockSocialToggle.isOn = contentBlockerStore.blockSocial
    }
    
    public func updateMonitor(monitor: ContentBlockerMonitor) {
        self.monitor = monitor
        refresh()
    }
    
    public func refresh() {
        guard let monitor = monitor else { return }
        advertisingCount.text = "\(monitor.totalAdvertising)"
        analyticsCount.text = "\(monitor.totalAnalytics)"
        socialCount.text = "\(monitor.totalSocial)"
        advertisingCountCircle.tintColor = tint(whenEnabled: contentBlockerStore.blockAdvertisers, withBlockCount:  monitor.totalAdvertising)
        analyticsCountCircle.tintColor = tint(whenEnabled: contentBlockerStore.blockAnalytics, withBlockCount:  monitor.totalAnalytics)
        socialCountCircle.tintColor = tint(whenEnabled: contentBlockerStore.blockSocial, withBlockCount:  monitor.totalSocial)
    }
    
    private func tint(whenEnabled enabled: Bool, withBlockCount count: Int) -> UIColor {
        if !enabled {
            return UIColor.contentBlockerInactiveTint
        }
        return count == 0 ? UIColor.contentBlockerActiveCleanSiteTint : UIColor.contentBlockerActiveDirtySiteTint
    }
    
    @IBAction func onBlockAdvertisersToggled(_ sender: UISwitch) {
        contentBlockerStore.blockAdvertisers = sender.isOn
        reloadContentBlockerExtension()
    }
    
    @IBAction func onBlockAnalyticsToggled(_ sender: UISwitch) {
        contentBlockerStore.blockAnalytics = sender.isOn
        reloadContentBlockerExtension()
    }
    
    @IBAction func onBlockSocialToggled(_ sender: UISwitch) {
        contentBlockerStore.blockSocial = sender.isOn
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
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
