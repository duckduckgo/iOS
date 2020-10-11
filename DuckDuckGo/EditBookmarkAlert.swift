//
//  EditBookmarkAlert.swift
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

class EditBookmarkAlert {

    typealias SaveCompletion = (Link) -> Void
    typealias CancelCompletion = () -> Void

    static func buildAlert(title: String,
                           bookmark: Link?,
                           saveCompletion: @escaping SaveCompletion,
                           cancelCompletion: CancelCompletion? = nil) -> UIAlertController {

        return ValidatingAlert(title: title, link: bookmark, saveCompletion: saveCompletion, cancelCompletion: cancelCompletion)
    }
}

private class ValidatingAlert: UIAlertController {
    
    var titleField: UITextField!
    var urlField: UITextField!
    var saveAction: UIAlertAction!
    
    convenience init(title: String,
                     link: Link?,
                     saveCompletion: @escaping EditBookmarkAlert.SaveCompletion,
                     cancelCompletion: EditBookmarkAlert.CancelCompletion?) {
        
        self.init(title: title, message: nil, preferredStyle: .alert)
        overrideUserInterfaceStyle()
        
        let keyboardAppearance = ThemeManager.shared.currentTheme.keyboardAppearance
        addTextField { textField in
            textField.accessibilityLabel = "Bookmark Title" // UserText.bookmarkTitleAccessibility
            textField.text = link?.title
            textField.placeholder = UserText.bookmarkTitlePlaceholder
            textField.keyboardAppearance = keyboardAppearance
            self.titleField = textField
        }
        addTextField { textField in
            textField.accessibilityLabel = "Bookmark Address"
            textField.text = link?.url.absoluteString
            textField.placeholder = UserText.bookmarkAddressPlaceholder
            textField.keyboardAppearance = keyboardAppearance
            textField.keyboardType = .URL
            self.urlField = textField
        }
        
        titleField.addTarget(self, action: #selector(onTextChanged), for: .allEditingEvents)
        urlField.addTarget(self, action: #selector(onTextChanged), for: .allEditingEvents)
        
        saveAction = createSaveAction(with: saveCompletion)
        addAction(title: UserText.actionCancel, style: .cancel) {
            cancelCompletion?()
        }
        updateSave()
    }
    
    private func createSaveAction(with completion: @escaping EditBookmarkAlert.SaveCompletion) -> UIAlertAction {
        return addAction(title: "Save", style: .default) {
            guard let title = self.titleField.text else { return }
            guard var urlString = self.urlField.text else { return }
            
            if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") && !urlString.isBookmarklet() {
                urlString = "http://\(urlString)"
            }

            let optionalURL: URL?
            if urlString.isBookmarklet() {
                optionalURL = urlString.toEncodedBookmarklet()
                guard URL.isValidBookmarklet(url: optionalURL) else { return }
            } else {
                optionalURL = urlString.punycodedUrl
            }

            guard let url = optionalURL else { return }
            
            completion(Link(title: title, url: url))
        }
    }
    
    @objc func onTextChanged() {
        updateSave()
    }
    
    func updateSave() {
        saveAction.isEnabled = false
        guard let title = titleField.text?.trimWhitespace(), !title.isEmpty else { return }
        guard let url = urlField.text?.trimWhitespace(), !url.isEmpty else { return }
        saveAction.isEnabled = true
    }
    
}
