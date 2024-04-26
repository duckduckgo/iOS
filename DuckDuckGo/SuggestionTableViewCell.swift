//
//  SuggestionTableViewCell.swift
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
import Suggestions

class SuggestionTableViewCell: UITableViewCell {
    
    struct Constants {
        static let defaultCellHeight: CGFloat = 44.0
        static let multipleLineCellHeight: CGFloat = 60.0
    }

    static let reuseIdentifier = "SuggestionTableViewCell"

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var plusButton: UIButton!

    func updateFor(query: String, suggestion: Suggestion, with theme: Theme, isAddressBarAtBottom: Bool) {

        self.plusButton.isHidden = true

        var text: String = ""
        switch suggestion {
        case .phrase(phrase: let phrase):
            text = phrase
            typeImage.image = UIImage(named: "Find-Search-24")
            urlLabel.isHidden = true
            self.accessibilityValue = UserText.voiceoverSuggestionTypeSearch

            self.plusButton.isHidden = false
            self.plusButton.accessibilityLabel = UserText.voiceoverActionAutocomplete
            self.plusButton.tintColor = theme.autocompleteCellPlusButtonColor
            if isAddressBarAtBottom {
                self.plusButton.setImage(UIImage(named: "Arrow-Circle-Down-Left-16"), for: .normal)
            } else {
                self.plusButton.setImage(UIImage(named: "Arrow-Circle-Up-Left-16"), for: .normal)
            }

        case .website(url: let url):
            text = url.absoluteString
            typeImage.image = UIImage(named: "Globe-24")
            urlLabel.isHidden = true
            self.accessibilityValue = UserText.voiceoverSuggestionTypeSearch

        case .bookmark(title: let title, let url, let isFavorite, _):
            text = title
            urlLabel.isHidden = url.isBookmarklet()
            urlLabel.text = url.formattedForSuggestion()
            typeImage.image = isFavorite ? UIImage(named: "Bookmark-Fav-24") : UIImage(named: "Bookmark-24")
            self.accessibilityValue = UserText.voiceoverSuggestionTypeBookmark

        case .historyEntry(title: let title, url: let url, _):
            if url.isDuckDuckGoSearch, let searchQuery = url.searchQuery {
                text = searchQuery
            } else {
                text = title ?? url.absoluteString
            }
            urlLabel.isHidden = false
            urlLabel.text = url.formattedForSuggestion()
            typeImage.image = UIImage(named: "History-24")
            self.accessibilityValue = UserText.voiceoverSuggestionTypeBookmark

        case .unknown(value: let value):
            assertionFailure("Unknown suggestion \(value)")
        }

        urlLabel.textColor = theme.tableCellSecondaryTextColor
        styleText(query: query,
                  text: text,
                  regularColor: theme.tableCellTextColor,
                  suggestionColor: theme.autocompleteSuggestionTextColor)
    }

    private func styleText(query: String, text: String, regularColor: UIColor, suggestionColor: UIColor) {

        let regularAttributes = [
            NSAttributedString.Key.font: UIFont.appFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: regularColor
        ]
        
        let boldAttributes = [
            NSAttributedString.Key.font: UIFont.boldAppFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: suggestionColor
        ]

        let newText = NSMutableAttributedString(string: text)
        
        let queryLength = query.length()
        if queryLength < newText.length, text.hasPrefix(query) {
            newText.addAttributes(regularAttributes, range: NSRange(location: 0, length: queryLength))
            newText.addAttributes(boldAttributes, range: NSRange(location: queryLength, length: newText.length - queryLength))
        } else {
            newText.addAttributes(regularAttributes, range: NSRange(location: 0, length: newText.length))
        }
        
        label.attributedText = newText
    }
}

private extension URL {

    func formattedForSuggestion() -> String {
        let string = absoluteString
            .dropping(prefix: "https://")
            .dropping(prefix: "http://")
        return pathComponents.isEmpty ? string : string.dropping(suffix: "/")
    }

}
