//
//  PrivacyProtectionOtherDomainsController.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit
import Common

class PrivacyProtectionOtherDomainsController: UIViewController {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!

    private var siteRating: SiteRating!
    private var privacyConfig: PrivacyConfiguration = ContentBlocking.privacyConfigurationManager.privacyConfig
    private var isProtecting: Bool { privacyConfig.isProtected(domain: siteRating.domain) }
    
    private lazy var tld = TLD()

    struct Section {
        let name: String
        let rows: [Row]
        let showFooter: Bool
        let isSummarySection: Bool
        let buttonTitle: String?
        let buttonAction: (() -> Void)?

        internal init(name: String,
                      rows: [PrivacyProtectionOtherDomainsController.Row] = [],
                      showFooter: Bool = false,
                      isSummarySection: Bool = false,
                      buttonTitle: String? = nil,
                      buttonAction: (() -> Void)? = nil) {
            self.name = name
            self.rows = rows
            self.showFooter = showFooter
            self.isSummarySection = isSummarySection
            self.buttonTitle = buttonTitle
            self.buttonAction = buttonAction
        }
        
        func adding(_ row: Row, enableFooter: Bool = false) -> Section {
            guard self.rows.filter({ $0.name == row.name }).count == 0 else { return self }
            var rows = self.rows
            rows.append(row)
            return Section(name: name, rows: rows.sorted(by: { $0.name < $1.name }), showFooter: self.showFooter || enableFooter)
        }
    }

    struct Row {
        let name: String
        let value: String
    }

    var sections = [Section]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
        initUI()
        update()
    }

    @IBAction func onBack() {
        navigationController?.popViewController(animated: true)
    }

    func update() {
        guard isViewLoaded else { return }
        
        if isProtecting {
            sections = AdClickAttributionSectionBuilder.build(with: siteRating, viewController: self)
            + ExceptionSectionBuilder.build(with: siteRating)
            + FirstPartySectionBuilder.build(with: siteRating)
            let isThirdPartySectionTheOnlySection = sections.isEmpty
            sections += ThirdPartySectionBuilder.build(with: siteRating, isTheOnlySection: isThirdPartySectionTheOnlySection)
        } else {
            sections = AllLoadedSectionBuilder.build(with: siteRating)
        }
            
        updateDomain()
        tableView.reloadData()
        tableView.setNeedsLayout()
    }

    private func updateDomain() {
        domainLabel.text = siteRating.domain
    }

    private func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func initUI() {
        let state = SiteRating.State(siteRating: siteRating, config: privacyConfig)
        messageLabel.setAttributedTextString(state.thirdPartyRequestsDescription)
        iconImage.image = state.thirdPartyRequestsHeroIcon
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

extension PrivacyProtectionOtherDomainsController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = sections[section]

        if section.isSummarySection {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Summary") as? PrivacyProtectionOtherDomainsSummaryCell else {
                fatalError("Failed to dequeue cell as PrivacyProtectionOtherDomainsSummaryCell")
            }
            cell.update(withSection: section)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Section") as? PrivacyProtectionOtherDomainsSectionCell else {
                fatalError("Failed to dequeue cell as PrivacyProtectionOtherDomainsSectionCell")
            }
            cell.update(withSection: section)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].isSummarySection ? UITableView.automaticDimension : 46
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sections[section].showFooter ? 40 : 0
    }

}

extension PrivacyProtectionOtherDomainsController: UITableViewDataSource {

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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Row") as? PrivacyProtectionOtherDomainsRowCell else {
            fatalError("Failed to dequeue cell as PrivacyProtectionOtherDomainsRowCell")
        }
        cell.update(withRow: sections[indexPath.section].rows[indexPath.row])
        return cell
    }

}

extension PrivacyProtectionOtherDomainsController: PrivacyProtectionInfoDisplaying {

    func using(siteRating: SiteRating, config: PrivacyConfiguration) {
        self.siteRating = siteRating
        self.privacyConfig = config
        update()
    }

}

class AllLoadedSectionBuilder: SectionWithSummaryBuilder {
    
    static func build(with siteRating: SiteRating) -> [PrivacyProtectionOtherDomainsController.Section] {
        buildSections(from: siteRating.requestsAllowed + siteRating.thirdPartyRequests,
                      withSummary: UserText.ppOtherDomainsOtherThirdParties)
    }
}

class FirstPartySectionBuilder: SectionWithSummaryBuilder {
    
    static func build(with siteRating: SiteRating) -> [PrivacyProtectionOtherDomainsController.Section] {
        buildSections(from: siteRating.trackersAllowedForReason(.ownedByFirstParty),
                      withSummary: String(format: UserText.ppOtherDomainsOwnedByFirstParty, siteRating.domain ?? siteRating.url.absoluteString))
    }
}

class ExceptionSectionBuilder: SectionWithSummaryBuilder {
    
    static func build(with siteRating: SiteRating) -> [PrivacyProtectionOtherDomainsController.Section] {
        buildSections(from: siteRating.trackersAllowedForReason(.ruleException),
                      withSummary: UserText.ppOtherDomainsExceptions)
    }
}

