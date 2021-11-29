//
//  BookmarkFoldersTableViewController.swift
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
import Core

//TODO this should be renamed...
class BookmarkFoldersViewController: UITableViewController {

    //TODO This should be purely injected I reckon?
    //now I'm just wondering if this should be one view controller again...
    //let's worry about it after the design review
    //if we do we should probs unify the datasources
    var dataSource: BookmarkItemDetailsDataSource? {
        didSet {
            tableView.dataSource = dataSource
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataSource?.select(tableView, indexPath: indexPath)
    }
    
    func save(delegate: BookmarkItemDetailsDataSourceDidSaveDelegate? = nil) {
        dataSource?.save(tableView, delegate: delegate)
    }
}
