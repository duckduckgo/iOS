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

import BrowserServicesKit
import Common
import Configuration
import Core
import Crashes
import DDGSync
import Kingfisher
import LinkPresentation
import NetworkProtection
import Persistence
import SwiftUI
import UIKit
import WebKit

class RootDebugViewController: UITableViewController {

    enum Row: Int {
        case resetAutoconsentPrompt = 665
        case crashFatalError = 666
        case crashMemory = 667
        case crashException = 673
        case crashCxxException = 675
        case toggleInspectableWebViews = 668
        case toggleInternalUserState = 669
        case openVanillaBrowser = 670
        case resetSendCrashLogs = 671
        case refreshConfig = 672
        case newTabPageSections = 674
        case onboarding = 676
        case resetSyncPromoPrompts = 677
        case resetTipKit = 681
        case aiChat = 682
        case webViewStateRestoration = 683
        case featureFlags = 684
    }

    @IBOutlet weak var shareButton: UIBarButtonItem!

    weak var reportGatheringActivity: UIView?

    @IBAction func onShareTapped() {
        presentShareSheet(withItems: [DiagnosticReportDataSource(delegate: self, fireproofing: fireproofing)], fromButtonItem: shareButton)
    }

    private let bookmarksDatabase: CoreDataDatabase
    private let sync: DDGSyncing
    private let internalUserDecider: InternalUserDecider
    let tabManager: TabManager
    private let tipKitUIActionHandler: TipKitDebugOptionsUIActionHandling
    private let fireproofing: Fireproofing

    @UserDefaultsWrapper(key: .lastConfigurationRefreshDate, defaultValue: .distantPast)
    private var lastConfigurationRefreshDate: Date

    init?(coder: NSCoder,
          sync: DDGSyncing,
          bookmarksDatabase: CoreDataDatabase,
          internalUserDecider: InternalUserDecider,
          tabManager: TabManager,
          tipKitUIActionHandler: TipKitDebugOptionsUIActionHandling = TipKitDebugOptionsUIActionHandler(),
          fireproofing: Fireproofing) {

        self.sync = sync
        self.bookmarksDatabase = bookmarksDatabase
        self.internalUserDecider = internalUserDecider
        self.tabManager = tabManager
        self.tipKitUIActionHandler = tipKitUIActionHandler
        self.fireproofing = fireproofing

        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init not implemented")
    }

    @IBSegueAction func onCreateImageCacheDebugScreen(_ coder: NSCoder) -> ImageCacheDebugViewController? {
        guard let controller = ImageCacheDebugViewController(coder: coder,
                                                             bookmarksDatabase: self.bookmarksDatabase,
                                                             fireproofing: fireproofing) else {
            fatalError("Failed to create controller")
        }

        return controller
    }

    @IBSegueAction func onCreateSyncDebugScreen(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> SyncDebugViewController {
        guard let controller = SyncDebugViewController(coder: coder,
                                                       sync: self.sync,
                                                       bookmarksDatabase: self.bookmarksDatabase) else {
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

    @IBSegueAction func onCreateCookieDebugScreen(_ coder: NSCoder) -> CookieDebugViewController? {
        guard let controller = CookieDebugViewController(coder: coder, fireproofing: fireproofing) else {
            fatalError("Failed to create controller")
        }

        return controller
    }


    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.tag == Row.toggleInspectableWebViews.rawValue {
            cell.accessoryType = AppUserDefaults().inspectableWebViewEnabled ? .checkmark : .none
        } else if cell.tag == Row.toggleInternalUserState.rawValue {
            cell.accessoryType = (internalUserDecider.isInternalUser) ? .checkmark : .none
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
            case .resetAutoconsentPrompt:
                AppUserDefaults().clearAutoconsentUserSetting()
            case .crashFatalError:
                fatalError(#function)
            case .crashMemory:
                var arrays = [String]()
                while 1 != 2 {
                    arrays.append(UUID().uuidString)
                }
            case .crashException:
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            case .crashCxxException:
                throwTestCppExteption()
            case .toggleInspectableWebViews:
                let defaults = AppUserDefaults()
                defaults.inspectableWebViewEnabled.toggle()
                cell.accessoryType = defaults.inspectableWebViewEnabled ? .checkmark : .none
                NotificationCenter.default.post(Notification(name: AppUserDefaults.Notifications.inspectableWebViewsToggled))
            case .toggleInternalUserState:
                let newState = !internalUserDecider.isInternalUser
                (internalUserDecider as? DefaultInternalUserDecider)?.debugSetInternalUserState(newState)
                cell.accessoryType = newState ? .checkmark : .none
                NotificationCenter.default.post(Notification(name: AppUserDefaults.Notifications.inspectableWebViewsToggled))
            case .openVanillaBrowser:
                openVanillaBrowser(nil)
            case .resetSendCrashLogs:
                AppUserDefaults().crashCollectionOptInStatus = .undetermined
            case .refreshConfig:
                fetchAssets()
            case .newTabPageSections:
                let controller = UIHostingController(rootView: NewTabPageSectionsDebugView())
                show(controller, sender: nil)
            case .onboarding:
                let action = { [weak self] in
                    guard let self else { return }
                    self.showOnboardingIntro()
                }
                let controller = UIHostingController(rootView: OnboardingDebugView(onNewOnboardingIntroStartAction: action))
                show(controller, sender: nil)
            case .resetSyncPromoPrompts:
                let syncPromoPresenter = SyncPromoManager(syncService: sync)
                syncPromoPresenter.resetPromos()
                ActionMessageView.present(message: "Sync Promos reset")
            case .resetTipKit:
                tipKitUIActionHandler.resetTipKitTapped()
            case .aiChat:
                let controller = UIHostingController(rootView: AIChatDebugView())
                navigationController?.pushViewController(controller, animated: true)
            case .webViewStateRestoration:
                let controller = UIHostingController(rootView: WebViewStateRestorationDebugView())
                navigationController?.pushViewController(controller, animated: true)
            case .featureFlags:
                let hostingController = UIHostingController(rootView: FeatureFlagsMenuView())
                navigationController?.pushViewController(hostingController, animated: true)
            }
        }
    }

    func fetchAssets() {
        self.lastConfigurationRefreshDate = Date.distantPast
        AppConfigurationFetch().start(isDebug: true) { [weak tableView] result in
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
    var fireproofing: Fireproofing?

    @UserDefaultsWrapper(key: .lastConfigurationRefreshDate, defaultValue: .distantPast)
    private var lastRefreshDate: Date

    convenience init(delegate: DiagnosticReportDataSourceDelegate, fireproofing: Fireproofing) {
        self.init(placeholderItem: "")
        self.delegate = delegate
        self.fireproofing = fireproofing
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
        let allowedDomains = fireproofing?.allowedDomains.map { "* \($0)" } ?? []

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