class AdClickAttributionSectionBuilder: SectionWithSummaryBuilder {
    
    static func build(with siteRating: SiteRating, viewController: UIViewController) -> [PrivacyProtectionOtherDomainsController.Section] {
        buildSections(from: siteRating.trackersAllowedForReason(.adClickAttribution),
                      withSummary: String(format: UserText.ppOtherDomainsAdClickAttribution, siteRating.domain ?? siteRating.url.absoluteString),
                      buttonTitle: UserText.ppAboutSearchProtectionsAndAdsLinkNew) { [weak viewController] in
            viewController?.dismiss(animated: true) {
                UIApplication.shared.open(AppDeepLinks.thirdPartyTrackerLoadingProtection, options: [:])
            }
        }
    }
}

class ThirdPartySectionBuilder: SectionWithSummaryBuilder {
    
    static func build(with siteRating: SiteRating, isTheOnlySection: Bool) -> [PrivacyProtectionOtherDomainsController.Section] {
        let summary = isTheOnlySection ?
        UserText.ppOtherDomainsInfoHeaderDisabledProtectionNew :
        UserText.ppOtherDomainsInfoHeaderDisabledProtectionAlsoNew
        return buildSections(from: ([DetectedRequest])(siteRating.thirdPartyRequests), withSummary: summary)
    }
}

class SectionWithSummaryBuilder: GenericSectionBuilder {
    
    static func buildSections(from trackers: [DetectedRequest],
                              withSummary summaryText: String,
                              buttonTitle: String? = nil,
                              buttonAction: (() -> Void)? = nil) -> [PrivacyProtectionOtherDomainsController.Section] {
        var sections = super.buildSections(from: trackers)
        
        if !sections.isEmpty {
            let sectionSummaryHeader = PrivacyProtectionOtherDomainsController.Section(name: summaryText,
                                                                                       isSummarySection: true,
                                                                                       buttonTitle: buttonTitle,
                                                                                       buttonAction: buttonAction)
            sections.insert(sectionSummaryHeader, at: 0)
        }
        
        return sections
    }
}

class GenericSectionBuilder {

    init() {}
    
    static func buildSections(from trackers: [DetectedRequest]) -> [PrivacyProtectionOtherDomainsController.Section] {
        var sections = [PrivacyProtectionOtherDomainsController.Section]()

        let sortedTrackers = trackers.sorted(by: compareTrackersByHostName)
            .sorted(by: compareTrackersByPrevalence)
        
        for tracker in sortedTrackers {
            guard let domain = tracker.domain else { continue }
            let networkName = tracker.networkNameForDisplay
            
            let row = PrivacyProtectionOtherDomainsController.Row(name: domain.droppingWwwPrefix(),
                                                                  value: tracker.category ?? "")

            if let sectionIndex = sections.firstIndex(where: { $0.name == networkName }) {
                if row.name != networkName {
                    let section = sections[sectionIndex]
                    sections[sectionIndex] = section.adding(row)
                }
            } else {
                let rows: [PrivacyProtectionOtherDomainsController.Row] = [row]
                let section = PrivacyProtectionOtherDomainsController.Section(name: networkName, rows: rows)
                sections.append(section)
            }
        }

        return sections
    }
    
    private static func compareTrackersByPrevalence(tracker1: DetectedRequest, tracker2: DetectedRequest) -> Bool {
        return tracker1.prevalence ?? 0 > tracker2.prevalence ?? 0
    }
    
    private static func compareTrackersByHostName(tracker1: DetectedRequest, tracker2: DetectedRequest) -> Bool {
        return tracker1.domain ?? "" < tracker2.domain ?? ""
    }
}

class PrivacyProtectionOtherDomainsRowCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    func update(withRow row: PrivacyProtectionOtherDomainsController.Row) {
        nameLabel.text = row.name
        valueLabel.text = row.value
    }
}

class PrivacyProtectionOtherDomainsSectionCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!

    func update(withSection section: PrivacyProtectionOtherDomainsController.Section) {
        nameLabel.text = section.name
        iconImage.image = PrivacyProtectionIconSource.iconImageTemplate(forNetworkName: section.name.lowercased(),
                                                                        iconSize: CGSize(width: 24, height: 24))
    }
}

final class PrivacyProtectionOtherDomainsSummaryCell: UITableViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    func update(withSection section: PrivacyProtectionOtherDomainsController.Section) {
        descriptionLabel.text = section.name
        
        if let title = section.buttonTitle {
            button.isHidden = false
            let buttonTitle = button.attributedTitle(for: .normal)?.withText(title)
            button.setAttributedTitle(buttonTitle, for: .normal)
            button.addAction {
                section.buttonAction?()
            }
        } else {
            button.isHidden = true
        }
    }
}

private extension UIControl {
    func addAction(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping () -> Void) {
        addAction(UIAction { _ in closure() }, for: controlEvents)
    }
}
