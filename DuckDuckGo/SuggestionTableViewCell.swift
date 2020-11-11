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

class SuggestionTableViewCell: UITableViewCell {
    
    struct Constants {
        static let cellHeight: CGFloat = 46.0
    }

    static let reuseIdentifier = "SuggestionTableViewCell"

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var plusButton: UIButton!

    func updateFor(query: String, suggestion: Suggestion) {
        let text = suggestion.suggestion
        
        switch suggestion.source {
        case .local:
            typeImage.image = UIImage(named: "BookmarkSuggestion")
        case .remote:
            if URL.isWebUrl(text: text) {
                typeImage.image = UIImage(named: "SuggestGlobe")
            } else {
                typeImage.image = UIImage(named: "SuggestLoupe")
            }
        }
        
        styleText(query: query, text: suggestion.suggestion)
    }

    private func styleText(query: String, text: String) {

        let attributes = [
            NSAttributedString.Key.font: UIFont.semiBoldAppFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]

        let text = NSMutableAttributedString(string: text)
        text.addAttributes(attributes, range: NSRange(location: 0, length: text.length))
        label.attributedText = text
    }
}
