//
//  BookmarkFoldersSectionDataSource.swift
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
import CoreData

protocol BookmarkFoldersSectionDataSourceAddFolderDelegate: AnyObject {
    func bookmarkFoldersSectionDataSourceDidRequestAddNewFolder(_ bookmarkFoldersSectionDataSource: BookmarkFoldersSectionDataSource)
}

class BookmarkFoldersSectionDataSource: BookmarksSectionDataSource {
    
    typealias PresentableFolder = (folder: BookmarkFolder, depth: Int)
    
    weak var delegate: BookmarkFoldersSectionDataSourceAddFolderDelegate?

    private let bookmarksManager: BookmarksManager

    private lazy var PresentableFolders: [PresentableFolder] = {
        guard let folder = bookmarksManager.topLevelBookmarksFolder else {
            return []
        }
        return visibleFolders(for: folder, depthOfFolder: 0)
    }()
    
    private var selectedRow = 0
    private let existingItem: BookmarkItem?
    private let shouldShowAddFolderCell: Bool
    
    init(existingItem: BookmarkItem?, initialParentFolder: BookmarkFolder?, delegate: BookmarkFoldersSectionDataSourceAddFolderDelegate?, bookmarksManager: BookmarksManager) {
        self.existingItem = existingItem
        self.delegate = delegate
        self.bookmarksManager = bookmarksManager
        self.shouldShowAddFolderCell = delegate != nil
                
        if let parent = existingItem?.parentFolder ?? initialParentFolder {
            let parentIndex = PresentableFolders.firstIndex {
                $0.folder.objectID == parent.objectID
            }
            selectedRow = parentIndex ?? 0
        }
    }
    
    var numberOfRows: Int {
        return PresentableFolders.count + (shouldShowAddFolderCell ? 1 : 0)
    }
    
    func title() -> String? {
        UserText.bookmarkFolderSelectTitle
    }
    
    func cell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkFolderCell.reuseIdentifier) as? BookmarkFolderCell else {
            fatalError("Failed to dequeue \(BookmarkFolderCell.reuseIdentifier) as BookmarkFolderCell")
        }
        
        if let folder = folder(at: index) {
            cell.folder = folder.folder
            cell.depth = folder.depth
            cell.isSelected = index == selectedRow
            
            if index == 0 {
                cell.titleString = UserText.bookmarkTopLevelFolderTitle

            }
        } else {
            cell.setUpAddFolderCell()
            cell.isSelected = false
        }
        
        return cell
    }
    
    func select(_ tableView: UITableView, row: Int, section: Int) {
        if shouldShowAddFolderCell && row == numberOfRows - 1 {
            tableView.deselectRow(at: IndexPath(row: row, section: section), animated: true)
            delegate?.bookmarkFoldersSectionDataSourceDidRequestAddNewFolder(self)
        } else {
            let previousSelected = selectedRow
            selectedRow = row
            
            let indexesToReload = [IndexPath(row: row, section: section), IndexPath(row: previousSelected, section: section)]
            tableView.reloadRows(at: indexesToReload, with: .none)
        }
    }
    
    func selected() -> BookmarkFolder? {
        return folder(at: selectedRow)?.folder
    }
    
    func refreshFolders(_ tableView: UITableView, section: Int, andSelectFolderWithObjectID objectID: NSManagedObjectID) {
        
        guard let folder = bookmarksManager.topLevelBookmarksFolder else {
            return
        }
        PresentableFolders = visibleFolders(for: folder, depthOfFolder: 0)
        let newIndex = PresentableFolders.firstIndex {
            $0.folder.objectID == objectID
        }
        if let index = newIndex {
            selectedRow = index
        }
        
        tableView.reloadData()
    }
}

private extension BookmarkFoldersSectionDataSource {
    
    func folder(at index: Int) -> PresentableFolder? {
        if PresentableFolders.count <= index {
            return nil
        }
        return PresentableFolders[index]
    }
    
    func visibleFolders(for folder: BookmarkFolder, depthOfFolder: Int) -> [PresentableFolder] {
        let array = folder.children?.array as? [BookmarkItem] ?? []
        let folders: [BookmarkFolder] = array.compactMap {
            // If a folder has subfolders and we edit the location, hide the subfolders in the folder structure (so you can't insert a folder into itself
            if let folder = existingItem as? BookmarkFolder,
               folder.objectID == $0.objectID {
                return nil
            } else {
                return $0 as? BookmarkFolder
            }
        }

        var visibleItems = [PresentableFolder(folder, depthOfFolder)]

        visibleItems.append(contentsOf: folders.map { folder -> [PresentableFolder] in
            return visibleFolders(for: folder, depthOfFolder: depthOfFolder + 1)
        }.flatMap { $0 })

        return visibleItems
    }
}
