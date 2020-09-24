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
    @IBOutlet weak var backButton: UIButton!

    private var siteRating: SiteRating!
    private var protectionStore = AppDependencyProvider.shared.storageCache.current.protectionStore

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
        
        Pixel.fire(pixel: .privacyDashboardNetworks)
        
        initTableView()
        initUI()
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
        tableView.setNeedsLayout()
    }

    private func trackers() -> [DetectedTracker] {
        let protecting = siteRating.protecting(protectionStore)
        return [DetectedTracker](protecting ? siteRating.trackersBlocked : siteRating.trackersDetected)
    }

    private func updateDomain() {
        domainLabel.text = siteRating.domain
    }

    private func updateSubtitle() {
        subtitleLabel.text = siteRating.networksText(protectionStore: protectionStore).uppercased()
    }

    private func updateIcon() {

        if protecting() || siteRating.trackerNetworksDetected == 0 {
            iconImage.image = #imageLiteral(resourceName: "PP Hero Major On")
        } else {
            iconImage.image = #imageLiteral(resourceName: "PP Hero Major Bad")
        }

    }

    private func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func initUI() {
        messageLabel.setAttributedTextString(UserText.ppTrackerNetworksInfo)
        backButton.isHidden = !isPad
    }

    private func protecting() -> Bool {
        return siteRating.protecting(protectionStore)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let header = tableView.tableHeaderView {
            let newSize = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            header.frame.size.height = newSize.height
            DispatchQueue.main.async {
                self.tableView.tableHeaderView = header
            }
        }
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

    func using(siteRating: SiteRating, protectionStore: ContentBlockerProtectionStore) {
        self.siteRating = siteRating
        self.protectionStore = protectionStore
        update()
    }

}

struct SiteRatingTrackerNetworkSectionBuilder {

    let trackers: [DetectedTracker]

    func build() -> [PrivacyProtectionTrackerNetworksController.Section] {
        return toSections()
    }

    private func toSections() -> [PrivacyProtectionTrackerNetworksController.Section] {
        var sections = [PrivacyProtectionTrackerNetworksController.Section]()

        let sortedTrackers = trackers.sorted(by: compareTrackersByHostName).sorted(by: compareTrackersByPrevalence)
        for tracker in sortedTrackers {
            guard let domain = tracker.domain else { continue }
            let networkName = tracker.networkNameForDisplay

            let row = PrivacyProtectionTrackerNetworksController.Row(name: domain.dropPrefix(prefix: "www."),
                                                                     value: tracker.knownTracker?.category ?? "")

            if let sectionIndex = sections.firstIndex(where: { $0.name == networkName }) {
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
    
    func compareTrackersByPrevalence(tracker1: DetectedTracker, tracker2: DetectedTracker) -> Bool {
        return tracker1.entity?.prevalence ?? 0 > tracker2.entity?.prevalence ?? 0
    }
    
    func compareTrackersByHostName(tracker1: DetectedTracker, tracker2: DetectedTracker) -> Bool {
        return tracker1.domain ?? "" < tracker2.domain ?? ""
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
        iconImage.image = PrivacyProtectionIconSource.iconImageTemplate(forNetworkName: section.name.lowercased(),
                                                                        iconSize: CGSize(width: 24, height: 24))
    }

}
