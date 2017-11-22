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

    struct Section {

        let name: String
        let rows: [Row]

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
        sections = siteRating.toSections()
        updateDomain()
        updateMessage()
        updateIcon()
        tableView.reloadData()
    }

    private func updateDomain() {
        domainLabel.text = siteRating.domain
    }

    private func updateMessage() {
        messageLabel.text = siteRating.networksText(contentBlocker: contentBlocker).uppercased()
    }

    private func updateIcon() {
        if siteRating.networksSuccess(contentBlocker: contentBlocker) {
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
        return tableView.dequeueReusableCell(withIdentifier: "Section")
    }

}

extension PrivacyProtectionTrackerNetworksController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "Row")!
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

    func toSections() -> [PrivacyProtectionTrackerNetworksController.Section] {
        return []
    }

}
