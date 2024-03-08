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
        static let cellHeight: CGFloat = 46.0
    }

    static let reuseIdentifier = "SuggestionTableViewCell"

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var plusButton: UIButton!

    func updateFor(query: String, suggestion: Suggestion, with theme: Theme, isAddressBarAtBottom: Bool) {

        var text: String = ""
        switch suggestion {
        case .phrase(phrase: let phrase):
            text = phrase
            typeImage.image = UIImage(named: "Find-Search-20")
            self.accessibilityValue = UserText.voiceoverSuggestionTypeSearch

        case .website(url: let url):
            text = url.absoluteString
            typeImage.image = UIImage(named: "Globe-20")
            self.accessibilityValue = UserText.voiceoverSuggestionTypeSearch

        case .bookmark(title: let title, url: let url, isFavorite: let isFavorite, allowedInTopHits: let allowedInTopHits):
            text = title
            typeImage.image = UIImage(named: "Bookmark-20")
            self.accessibilityValue = UserText.voiceoverSuggestionTypeBookmark

        case .historyEntry(title: let title, url: let url, allowedInTopHits: let allowedInTopHits):
            text = title ?? url.absoluteString
            typeImage.image = UIImage(named: "History-20")
            self.accessibilityValue = UserText.voiceoverSuggestionTypeBookmark

        case .unknown(value: let value):
            // TODO use log if too agressive
            assertionFailure("Unknown suggestion \(value)")
        }

        self.plusButton.accessibilityLabel = UserText.voiceoverActionAutocomplete
        if isAddressBarAtBottom {
            self.plusButton.setImage(UIImage(named: "Arrow-Down-Left-24"), for: .normal)
        } else {
            self.plusButton.setImage(UIImage(named: "Arrow-Top-Left-24"), for: .normal)
        }

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
