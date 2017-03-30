//
//  EditBookmarkAlert.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 20/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class EditBookmarkAlert {
    
    typealias SaveCompletion = (Link) -> Swift.Void
    typealias CancelCompletion = () -> Swift.Void
    
    static func buildAlert(title: String,
                           bookmark: Link,
                           saveCompletion: @escaping SaveCompletion,
                           cancelCompletion: @escaping CancelCompletion) -> UIAlertController {
        
        let editBox = UIAlertController(title: title, message: "", preferredStyle: .alert)
        editBox.addTextField { (textField) in textField.text = bookmark.title }
        editBox.addTextField { (textField) in textField.text = bookmark.url.absoluteString }
        editBox.addAction(saveAction(editBox: editBox, originalBookmark: bookmark, completion: saveCompletion))
        editBox.addAction(cancelAction(completion: cancelCompletion))
        return editBox
    }
    
    private static func saveAction(editBox: UIAlertController, originalBookmark bookmark: Link, completion: @escaping SaveCompletion) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionSave, style: .default) { (action) in
            if let title = editBox.textFields?[0].text,
                let urlString = editBox.textFields?[1].text,
                let url = URL(string: urlString) {
                let newBookmark = Link(title: title, url: url, favicon: bookmark.favicon)
                completion(newBookmark)
            }
        }
    }
    
    private static func cancelAction(completion: @escaping CancelCompletion) -> UIAlertAction {
        return UIAlertAction(title: UserText.actionCancel, style: .cancel) { (action) in
            completion()
        }
    }
}
