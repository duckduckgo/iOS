//
//  CookieDebugViewController.swift
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
import WebKit
import Core

class CookieDebugViewController: UITableViewController {

    struct DomainCookies {
        let domain: String
        let cookies: [HTTPCookie]
        let isProtected: Bool
    }

    @IBOutlet var cookieSourceSegmentedControl: UISegmentedControl!
    @IBOutlet var cookieSummaryLabel: UILabel!

    var cookies = [DomainCookies]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    var loaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCookies()
    }
    
    @IBAction func cookieSourceValueChanged(_ sender: Any) {
        fetchCookies()
    }

    private func fetchCookies() {
        loaded = false
        cookies = []
        tableView.reloadData()
        cookieSummaryLabel.text = ""
        
        switch cookieSourceSegmentedControl.selectedSegmentIndex {
        case 0: fetchCookiesFromStore() // WKHTTPCookieStore
        case 1: fetchCookiesFromStorage() // HTTPCookieStorage
        default: break
        }
    }
    
    private func fetchCookiesFromStore() {
        WKWebsiteDataStore.default().cookieStore?.getAllCookies(displayCookies)
    }
    
    private func fetchCookiesFromStorage() {
        let cookies = HTTPCookieStorage.shared.cookies ?? []
        displayCookies(cookies: cookies)
    }
    
    private func displayCookies(cookies: [HTTPCookie]) {
        self.loaded = true

        var tmp = [DomainCookies]()
        let domains = Set<String>(cookies.map { $0.domain })
        for domain in domains.sorted(by: { String($0.reversed()) < String($1.reversed()) }) {
            let domainCookies = [HTTPCookie](cookies
                .filter({ $0.domain == domain })
                .sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
                .sorted(by: { $0.path.lowercased() < $1.path.lowercased() })
                .reversed())

            var domainName = domain
            var isProtected = false
            
            if PreserveLogins.shared.isAllowed(cookieDomain: domain) {
                domainName += " 👩‍🚒"
                isProtected = true
            }
            if domain == "duckduckgo.com" {
                domainName += " 🦆"
                isProtected = true
            }

            tmp.append(DomainCookies(domain: domainName, cookies: domainCookies, isProtected: isProtected))
        }
        self.cookies = tmp
        self.displayCookieSummary()
    }
    
    private func displayCookieSummary() {
        let summary =
        """
        All 🍪 count: \(cookies.reduce(0) { $0 + $1.cookies.count })
        Protected 🍪 count: \(cookies.filter { $0.isProtected }.reduce(0) { $0 + $1.cookies.count })
        """
        
        cookieSummaryLabel.text = summary
    }
    
    // MARK: Table view

    override func numberOfSections(in tableView: UITableView) -> Int {
        return cookies.isEmpty ? 1 : cookies.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cookies.isEmpty ? 1 : cookies[section].cookies.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return cookies.isEmpty ? "" : cookies[section].domain + " (\(cookies[section].cookies.count))"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if cookies.isEmpty {
            cell = tableView.dequeueReusableCell(withIdentifier: "Info")!
            cell.textLabel?.text = loaded ? "No cookies" : "Loading"
        } else {
            let cookie = cookies[indexPath.section].cookies[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: "Cookie")!
            cell.textLabel?.text = cookie.path + " " + cookie.name + "=" + cookie.value
            cell.detailTextLabel?.text = cookie.expiresDate == nil ? nil : String(describing: cookie.expiresDate!)
        }
        return cell
    }

}
