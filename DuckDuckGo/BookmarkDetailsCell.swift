//
//  BookmarkDetailsCell.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

protocol BookmarkDetailsCellDelegate: AnyObject {
    func bookmarkDetailsCellDelegate(_ cell: BookmarkDetailsCell, textFieldDidChangeWithTitleText titleText: String?, urlText: String?)
    func bookmarkDetailsCellDelegateTextFieldDidReturn(cell: BookmarkDetailsCell)
}

class BookmarkDetailsCell: UITableViewCell {

    static let reuseIdentifier = "BookmarkDetailsCell"
    
    weak var delegate: BookmarkDetailsCellDelegate?
    
    var title: String? {
        get {
            titleTextField.text
        }
        set {
            titleTextField.text = newValue
        }
    }
    
    var urlString: String? {
        get {
            urlTextField.text
        }
        set {
            urlTextField.text = newValue
        }
    }

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var faviconImageView: UIImageView!
    
    func setUp() {
        selectionStyle = .none
        
        titleTextField.becomeFirstResponder()
        
        titleTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        urlTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        titleTextField.removeTarget(self, action: #selector(textFieldDidReturn), for: .editingDidEndOnExit)
        urlTextField.removeTarget(self, action: #selector(textFieldDidReturn), for: .editingDidEndOnExit)
        
        titleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        urlTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        titleTextField.addTarget(self, action: #selector(textFieldDidReturn), for: .editingDidEndOnExit)
        urlTextField.addTarget(self, action: #selector(textFieldDidReturn), for: .editingDidEndOnExit)
    }
    
    func setUrlString(_ urlString: String?) {
        let url = URL(string: urlString ?? "")
        faviconImageView.loadFavicon(forDomain: url?.host, usingCache: .fireproof)
        self.urlString = urlString
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        delegate?.bookmarkDetailsCellDelegate(self, textFieldDidChangeWithTitleText: titleTextField.text, urlText: urlTextField.text)
    }
    
    @objc func textFieldDidReturn() {
        delegate?.bookmarkDetailsCellDelegateTextFieldDidReturn(cell: self)
    }
}
