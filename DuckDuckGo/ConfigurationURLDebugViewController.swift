//
//  ConfigurationURLDebugViewController.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import WebKit
import Core
import Configuration
import DesignResourcesKit

final class ConfigurationURLDebugViewController: UITableViewController {

    enum Sections: Int, CaseIterable {

        case customURLs

    }

    enum CustomURLsRows: Int, CaseIterable {

        case privacyConfigURL

        var title: String {
            switch self {
            case .privacyConfigURL: return "Privacy Config"
            }
        }

    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        return formatter
    }()

    private var customURLProvider = CustomConfigurationURLProvider()

    @UserDefaultsWrapper(key: .lastConfigurationRefreshDate, defaultValue: .distantPast)
    private var lastConfigurationRefreshDate: Date

    @UserDefaultsWrapper(key: .lastConfigurationUpdateDate, defaultValue: nil)
    private var lastConfigurationUpdateDate: Date?

    @UserDefaultsWrapper(key: .privacyConfigCustomURL, defaultValue: nil)
    private var privacyConfigCustomURL: String? {
        didSet {
            customURLProvider.customPrivacyConfigurationURL = privacyConfigCustomURL.flatMap { URL(string: $0) }
            Configuration.setURLProvider(customURLProvider)
            lastConfigurationRefreshDate = Date.distantPast
            fetchAssets()
        }
    }

    private func customURL(for row: CustomURLsRows) -> String? {
        switch row {
        case .privacyConfigURL: return privacyConfigCustomURL
        }
    }

    private func url(for row: CustomURLsRows) -> String {
        switch row {
        case .privacyConfigURL: return customURL(for: row) ?? customURLProvider.url(for: .privacyConfiguration).absoluteString
        }
    }

    private func setCustomURL(_ urlString: String?, for row: CustomURLsRows) {
        switch row {
        case .privacyConfigURL: privacyConfigCustomURL = urlString
        }
    }

    private func fetchAssets() {
        AppConfigurationFetch().start(isDebug: true) { [weak tableView] result in
            switch result {
            case .assetsUpdated(let protectionsUpdated):
                if protectionsUpdated {
                    ContentBlocking.shared.contentBlockingManager.scheduleCompilation()
                    DispatchQueue.main.async {
                        self.lastConfigurationUpdateDate = Date()
                    }
                }
                DispatchQueue.main.async {
                    tableView?.reloadData()
                }

            case .noData:
                break
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        Sections.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .customURLs: return CustomURLsRows.allCases.count
        case nil: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = CustomURLsRows(rawValue: indexPath.row)!
        guard let cell =
                tableView.dequeueReusableCell(withIdentifier: ConfigurationURLTableViewCell.reuseIdentifier) as?  ConfigurationURLTableViewCell else {
            fatalError("Failed to dequeue cell")
        }
        cell.title.text = row.title
        cell.subtitle.text = url(for: row)
        cell.subtitle.textColor = customURL(for: row) != nil ? UIColor(designSystemColor: .accent) : .label
        cell.ternary.text = lastConfigurationUpdateDate != nil ? dateFormatter.string(from: lastConfigurationUpdateDate!) : "-"
        cell.refresh.addAction(refreshAction, for: .primaryActionTriggered)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = CustomURLsRows(rawValue: indexPath.row)!
        presentCustomURLAlert(for: row)
    }

    private lazy var refreshAction = UIAction { [weak self] _ in
        self?.lastConfigurationRefreshDate = Date.distantPast
        self?.fetchAssets()
        self?.tableView.reloadData()
    }

    private func presentCustomURLAlert(for row: CustomURLsRows) {
        let alert = UIAlertController(title: row.title, message: "Provide custom URL", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.tag = row.rawValue
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.tableView.reloadData()
        }
        alert.addAction(cancelAction)

        if customURL(for: row) != nil {
            let resetToDefaultAction = UIAlertAction(title: "Reset to default URL", style: .default) { _ in
                self.privacyConfigCustomURL = nil
            }
            alert.addAction(resetToDefaultAction)
        }

        let submitAction = UIAlertAction(title: "Override", style: .default) { _ in
            self.setCustomURL(alert.textFields?.first?.text, for: row)
            self.tableView.reloadData()
        }
        alert.addAction(submitAction)
        let cell = self.tableView.cellForRow(at: IndexPath(row: row.rawValue,
                                                           section: Sections.customURLs.rawValue))!
        present(controller: alert, fromView: cell)
    }

}

struct CustomConfigurationURLProvider: ConfigurationURLProviding {

    var customBloomFilterSpecURL: URL?
    var customBloomFilterBinaryURL: URL?
    var customBloomFilterExcludedDomainsURL: URL?
    var customPrivacyConfigurationURL: URL?
    var customTrackerDataSetURL: URL?
    var customSurrogatesURL: URL?
    var customRemoteMessagingConfigURL: URL?

    let defaultProvider = AppConfigurationURLProvider()

    func url(for configuration: Configuration) -> URL {
        let defaultURL = defaultProvider.url(for: configuration)
        let customURL: URL?
        switch configuration {
        case .bloomFilterSpec: customURL = customBloomFilterSpecURL
        case .bloomFilterBinary: customURL = customBloomFilterBinaryURL
        case .bloomFilterExcludedDomains: customURL = customBloomFilterExcludedDomainsURL
        case .privacyConfiguration: customURL = customPrivacyConfigurationURL
        case .trackerDataSet: customURL = customTrackerDataSetURL
        case .surrogates: customURL = customSurrogatesURL
        case .remoteMessagingConfig: customURL = customRemoteMessagingConfigURL
        }
        return customURL ?? defaultURL
    }

}

final class ConfigurationURLTableViewCell: UITableViewCell {

    static let reuseIdentifier = "ConfigurationURLTableViewCell"

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var refresh: UIButton!
    @IBOutlet weak var ternary: UILabel!

}
