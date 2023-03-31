//
//  ConfigurationDebugViewController.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
import BackgroundTasks
import Core

class ConfigurationDebugViewController: UITableViewController {

    private let titles = [
        Sections.refreshInformation: "Background Refresh Info",
        Sections.queuedTasks: "Queued Tasks (Earliest Execution Date)",
        Sections.etags: "ETags"
    ]

    enum Sections: Int, CaseIterable {

        case refreshInformation
        case queuedTasks
        case etags

    }

    enum RefreshInformationRows: Int, CaseIterable {

        case lastRefreshDate
        case resetLastRefreshDate
        case copyConfigLocationPath
        case forceRefresh

    }

    enum ETagRows: String, CaseIterable {

        case httpsBloomFilterSpec
        case httpsBloomFilter
        case httpsExcludedDomains
        case surrogates
        case trackerDataSet
        case privacyConfiguration
        case resetEtags = "Reset ETags"

        var showDetail: Bool {
            return self != .resetEtags
        }

    }

    @UserDefaultsWrapper(key: .lastConfigurationRefreshDate, defaultValue: .distantPast)
    private var lastConfigurationRefreshDate: Date
    private var queuedTasks: [BGTaskRequest] = []
    private let etagStorage = DebugEtagStorage()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        BGTaskScheduler.shared.getPendingTaskRequests { tasks in
            let filteredTasks = tasks.filter { $0.identifier == AppConfigurationFetch.Constants.backgroundProcessingTaskIdentifier }
            self.queuedTasks = filteredTasks

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Sections(rawValue: section) else { return nil }
        return titles[section]
    }

    // swiftlint:disable cyclomatic_complexity
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        switch Sections(rawValue: indexPath.section) {

        case .refreshInformation:
            switch RefreshInformationRows(rawValue: indexPath.row) {
            case .lastRefreshDate:
                cell.textLabel?.text = "Last Refresh"

                if lastConfigurationRefreshDate == Date.distantPast {
                    cell.detailTextLabel?.text = "Never"
                } else {
                    cell.detailTextLabel?.text = dateFormatter.string(from: lastConfigurationRefreshDate)
                }
            case .resetLastRefreshDate:
                cell.textLabel?.text = "Reset Last Refresh Date"
            case .copyConfigLocationPath:
                cell.textLabel?.text = "Copy Location of Config Files to Pasteboard"
            case .forceRefresh:
                cell.textLabel?.text = "Trigger refresh"
            case .none:
                break
            }

        case .queuedTasks:
            if queuedTasks.isEmpty {
                cell.textLabel?.text = "None"
            } else {
                cell.textLabel?.text = dateFormatter.string(from: queuedTasks[indexPath.row].earliestBeginDate!)
            }

        case .etags:
            let row = ETagRows.allCases[indexPath.row]
            cell.textLabel?.text = row.rawValue

            if let etag = etagStorage.loadEtag(for: row.rawValue) {
                cell.detailTextLabel?.text = etag
            } else {
                cell.detailTextLabel?.text = row.showDetail ? "None" : nil
            }

        default: break
        }

        return cell
    }
    // swiftlint:enable cyclomatic_complexity

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .refreshInformation: return RefreshInformationRows.allCases.count
        case .queuedTasks: return queuedTasks.isEmpty ? 1 : queuedTasks.count
        case .etags: return ETagRows.allCases.count
        case .none: return 0
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Sections(rawValue: indexPath.section) {
        case .refreshInformation:
            switch RefreshInformationRows(rawValue: indexPath.row) {
            case .resetLastRefreshDate:
                lastConfigurationRefreshDate = Date.distantPast
                tableView.reloadData()
            case .copyConfigLocationPath:
                let location = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: ContentBlockerStoreConstants.groupName)
                UIPasteboard.general.string = location?.path ?? ""
            case .forceRefresh:
                AppConfigurationFetch().start { [weak tableView] result in
                    switch result {
                    case .assetsUpdated(let protectionsUpdated):
                        if protectionsUpdated {
                            ContentBlocking.shared.contentBlockingManager.scheduleCompilation()
                        }
                        DispatchQueue.main.async {
                            tableView?.reloadData()
                        }
                    case .noData:
                        break
                    }
                }
            default: break
            }
        case .etags:
            switch ETagRows.allCases[indexPath.row] {
            case .resetEtags:
                etagStorage.resetAll()
                tableView.reloadData()
            default: break
            }
        default: break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

}
