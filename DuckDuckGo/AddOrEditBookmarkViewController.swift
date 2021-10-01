//
//  AddBookmarksFolderViewController.swift
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

class AddOrEditBookmarkViewController: UIViewController {
    
    private var foldersViewController: BookmarkFoldersViewController?
    
    var isFavorite = false
        
    var existingBookmark: Bookmark? {
        didSet {
            foldersViewController?.dataSource = BookmarkDetailsDataSource(isFavorite: existingBookmark?.isFavorite ?? isFavorite, existingBookmark: existingBookmark)
            setUpTitle()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTitle()
        if existingBookmark == nil {
            foldersViewController?.dataSource = BookmarkDetailsDataSource(isFavorite: isFavorite)
        }
    }
    
    func setUpTitle() {
        if existingBookmark != nil {
            title = NSLocalizedString("Edit Boomkark", comment: "Edit bookmark screen title")
        } else {
            title = NSLocalizedString("Add Bookmark", comment: "Add bookmark screen title")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedFoldersTableViewControllerSegue" {
            foldersViewController = segue.destination as? BookmarkFoldersViewController
            foldersViewController?.dataSource =  BookmarkDetailsDataSource(isFavorite: existingBookmark?.isFavorite ?? isFavorite, existingBookmark: existingBookmark)
        }
    }
    
    @IBAction func onDonePressed(_ sender: Any) {
        foldersViewController?.save()
        dismiss(animated: true, completion: nil)
    }
}
