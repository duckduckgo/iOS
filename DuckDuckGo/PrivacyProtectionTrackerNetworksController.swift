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

    struct Section {

        let name: String
        let rows: [Row]

        func adding(_ row: Row) -> Section {
            guard self.rows.filter({ $0.name == row.name }).count == 0 else { return self }
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

        sections = SiteRatingTrackerNetworkSectionBuilder(trackers: trackers()).build()
        updateDomain()
        updateSubtitle()
        updateIcon()
        tableView.reloadData()
    }

    private func trackers() -> [DetectedTracker: Int] {
        let protecting = siteRating.protecting(contentBlocker)
        return protecting ? siteRating.trackersBlocked : siteRating.trackersDetected
    }

    private func updateDomain() {
        domainLabel.text = siteRating.domain
    }

    private func updateSubtitle() {
        subtitleLabel.text = siteRating.networksText(contentBlocker: contentBlocker).uppercased()
    }

    private func updateIcon() {

        if protecting() || siteRating.uniqueTrackerNetworksDetected == 0 {
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Section") as? PrivacyProtectionTrackerNetworksSectionCell else {
            fatalError("Failed to dequeue cell as PrivacyProtectionTrackerNetworksSectionCell")
        }
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Row") as? PrivacyProtectionTrackerNetworksRowCell else {
            fatalError("Failed to dequeue cell as PrivacyProtectionTrackerNetworksRowCell")
        }
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

class SiteRatingTrackerNetworkSectionBuilder {

    let trackers: [DetectedTracker: Int]
    let majorTrackerNetworksStore: MajorTrackerNetworkStore

    init(trackers: [DetectedTracker: Int], majorTrackerNetworksStore: MajorTrackerNetworkStore = EmbeddedMajorTrackerNetworkStore()) {
        self.trackers = trackers
        self.majorTrackerNetworksStore = majorTrackerNetworksStore
    }

    func build() -> [PrivacyProtectionTrackerNetworksController.Section] {
        return toSections(trackers: trackers)
    }

    private func toSections(trackers: [DetectedTracker: Int]) -> [PrivacyProtectionTrackerNetworksController.Section] {
        var sections = [PrivacyProtectionTrackerNetworksController.Section]()

        // work around bug in first party detection - everything *should* have a URL with host
        let trackers = trackers.compactMap({ $0.key }).filter({ $0.domain != nil }).sorted(by: { $0.domain! < $1.domain! })

        // group by tracker types, sorted appropriately
        let majorTrackers = trackers.filter({ $0.isMajor(majorTrackerNetworksStore) }).sorted(by: { $0.percentage(majorTrackerNetworksStore) > $1.percentage(majorTrackerNetworksStore) })
        let nonMajorKnownTrackers = trackers.filter({ $0.networkName != nil && !$0.isMajor(majorTrackerNetworksStore) }).sorted(by: { $0.networkName! < $1.networkName! })
        let unknownTrackers = trackers.filter({ $0.networkName == nil })

        for tracker in majorTrackers + nonMajorKnownTrackers + unknownTrackers {
            guard let domain = tracker.domain else { continue }
            let networkName = tracker.networkNameForDisplay

            let row = PrivacyProtectionTrackerNetworksController.Row(name: domain, value: tracker.category ?? "")

            if let sectionIndex = sections.index(where: { $0.name == networkName }) {
                if row.name != networkName {
                    let section = sections[sectionIndex]
                    sections[sectionIndex] = section.adding(row)
                }
            } else {
                let rows: [PrivacyProtectionTrackerNetworksController.Row] = (row.name == networkName) ? [] : [row]
                sections.append(PrivacyProtectionTrackerNetworksController.Section(name: networkName, rows: rows))
            }
        }

        return sections
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
            iconImage.image = nil
        }
    }

}

fileprivate extension DetectedTracker {

    var networkNameForDisplay: String {
        get {
            guard !isIpTracker else { return UserText.ppTrackerNetworkUnknown }
            guard let networkName = networkName else { return domain! }
            return networkName
        }
    }

    func isMajor(_ majorTrackerNetworkStore: MajorTrackerNetworkStore) -> Bool {
        guard let networkName = networkName else { return false }
        return majorTrackerNetworkStore.network(forName: networkName) != nil
    }

    func percentage(_ majorTrackerNetworkStore: MajorTrackerNetworkStore) -> Int {
        guard let networkName = networkName else { return 0 }
        guard let majorNetwork = majorTrackerNetworkStore.network(forName: networkName) else { return 0 }
        return majorNetwork.percentageOfPages
    }

}
