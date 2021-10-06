//
//  AddOrEditBookmarkViewController.swift
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
            setUpTitle()
            setUpDataSource()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTitle()
    }
    
    private func setUpTitle() {
        if let bookmark = existingBookmark {
            if bookmark.isFavorite {
                title = NSLocalizedString("Edit Favorite", comment: "Edit favorite screen title")
            } else {
                title = NSLocalizedString("Edit Bookmark", comment: "Edit bookmark screen title")
            }
        } else {
            if isFavorite {
                title = NSLocalizedString("Add Favorite", comment: "Add favorite screen title")
            } else {
                title = NSLocalizedString("Add Bookmark", comment: "Add bookmark screen title")
            }
        }
    }
    
    private func setUpDataSource() {
        if existingBookmark?.isFavorite ?? isFavorite {
            foldersViewController?.dataSource = FavoriteDetailsDataSource(existingBookmark: existingBookmark)
        } else {
            foldersViewController?.dataSource = BookmarkDetailsDataSource(existingBookmark: existingBookmark)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedFoldersTableViewControllerSegue" {
            foldersViewController = segue.destination as? BookmarkFoldersViewController
            setUpDataSource()
        }
    }
    
    @IBAction func onDonePressed(_ sender: Any) {
        foldersViewController?.save()
        navigationController?.popViewController(animated: true)
    }
}
