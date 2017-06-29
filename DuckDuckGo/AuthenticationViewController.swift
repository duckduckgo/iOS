//
//  AuthenticationViewController.swift
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

class AuthenticationViewController: UIViewController {

    @IBOutlet weak var lockedText: UILabel!

    private let authenticator = Authenticator()
    
    static func loadFromStoryboard() -> AuthenticationViewController {
        let storyboard = UIStoryboard.init(name: "Authentication", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! AuthenticationViewController
        return controller
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if authenticator.canAuthenticate() {
            authenticate()
        } else {
            onCouldNotAuthenticate()
        }
    }
    
    private func authenticate() {
        hideLockedText()
        authenticator.authenticate() { (success, evaluateError) in
            if (success) {
                self.onAuthenticationSucceeded()
            } else {
                self.onAuthenticationFailed()
            }
        }
    }
    
    @IBAction func onTap(_ sender: Any) {
        authenticate()
    }
    
    private func onCouldNotAuthenticate() {
        dismiss(animated: true, completion: nil)
    }
    
    private func onAuthenticationSucceeded() {
        dismiss(animated: true, completion: nil)
    }
    
    private func onAuthenticationFailed() {
        showLockedText()
    }
    
    private func hideLockedText() {
        lockedText.isHidden = true
    }
    
    private func showLockedText() {
        lockedText.isHidden = false
    }
}

