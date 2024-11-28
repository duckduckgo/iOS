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

    }

    var cookies = [DomainCookies]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    var loaded = false
    let fireproofing: Fireproofing

    init?(coder: NSCoder, fireproofing: Fireproofing) {
        self.fireproofing = fireproofing
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCookies()
    }

    private func fetchCookies() {
        Task { @MainActor in
            let dataStore = WKWebsiteDataStore.current()
            displayCookies(cookies: await dataStore.httpCookieStore.allCookies())
        }
    }

    @MainActor
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

            let domainName = domain +
                (fireproofing.isAllowed(cookieDomain: domain) ? " 👩‍🚒" : "")

            tmp.append(DomainCookies(domain: domainName, cookies: domainCookies))
        }
        self.cookies = tmp
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return cookies.isEmpty ? 1 : cookies.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cookies.isEmpty ? 1 : cookies[section].cookies.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return cookies.isEmpty ? "" : cookies[section].domain
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
