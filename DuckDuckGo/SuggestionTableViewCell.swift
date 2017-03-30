//
//  SuggestionTableViewCell.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 09/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16),
            NSForegroundColorAttributeName: UIColor.black
        ]
        
        let count = (query.length() < text.length()) ? query.length() : text.length()
        let text = NSMutableAttributedString(string: text)
        text.addAttributes(attributes, range: NSMakeRange(0, count))
        label.attributedText = text
    }
}
