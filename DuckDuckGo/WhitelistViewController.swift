//
//  WhitelistViewController.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
import Core

class WhitelistViewController: UITableViewController {

    let whitelistManager = WhitelistManager()

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return whitelistManager.count == 0 ? 1 : whitelistManager.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard whitelistManager.count > 0 else {
            return tableView.dequeueReusableCell(withIdentifier: "NoWhitelistCell")!
        }
        let whitelistItemCell = tableView.dequeueReusableCell(withIdentifier: "WhitelistItemCell") as! WhitelistItemCell
        whitelistItemCell.domain = whitelistManager.domain(at: indexPath.row)
        return whitelistItemCell
    }

}

class WhitelistItemCell: UITableViewCell {

    @IBOutlet weak var domainLabel: UILabel!

    var domain: String? {
        get {
            return domainLabel.text
        }
        set {
            domainLabel.text = newValue
        }
    }

}
