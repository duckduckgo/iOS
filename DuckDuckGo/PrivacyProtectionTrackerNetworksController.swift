//
//  PrivacyProtectionTrackerNetworksController.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 22/11/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class PrivacyProtectionTrackerNetworksController: UIViewController {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    private weak var siteRating: SiteRating!
    private weak var contentBlocker: ContentBlockerConfigurationStore!

    var majorOnly = false

    struct Section {

        let name: String
        let rows: [Row]

        func adding(_ row: Row) -> Section {
            guard self.rows.filter( { $0.name == row.name } ).count == 0 else { return self }
            var rows = self.rows
            rows.append(row)
            return Section(name: name, rows: rows.sorted(by: { $0.name < $1.name }))
        }

    }

    struct Row {

        let name: String
        let value: String

    }

    var sections = [Section]()

    override func viewDidLoad() {
        initTableView()
        update()
    }

    @IBAction func onBack() {
        navigationController?.popViewController(animated: true)
    }

    func update() {
        guard isViewLoaded else { return }
        sections = siteRating.toSections(withSiteRating: siteRating, andContentBlocker: contentBlocker, forMajorNetworksOnly: majorOnly)
        updateDomain()
        updateMessage()
        updateIcon()
        tableView.reloadData()
    }

    private func updateDomain() {
        domainLabel.text = siteRating.domain
    }

    private func updateMessage() {
        messageLabel.text = majorOnly ?
            siteRating.majorNetworksText(contentBlocker: contentBlocker).uppercased() :
            siteRating.networksText(contentBlocker: contentBlocker).uppercased()
    }

    private func updateIcon() {

        if majorOnly {
            updateMajorNetworksIcon()
        } else {
            updateNetworksIcon()
        }

    }

    private func updateMajorNetworksIcon() {
        if siteRating.majorNetworksSuccess(contentBlocker: contentBlocker)  {
            iconImage.image = siteRating.protecting(contentBlocker) ? #imageLiteral(resourceName: "PP Hero Major On") : #imageLiteral(resourceName: "PP Hero Major Off")
        } else {
            // TODO replace with bad icon
            iconImage.image = siteRating.protecting(contentBlocker) ? #imageLiteral(resourceName: "PP Hero Major On") : #imageLiteral(resourceName: "PP Hero Major Off")
        }
    }

    private func updateNetworksIcon() {
        if siteRating.networksSuccess(contentBlocker: contentBlocker)  {
            iconImage.image = siteRating.protecting(contentBlocker) ? #imageLiteral(resourceName: "PP Hero Networks On") : #imageLiteral(resourceName: "PP Hero Networks Off")
        } else {
            // TODO replace with bad icon
            iconImage.image = siteRating.protecting(contentBlocker) ? #imageLiteral(resourceName: "PP Hero Networks On") : #imageLiteral(resourceName: "PP Hero Networks Off")
        }
    }

    private func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

}

extension PrivacyProtectionTrackerNetworksController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Section") as! PrivacyProtectionTrackerNetworksSectionCell
        cell.update(withSection: sections[section])
        return cell
    }

}

extension PrivacyProtectionTrackerNetworksController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Row") as! PrivacyProtectionTrackerNetworksRowCell
        cell.update(withRow: sections[indexPath.section].rows[indexPath.row])
        return cell
    }

}

extension PrivacyProtectionTrackerNetworksController: PrivacyProtectionInfoDisplaying {

    func using(siteRating: SiteRating, contentBlocker: ContentBlockerConfigurationStore) {
        self.siteRating = siteRating
        self.contentBlocker = contentBlocker
        update()
    }

}

fileprivate extension Tracker {

    var domain: String? {
        let urlString = url.starts(with: "//") ? "http:\(url)" : url
        return URL(string: urlString)?.host
    }

}

fileprivate extension SiteRating {

    func toSections(withSiteRating siteRating: SiteRating, andContentBlocker contentBlocker: ContentBlockerConfigurationStore, forMajorNetworksOnly majorOnly: Bool) -> [PrivacyProtectionTrackerNetworksController.Section] {

        if majorOnly {
            return toSections(siteRating: siteRating, trackers: contentBlocker.enabled ? majorNetworkTrackersBlocked : majorNetworkTrackersDetected)
        } else {
            return toSections(siteRating: siteRating, trackers: contentBlocker.enabled ? trackersBlocked : trackersDetected)
        }
    }

    func toSections(siteRating: SiteRating, trackers: [Tracker: Int]) -> [PrivacyProtectionTrackerNetworksController.Section] {
        var sections = [String: PrivacyProtectionTrackerNetworksController.Section]()

        for tracker in trackers.keys {
            guard let networkName = tracker.networkName, networkName != "" else { continue }
            guard let domain = tracker.domain else { continue }
            let category = siteRating.category(forDomain: domain)

            let row = PrivacyProtectionTrackerNetworksController.Row(name: domain, value: category ?? "")

            if let section = sections[networkName] {
                sections[networkName] = section.adding(row)
            } else {
                sections[networkName] = PrivacyProtectionTrackerNetworksController.Section(name: networkName, rows: [row])
            }
        }

        return Array(sections.values).sorted(by: { $0.name < $1.name })
    }

}

class PrivacyProtectionTrackerNetworksRowCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    func update(withRow row: PrivacyProtectionTrackerNetworksController.Row) {
        nameLabel.text = row.name
        valueLabel.text = row.value
    }

}

class PrivacyProtectionTrackerNetworksSectionCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!

    func update(withSection section: PrivacyProtectionTrackerNetworksController.Section) {
        nameLabel.text = section.name
        iconImage.backgroundColor = UIColor.gray
        if let image = UIImage(named: "PP Pill \(section.name.lowercased())") {
            iconImage.image = image
        } else {
            iconImage.image = #imageLiteral(resourceName: "PP Pill Generic")
        }
    }

}
