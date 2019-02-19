//
//  FindInPageView.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

class FindInPageView: UIView {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var searchLoupe: UIImageView!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var searchBackground: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var inputText: UITextField!

    weak var findInPage: FindInPage?

    override func awakeFromNib() {
        layer.shadowRadius = 1
        layer.shadowOffset = CGSize(width: 0, height: -1.0 / UIScreen.main.scale)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.masksToBounds = false
    }
    
    func update(with findInPage: FindInPage?) {
        self.findInPage = findInPage
        isHidden = findInPage == nil
        inputText?.text = findInPage?.searchTerm
        counterLabel.isHidden = findInPage?.total ?? 0 == 0

        let current = findInPage?.current ?? 0
        let total = findInPage?.total ?? 0
        counterLabel.text = UserText.findInPageCount.format(arguments: current, total)
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

extension FindInPageView: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        next()
        return true
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
