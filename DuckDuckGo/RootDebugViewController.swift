//
//  RootDebugViewController.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
import LinkPresentation
import Core
import Kingfisher
import WebKit
import BrowserServicesKit
import Common
import Configuration
import Persistence
import DDGSync

class RootDebugViewController: UITableViewController {

    enum Row: Int {
        case crashFatalError = 666
        case crashMemory = 667
        case toggleInspectableWebViews = 668
        case toggleInternalUserState = 669
        case openVanillaBrowser = 670
    }

    @IBOutlet weak var shareButton: UIBarButtonItem!

    weak var reportGatheringActivity: UIView?

    @IBAction func onShareTapped() {
        presentShareSheet(withItems: [DiagnosticReportDataSource(delegate: self)], fromButtonItem: shareButton)
    }

    private var bookmarksDatabase: CoreDataDatabase?
    private var sync: DDGSyncing?
    private var internalUserDecider: DefaultInternalUserDecider?
    var tabManager: TabManager?

    init?(coder: NSCoder,
          sync: DDGSyncing,
          bookmarksDatabase: CoreDataDatabase,
          internalUserDecider: InternalUserDecider,
          tabManager: TabManager) {

        self.sync = sync
        self.bookmarksDatabase = bookmarksDatabase
        self.internalUserDecider = internalUserDecider as? DefaultInternalUserDecider
        self.tabManager = tabManager
        super.init(coder: coder)
    }
        
