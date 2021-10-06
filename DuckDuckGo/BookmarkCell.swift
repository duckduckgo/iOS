//
//  BookmarkCell.swift
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

class BookmarkCell: UITableViewCell {

    static let reuseIdentifier = "BookmarkCell"

    //TODO rename
    @IBOutlet weak var linkImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var numberOfChildrenLabel: UILabel!
    @IBOutlet weak var disclosureImage: UIImageView!
    
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
//    var link: Link? {
//        didSet {
//            if let linkTitle = link?.title?.trimWhitespace(), !linkTitle.isEmpty {
//                title.text = linkTitle
//            } else {
//                title.text = link?.url.host?.dropPrefix(prefix: "www.") ?? ""
//            }
//            linkImage.loadFavicon(forDomain: link?.url.host, usingCache: .bookmarks)
//        }
//    }

    var bookmarkItem: BookmarkItem? {
        didSet {
            if let bookmark = bookmarkItem as? Bookmark {
                disclosureImage.isHidden = true
                numberOfChildrenLabel.isHidden = true
                imageWidthConstraint.constant = 24
                imageHeightConstraint.constant = 24
                if let linkTitle = bookmark.title?.trimWhitespace(), !linkTitle.isEmpty {
                    title.text = linkTitle
                } else {
                    title.text = bookmark.url?.host?.dropPrefix(prefix: "www.") ?? ""
                }
                linkImage.loadFavicon(forDomain: bookmark.url?.host, usingCache: .bookmarks)
            } else if let folder = bookmarkItem as? BookmarkFolder {
                //TODO
                imageWidthConstraint.constant = 22
                imageHeightConstraint.constant = 20
                disclosureImage.isHidden = false
                numberOfChildrenLabel.isHidden = false
                title.text = folder.title
                numberOfChildrenLabel.text = folder.children?.count.description
                linkImage.image = #imageLiteral(resourceName: "Folder")
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        showsReorderControl = true
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    }

}
