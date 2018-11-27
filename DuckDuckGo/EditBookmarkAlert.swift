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
                           cancelCompletion: @escaping CancelCompletion) -> UIAlertController {

        let editBox = UIAlertController(title: title, message: "", preferredStyle: .alert)
        
        let keyboardAppearance = ThemeManager.shared.currentTheme.keyboardAppearance
        editBox.addTextField { (textField) in
            textField.text = bookmark?.title
            textField.placeholder = "Website Title"
            textField.keyboardAppearance = keyboardAppearance
        }
        editBox.addTextField { (textField) in
            textField.text = bookmark?.url.absoluteString
            textField.placeholder = "www.example.com"
            textField.keyboardAppearance = keyboardAppearance
        }
        editBox.addAction(saveAction(editBox: editBox, originalBookmark: bookmark, completion: saveCompletion))
        editBox.addAction(cancelAction(completion: cancelCompletion))
        return editBox
    }

    private static func saveAction(editBox: UIAlertController,
                                   originalBookmark bookmark: Link?,
                                   completion: @escaping SaveCompletion) -> UIAlertAction {
        
        return UIAlertAction(title: UserText.actionSave, style: .default) { (_) in
            
            guard let title = editBox.textFields?[0].text else { return }
            guard var urlString = editBox.textFields?[1].text else { return }
            
            if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
                urlString = "http://\(urlString)"
            }
            
            guard let url = URL(string: urlString) else { return }
            
            completion(Link(title: title, url: url))

        }
    }

    private static func cancelAction(completion: @escaping CancelCompletion) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionCancel, style: .cancel) { (_) in
            completion()
        }
    }
}
