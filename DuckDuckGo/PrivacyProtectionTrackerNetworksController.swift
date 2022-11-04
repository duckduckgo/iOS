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
import BrowserServicesKit

class PrivacyProtectionTrackerNetworksController: UIViewController {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var separator: UIView!

    private var siteRating: SiteRating!
    private var privacyConfig: PrivacyConfiguration = ContentBlocking.shared.privacyConfigurationManager.privacyConfig

    struct Section {
        let name: String
        let rows: [Row]

        internal init(name: String, rows: [PrivacyProtectionTrackerNetworksController.Row] = []) {
            self.name = name
            self.rows = rows
        }
        
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
        super.viewDidLoad()
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
        updateIcon()
        tableView.reloadData()
        tableView.setNeedsLayout()
        updateSeparator()
    }

    private func trackers() -> [DetectedRequest] {
        siteRating.trackersBlocked
    }

    private func updateDomain() {
        domainLabel.text = siteRating.domain
    }

    private func updateIcon() {
        iconImage.image = SiteRating.State(siteRating: siteRating, config: privacyConfig).trackingRequestsIcon
    }
    
    private func updateSeparator() {
        separator.isHidden = sections.isEmpty
    }

    private func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func initUI() {
        var networksInfo = UserText.ppTrackerNetworksInfoEmptyStatePrivacyOff
        if siteRating.protecting(privacyConfig) {
            networksInfo = UserText.ppTrackerNetworksInfoNew
        }
        messageLabel.setAttributedTextString(networksInfo)
        backButton.isHidden = !AppWidthObserver.shared.isLargeWidth
                
        let attributedTitle = aboutButton.attributedTitle(for: .normal)?.withText(UserText.ppAboutProtectionsLink)
        aboutButton.setAttributedTitle(attributedTitle, for: .normal)
        
        footerLabel.text = UserText.ppPlatformLimitationsFooterInfo
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let headerView = tableView.tableHeaderView {
            let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            if headerView.frame.size.height != size.height {
                headerView.frame.size.height = size.height
                tableView.tableHeaderView = headerView
                tableView.layoutIfNeeded()
            }
        }
        
        if let footerView = tableView.tableFooterView {
            let size = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            if footerView.frame.size.height != size.height {
                footerView.frame.size.height = size.height
                tableView.tableFooterView = footerView
                tableView.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func onAboutLinkTapped(_ sender: UIButton) {
        dismiss(animated: true) {
            UIApplication.shared.open(AppDeepLinks.webTrackingProtections, options: [:])
        }
    }
}

extension PrivacyProtectionTrackerNetworksController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = sections[section]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Section") as? PrivacyProtectionTrackerNetworksSectionCell else {
            fatalError("Failed to dequeue cell as PrivacyProtectionTrackerNetworksSectionCell")
        }
        cell.update(withSection: section)
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46
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

    func using(siteRating: SiteRating, config: PrivacyConfiguration) {
        self.siteRating = siteRating
        self.privacyConfig = config
        update()
    }

}

struct SiteRatingTrackerNetworkSectionBuilder {

    let trackers: [DetectedRequest]

    func build() -> [PrivacyProtectionTrackerNetworksController.Section] {
        return toSections()
    }

    private func toSections() -> [PrivacyProtectionTrackerNetworksController.Section] {
        var sections = [PrivacyProtectionTrackerNetworksController.Section]()

        let sortedTrackers = trackers.sorted(by: compareTrackersByHostName).sorted(by: compareTrackersByPrevalence)
        for tracker in sortedTrackers {
            guard let domain = tracker.domain else { continue }
            let networkName = tracker.networkNameForDisplay

            let row = PrivacyProtectionTrackerNetworksController.Row(name: domain.droppingWwwPrefix(),
                                                                     value: tracker.category ?? "")

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
    
    func compareTrackersByPrevalence(tracker1: DetectedRequest, tracker2: DetectedRequest) -> Bool {
        return tracker1.prevalence ?? 0 > tracker2.prevalence ?? 0
    }
    
    func compareTrackersByHostName(tracker1: DetectedRequest, tracker2: DetectedRequest) -> Bool {
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

class PrivacyProtectionTrackerNetworksSummaryCell: UITableViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func update(withSection section: PrivacyProtectionTrackerNetworksController.Section) {
        descriptionLabel.text = section.name
    }
}
