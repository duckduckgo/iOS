//
//  SettingsViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 30/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import MessageUI
import Core

class SettingsViewController: UITableViewController {

    @IBOutlet weak var safeSearchToggle: UISwitch!
    @IBOutlet weak var regionFilterText: UILabel!
    @IBOutlet weak var dateFilterText: UILabel!
    @IBOutlet weak var versionText: UILabel!
    
    private lazy var regionFilterProvider = RegionFilterProvider()
    private lazy var versionProvider = Version()
    fileprivate lazy var searchFilterStore = SearchFilterUserDefaults()
    
    private struct TableIndex {
        static let sendFeedback = IndexPath(item: 0, section: 2)
        static let onboardingFlow = IndexPath(item: 0, section: 3)
    }
    
    static func loadFromStoryboard() -> UIViewController {
        return UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController()!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSafeSearchToggle()
        configureVersionText()
    }
    
    private func configureSafeSearchToggle() {
        safeSearchToggle.isOn = searchFilterStore.safeSearchEnabled
    }
    
    private func configureVersionText() {
        versionText.text = versionProvider.localized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureRegionFilter()
        configureDateFilter()
    }

    private func configureRegionFilter() {
        regionFilterText.text = currentRegionSelection().name
    }
    
    private func configureDateFilter() {
        dateFilterText.text = UserText.forDateFilter(currentDateFilter())
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == TableIndex.onboardingFlow {
            launchOnboardingFlow()
        }
        if indexPath == TableIndex.sendFeedback {
            sendFeedback()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func launchOnboardingFlow() {
        let controller = OnboardingViewController.loadFromStoryboard()
        controller.modalTransitionStyle = .flipHorizontal
        present(controller, animated: true, completion: nil)
    }
    
    private func sendFeedback() {
        let appVersion = versionProvider.localized() ?? ""
        let device = UIDevice.current.deviceType.displayName
        let osName = UIDevice.current.systemName
        let osVersion = UIDevice.current.systemVersion
        
        let feedback = FeedbackEmail(appVersion: appVersion, device: device, osName: osName, osVersion: osVersion)
        guard let mail = MFMailComposeViewController.create() else { return }
        mail.mailComposeDelegate = self
        mail.setToRecipients([feedback.mailTo])
        mail.setSubject(feedback.subject)
        mail.setMessageBody(feedback.body, isHTML: false)
        present(mail, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? RegionSelectionViewController {
            controller.delegate = self
        }
        if let controller = segue.destination as? DateFilterSelectionViewController {
            controller.delegate = self
        }
    }
    
    @IBAction func onSafeSearchToggled(_ sender: UISwitch) {
        searchFilterStore.safeSearchEnabled = sender.isOn
    }
    
    fileprivate func currentRegionFilter() -> RegionFilter {
        return regionFilterProvider.regionForKey(searchFilterStore.regionFilter)
    }
    
    fileprivate func currentDateFilter() -> DateFilter {
        return DateFilter.forKey(searchFilterStore.dateFilter)
    }
    
    @IBAction func onDonePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController: RegionSelectionDelegate {
    func currentRegionSelection() -> RegionFilter {
        return currentRegionFilter()
    }
    
    func onRegionSelected(region: RegionFilter) {
        searchFilterStore.regionFilter = region.filter
    }
}

extension SettingsViewController: DateFilterSelectionDelegate {
    
    func currentDateFilterSelection() -> DateFilter {
        return currentDateFilter()
    }
    
    func onDateFilterSelected(dateFilter: DateFilter) {
        let value = (dateFilter == .any) ? nil : dateFilter.rawValue
        searchFilterStore.dateFilter = value
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}

extension MFMailComposeViewController {
    static func create() -> MFMailComposeViewController? {
        return MFMailComposeViewController()
    }
}


