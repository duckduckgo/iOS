//
//  FindInPageView.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 15/02/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import UIKit

class FindInPageView: UIView {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var searchLoupe: UIImageView!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var searchBackground: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var inputText: UITextField!

    func update(with findInPage: FindInPage?) {
        guard let findInPage = findInPage else {
            isHidden = true
            return
        }

        isHidden = false
    }

    override func becomeFirstResponder() -> Bool {
        return inputText.becomeFirstResponder()
    }

}

extension FindInPageView: Themable {
    func decorate(with theme: Theme) {
        backgroundColor = theme.barBackgroundColor
        tintColor = theme.barTintColor
        nextButton.tintColor = theme.barTintColor
        previousButton.tintColor = theme.barTintColor
        counterLabel.textColor = theme.barTintColor
        searchBackground.backgroundColor = theme.searchBarBackgroundColor
        inputText.textColor = theme.searchBarTextColor
        inputText.tintColor = theme.searchBarTextColor
        inputText.keyboardAppearance = theme.keyboardAppearance
        searchLoupe.tintColor = theme.barTintColor
        doneButton.setTitleColor(theme.barTintColor, for: .normal)
    }
}
