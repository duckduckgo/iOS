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

    weak var findInPage: FindInPage?

    func update(with findInPage: FindInPage?) {
        self.findInPage = findInPage
        isHidden = findInPage == nil
        inputText?.text = findInPage?.searchTerm
        counterLabel.isHidden = findInPage?.total ?? 0 == 0

        let current = findInPage?.current ?? 0
        let total = findInPage?.total ?? 0
        counterLabel.text = "\(current) of \(total)"
    }

    override func becomeFirstResponder() -> Bool {
        return inputText.becomeFirstResponder()
    }

    @IBAction func done() {
        isHidden = true
        findInPage?.done()
        inputText.resignFirstResponder()        
    }

    @IBAction func next() {
        findInPage?.next()
    }

    @IBAction func previous() {
        findInPage?.previous()
    }

    @IBAction func textChanged() {
        guard let text = inputText.text else {
            return
        }
        findInPage?.search(forText: text)
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