    func configure(sync: DDGSyncing, bookmarksDatabase: CoreDataDatabase, internalUserDecider: InternalUserDecider, tabManager: TabManager) {
        self.sync = sync
        self.bookmarksDatabase = bookmarksDatabase
        self.internalUserDecider = internalUserDecider as? DefaultInternalUserDecider
        self.tabManager = tabManager
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @IBSegueAction func onCreateImageCacheDebugScreen(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> ImageCacheDebugViewController {
        guard let controller = ImageCacheDebugViewController(coder: coder,
                                                             bookmarksDatabase: self.bookmarksDatabase!) else {
            fatalError("Failed to create controller")
        }

        return controller
    }

    @IBSegueAction func onCreateSyncDebugScreen(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> SyncDebugViewController {
        guard let controller = SyncDebugViewController(coder: coder,
                                                       sync: self.sync!,
                                                       bookmarksDatabase: self.bookmarksDatabase!) else {
            fatalError("Failed to create controller")
        }

        return controller
    }

    @IBSegueAction func onCreateNetPDebugScreen(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> NetworkProtectionDebugViewController {
        guard let controller = NetworkProtectionDebugViewController(coder: coder) else {
            fatalError("Failed to create controller")
        }

        return controller
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.tag == Row.toggleInspectableWebViews.rawValue {
            cell.accessoryType = AppUserDefaults().inspectableWebViewEnabled ? .checkmark : .none
        } else if cell.tag == Row.toggleInternalUserState.rawValue {
            cell.accessoryType = (internalUserDecider?.isInternalUser ?? false) ? .checkmark : .none
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }

        if let rowTag = tableView.cellForRow(at: indexPath)?.tag,
            let row = Row(rawValue: rowTag),
           let cell = tableView.cellForRow(at: indexPath) {

            switch row {
            case .crashFatalError:
                fatalError(#function)
            case .crashMemory:
                var arrays = [String]()
                while 1 != 2 {
                    arrays.append(UUID().uuidString)
                }
            case .toggleInspectableWebViews:
                let defaults = AppUserDefaults()
                defaults.inspectableWebViewEnabled.toggle()
                cell.accessoryType = defaults.inspectableWebViewEnabled ? .checkmark : .none
                NotificationCenter.default.post(Notification(name: AppUserDefaults.Notifications.inspectableWebViewsToggled))
            case .toggleInternalUserState:
                let newState = !(internalUserDecider?.isInternalUser ?? false)
                internalUserDecider?.debugSetInternalUserState(newState)
                cell.accessoryType = newState ? .checkmark : .none
                NotificationCenter.default.post(Notification(name: AppUserDefaults.Notifications.inspectableWebViewsToggled))
            case .openVanillaBrowser:
                openVanillaBrowser(nil)
            }
        }
    }
}

extension RootDebugViewController: DiagnosticReportDataSourceDelegate {

    func dataGatheringStarted() {
        DispatchQueue.main.async {
            let background = UIView()
            background.frame = self.view.window?.frame ?? .zero
            background.center = self.view.window?.center ?? .zero
            background.backgroundColor = .black.withAlphaComponent(0.5)
            self.view.window?.addSubview(background)
            self.reportGatheringActivity = background

            let activity = UIActivityIndicatorView()
            activity.startAnimating()
            activity.style = .large
            activity.center = background.center
            background.addSubview(activity)
        }
    }

    func dataGatheringComplete() {
        DispatchQueue.main.async {
            self.reportGatheringActivity?.removeFromSuperview()
        }
    }

}

protocol DiagnosticReportDataSourceDelegate: AnyObject {

    func dataGatheringStarted()
    func dataGatheringComplete()

}

class DiagnosticReportDataSource: UIActivityItemProvider {

    weak var delegate: DiagnosticReportDataSourceDelegate?

    @UserDefaultsWrapper(key: .lastConfigurationRefreshDate, defaultValue: .distantPast)
    private var lastRefreshDate: Date

    convenience init(delegate: DiagnosticReportDataSourceDelegate) {
        self.init(placeholderItem: "")
        self.delegate = delegate
    }

    override var item: Any {
        delegate?.dataGatheringStarted()

        let report = [reportHeader(),
                      tabsReport(),
                      imageCacheReport(),
                      fireproofingReport(),
                      configurationReport(),
                      cookiesReport()].joined(separator: "\n\n")

        delegate?.dataGatheringComplete()
        return report
    }

    override func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = "Diagnostic Report"
        return metadata
    }

    func reportHeader() -> String {
        """
        # DuckDuckGo App Diagnostic Report
        Date: \(String(describing: Date()))
        Version: \(AppVersion.shared.versionAndBuildNumber)
        """
    }

    func fireproofingReport() -> String {
        let allowedDomains = PreserveLogins.shared.allowedDomains.map { "* \($0)" }

        let allowedDomainsEntry = ["### Allowed Domains"] + (allowedDomains.isEmpty ? [""] : allowedDomains)

        return (["## Fireproofing Report"] + allowedDomainsEntry).joined(separator: "\n")
    }

    func imageCacheReport() -> String {
        """
        ## Image Cache Report
        Bookmark Cache: \(Favicons.Constants.caches[.fireproof]?.count ?? -1)
        Tabs Cache: \(Favicons.Constants.caches[.tabs]?.count ?? -1)
        """
    }

    func configurationReport() -> String {
        let etagStorage = DebugEtagStorage()
        let configs = Configuration.allCases.map { $0.rawValue + ": " + (etagStorage.loadEtag(for: $0.storeKey) ?? "<none>") }
        let lastRefreshDate = "Last refresh date: \(lastRefreshDate == .distantPast ? "Never" : String(describing: lastRefreshDate))"
        return (["## Configuration Report"] + [lastRefreshDate] + configs).joined(separator: "\n")
    }

    func cookiesReport() -> String {
        var cookies = [HTTPCookie]()

        let group = DispatchGroup()
        group.enter()
        DispatchQueue.main.async {
            WKWebsiteDataStore.current().httpCookieStore.getAllCookies { httpCookies in
                cookies = httpCookies
                group.leave()
            }
        }

        var timeout = [String]()
        if group.wait(timeout: .now() + 10) == .timedOut {
            timeout = ["Failed to retrieve cookies in 10 seconds"]
        }

        let processedCookies = cookies
            .sorted(by: { $0.domain < $1.domain })
            .sorted(by: { $0.name < $1.name })
            .map { $0.debugString }

        return (["## Cookie Report"] + timeout + processedCookies).joined(separator: "\n")
    }

    func tabsReport() -> String {
        """
        ### Tabs Report
        Tabs: \(TabsModel.get()?.count ?? -1)
        """
    }

}

private extension ImageCache {

    var count: Int {
        let url = diskStorage.directoryURL
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: url.path)
            return contents.count
        } catch {
            return -2
        }
    }

}

private extension HTTPCookie {

    var debugString: String {
        """
        \(domain)\(path):\(name)=\(value.isEmpty ? "<blank>" : "<value>")\(expiresDate != nil ? ";expires=\(String(describing: expiresDate!))" : "")
        """
    }

}
