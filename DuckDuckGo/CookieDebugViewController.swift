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

class CookieDebugViewController: UITableViewController {

    var cookies = [HTTPCookie]()
    var loaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCookies()
    }

    private func fetchCookies() {
        WKWebsiteDataStore.default().cookieStore?.getAllCookies(displayCookies)
    }

    private func displayCookies(cookies: [HTTPCookie]) {
        self.loaded = true
        self.cookies = cookies
            .sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
            .sorted(by: { $0.path.lowercased() < $1.path.lowercased() })
            .sorted(by: { String($0.domain.reversed()) < String($1.domain.reversed())})
            .reversed()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cookies.isEmpty ? 1 : cookies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if cookies.isEmpty {
            cell = tableView.dequeueReusableCell(withIdentifier: "Info")!
            cell.textLabel?.text = loaded ? "No cookies" : "Loading"
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "Cookie")!
            cell.textLabel?.text = cookies[indexPath.row].domain + cookies[indexPath.row].path
            cell.detailTextLabel?.text = cookies[indexPath.row].name +
                "=" +
                (cookies[indexPath.row].value.isEmpty ? "<no value>" : cookies[indexPath.row].value) +
                ", expires=" +
                (cookies[indexPath.row].expiresDate == nil ? "<no value>" : String(describing: cookies[indexPath.row].expiresDate!))
        }
        return cell
    }

}
