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

    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var numberOfChildrenLabel: UILabel!
    @IBOutlet weak var disclosureEditView: UIImageView!
    @IBOutlet weak var editSeperatorView: UIView!
    @IBOutlet weak var mainContentStackView: UIStackView!
    @IBOutlet weak var stackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var editSeperatorViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    var bookmarkItem: BookmarkItem? {
        didSet {
            if let bookmark = bookmarkItem as? Bookmark {
                numberOfChildrenLabel.isHidden = true
                imageWidthConstraint.constant = 24
                imageHeightConstraint.constant = 24
                if let linkTitle = bookmark.title?.trimWhitespace(), !linkTitle.isEmpty {
                    title.text = linkTitle
                } else {
                    title.text = bookmark.url?.host?.droppingWwwPrefix() ?? ""
                }
                
                accessoryView = nil
                
                itemImage.loadFavicon(forDomain: bookmark.url?.host, usingCache: .bookmarks)
            } else if let folder = bookmarkItem as? BookmarkFolder {
                imageWidthConstraint.constant = 22
                imageHeightConstraint.constant = 20
                numberOfChildrenLabel.isHidden = false
                title.text = folder.title
                numberOfChildrenLabel.text = folder.children?.count.description
                itemImage.image = #imageLiteral(resourceName: "Folder")
                
                let theme = ThemeManager.shared.currentTheme
                let accesoryImage = UIImageView(image: UIImage(named: "DisclosureIndicator"))
                accesoryImage.frame = CGRect(x: 0, y: 0, width: 8, height: 13)
                accesoryImage.tintColor = theme.tableCellAccessoryColor
                accessoryView = accesoryImage
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        showsReorderControl = true
        disclosureEditView.isHidden = true
        editSeperatorView.isHidden = true
        editSeperatorViewWidthConstraint.constant =  1.0 / UIScreen.main.scale
    }
    
    var currentState: UITableViewCell.StateMask = []
    
    override func willTransition(to state: UITableViewCell.StateMask) {
        super.willTransition(to: state)
        currentState = state
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        // require current state to make sure this doesn't happen when swiping cells
        if editing && currentState.contains(.showingEditControl) {
            numberOfChildrenLabel.isHidden = true
            disclosureEditView.isHidden = false
            editSeperatorView.isHidden = false
            stackViewTrailingConstraint.constant = 32 + editSeperatorViewWidthConstraint.constant
            mainContentStackView.setCustomSpacing(8, after: itemImage)
        } else {
            disclosureEditView.isHidden = true
            editSeperatorView.isHidden = true
            stackViewTrailingConstraint.constant = 0
            if bookmarkItem as? BookmarkFolder != nil {
                numberOfChildrenLabel.isHidden = false
            }
            mainContentStackView.setCustomSpacing(16, after: itemImage)
        }
    }

}
