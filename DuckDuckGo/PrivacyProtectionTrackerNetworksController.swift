//
//  PrivacyProtectionTrackerNetworksController.swift
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
import Core

class PrivacyProtectionTrackerNetworksController: UIViewController {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
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
        messageLabel.adjustPlainTextLineHeight(1.286)
        update()
    }

    @IBAction func onBack() {
        navigationController?.popViewController(animated: true)
    }

    func update() {
        guard isViewLoaded else { return }
        sections = siteRating.toSections(withSiteRating: siteRating, andContentBlocker: contentBlocker, forMajorNetworksOnly: majorOnly)
        updateDomain()
        updateSubtitle()
        updateIcon()
        tableView.reloadData()
    }

    private func updateDomain() {
        domainLabel.text = siteRating.domain
    }

    private func updateSubtitle() {
        subtitleLabel.text = majorOnly ?
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

    private func updateNetworksIcon() {
        if protecting() || siteRating.uniqueTrackersDetected == 0 {
            iconImage.image = #imageLiteral(resourceName: "PP Hero Networks On")
        } else {
            iconImage.image = #imageLiteral(resourceName: "PP Hero Networks Bad")
        }
    }

    private func updateMajorNetworksIcon() {
        if protecting() || siteRating.uniqueMajorTrackerNetworksDetected == 0 {
            iconImage.image = #imageLiteral(resourceName: "PP Hero Major On")
        } else {
            iconImage.image = #imageLiteral(resourceName: "PP Hero Major Bad")
        }
    }

    private func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func protecting() -> Bool {
        return siteRating.protecting(contentBlocker)
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

//fileprivate extension Tracker {
//
//    var domain: String? {
//        let urlString = url.starts(with: "//") ? "http:\(url)" : url
//        let domainUrl = URL(string: urlString.trimWhitespace())
//        let host = domainUrl?.host
//        return host
//    }
//
//}

fileprivate extension SiteRating {

    func toSections(withSiteRating siteRating: SiteRating, andContentBlocker contentBlocker: ContentBlockerConfigurationStore, forMajorNetworksOnly majorOnly: Bool) -> [PrivacyProtectionTrackerNetworksController.Section] {

        if majorOnly {
            return toSections(siteRating: siteRating, trackers: contentBlocker.enabled ? majorNetworkTrackersBlocked : majorNetworkTrackersDetected)
        } else {
            return toSections(siteRating: siteRating, trackers: contentBlocker.enabled ? trackersBlocked : trackersDetected)
        }
    }

    func toSections(siteRating: SiteRating, trackers: [DetectedTracker: Int]) -> [PrivacyProtectionTrackerNetworksController.Section] {
        var sections = [String: PrivacyProtectionTrackerNetworksController.Section]()

        for tracker in trackers.keys {
            guard let domain = tracker.domain else { continue }
            let networkName = tracker.networkName ?? UserText.ppTrackerNetworkUnknown
            let networkNameAndCategory = siteRating.networkNameAndCategory(forDomain: domain)

            let row = PrivacyProtectionTrackerNetworksController.Row(name: domain, value: networkNameAndCategory.category ?? "")

            if let section = sections[networkName] {
                sections[networkName] = section.adding(row)
            } else {
                sections[networkName] = PrivacyProtectionTrackerNetworksController.Section(name: networkName, rows: [row])
            }
        }

        return Array(sections.values).sorted(by: { $0.name != UserText.ppTrackerNetworkUnknown || $0.name.lowercased() < $1.name.lowercased() })
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
        if let image = UIImage(named: "PP Network Icon \(section.name.lowercased())") {
            iconImage.image = image
        } else {
            iconImage.image = #imageLiteral(resourceName: "PP Network Icon unknown")
        }
    }

}
