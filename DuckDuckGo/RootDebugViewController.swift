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

class RootDebugViewController: UITableViewController {

    @IBOutlet weak var shareButton: UIBarButtonItem!

    weak var reportGatheringActivity: UIView?

    @IBAction func onShareTapped() {
        presentShareSheet(withItems: [DiagnosticReportDataSource(delegate: self)], fromButtonItem: shareButton)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.tag == 666 {
            fatalError(#function)
        }

        if tableView.cellForRow(at: indexPath)?.tag == 667 {
            var arrays = [String]()
            while 1 != 2 {
                arrays.append(UUID().uuidString)
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
        let legacyAllowedDomains = PreserveLogins.shared.legacyAllowedDomains.map { "* \($0)" }

        let allowedDomainsEntry = ["### Allowed Domains"] + (allowedDomains.isEmpty ? [""] : allowedDomains)
        let legacyAllowedDomainsEntry = ["### Legacy Allowed Domains"] + (legacyAllowedDomains.isEmpty ? [""] : legacyAllowedDomains)

        return (["## Fireproofing Report"] + allowedDomainsEntry + legacyAllowedDomainsEntry).joined(separator: "\n")
    }

    func imageCacheReport() -> String {
        """
        ## Image Cache Report
        Bookmark Cache: \(Favicons.Constants.caches[.bookmarks]?.count ?? -1)
        Tabs Cache: \(Favicons.Constants.caches[.tabs]?.count ?? -1)
        """
    }

    func configurationReport() -> String {
        let etagStorage = DebugEtagStorage()
        let configs = ContentBlockerRequest.Configuration.allCases.map { $0.rawValue + ": " + (etagStorage.etag(for: $0.rawValue) ?? "<none>") }
        let lastRefreshDate = "Last refresh date: \(lastRefreshDate == .distantPast ? "Never" : String(describing: lastRefreshDate))"
        return (["## Configuration Report"] + [lastRefreshDate] + configs).joined(separator: "\n")
    }

    func cookiesReport() -> String {
        var cookies = [HTTPCookie]()

        let group = DispatchGroup()
        group.enter()
        DispatchQueue.main.async {
            WKWebsiteDataStore.default().cookieStore?.getAllCookies { httpCookies in
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
