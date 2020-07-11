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

    @IBOutlet weak var linkImage: UIImageView!
    @IBOutlet weak var title: UILabel!

    var link: Link? {
        didSet {
            if let linkTitle = link?.title?.trimWhitespace(), !linkTitle.isEmpty {
                title.text = linkTitle
            } else {
                title.text = link?.url.host?.dropPrefix(prefix: "www.") ?? ""
            }
            Favicons.loadFavicon(forDomain: link?.url.host, intoImageView: linkImage, usingCache: .bookmarks)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        showsReorderControl = true
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        linkImage.isHidden = editing
        super.setEditing(editing, animated: animated)
    }

}
