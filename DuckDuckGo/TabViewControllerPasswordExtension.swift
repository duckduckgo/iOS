//
//  TabViewControllerPasswordExtension.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 22/01/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

extension TabViewController: PasswordsViewControllerDelegate {
    
    func use(username: String, andPassword password: String) {
        webView.evaluateJavaScript("ddgPasswords.populate(\"\(username)\", \"\(password)\")") { (result, error) in
            print("***", #function, result, error)
        }
    }
    
}
