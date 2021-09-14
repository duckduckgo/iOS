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

class BookmarkFoldersViewController: UITableViewController {

    var dataSource: FolderDetailsDataSource = BookmarksFolderDetailsDataSource()
    
    var existingFolder: BookmarkFolder? {
        didSet {
            dataSource = BookmarksFolderDetailsDataSource(existingFolder: existingFolder)
            tableView.dataSource = dataSource
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataSource.select(tableView, indexPath: indexPath)
    }
    
    func save() {
        dataSource.save(tableView)
    }
}

// TODO NEXT UP
/*
 can either do rest of cell styling or the other elements of this page

 Need to at least do the title colour
 let's do the add folder title cell
 */
