//
//  EditBookmarkFolderCell.swift
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

class BookmarkFolderCell: UITableViewCell {

    static let reuseIdentifier = "BookmarkFolderCell"

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var leadingPaddingConstraint: NSLayoutConstraint!

    var folder: BookmarkFolder? {
        didSet {
            guard let folder = folder else { return }
            title.text = folder.title
        }
    }
    
    var titleString: String? {
        get {
            return title.text
        }
        set {
            title.text = newValue
        }
    }
    
    var depth: Int = 0 {
        didSet {
            let paddingDepth = min(depth, 10)
            separatorInset.left = CGFloat(paddingDepth + 1) * 16.0
            leadingPaddingConstraint.constant = CGFloat(paddingDepth) * 16.0
        }
    }
    
    override var isSelected: Bool {
        didSet {
            accessoryType = isSelected ? .checkmark : .none
        }
    }
    
}

