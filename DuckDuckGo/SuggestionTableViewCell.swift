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
    
    static let reuseIdentifier = "SuggestionTableViewCell"
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var plusButton: UIButton!
    
    func updateFor(query: String, suggestion: Suggestion) {
        let text = suggestion.suggestion
        if URL.isWebUrl(text: text) {
            typeImage.image = #imageLiteral(resourceName: "GlobeSmall")
            plusButton.isHidden = true
        } else {
            typeImage.image = #imageLiteral(resourceName: "SearchLoupeMini")
            plusButton.isHidden = false
        }
        styleText(query: query, text: suggestion.suggestion)
    }
    
    private func styleText(query: String, text: String) {

        let attributes = [
            NSAttributedStringKey.font: UIFont.semiBoldAppFont(ofSize: 16),
            NSAttributedStringKey.foregroundColor: UIColor.white
        ]
        
        let count = (query.length() < text.length()) ? query.length() : text.length()
        let text = NSMutableAttributedString(string: text)
        text.addAttributes(attributes, range: NSMakeRange(0, count))
        label.attributedText = text
    }
}
