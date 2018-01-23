//
//  PasswordsViewController.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 22/01/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit

protocol PasswordsViewControllerDelegate: class {
    
    func use(username: String, andPassword password: String)
    
}

class PasswordsViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var domainNameLabel: UILabel!
    
    var domainName: String?
    weak var delegate: PasswordsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        domainNameLabel.text = domainName
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        usernameField.becomeFirstResponder()
    }
    
    @IBAction func onUse() {
        
        guard let username = usernameField.text?.trimWhitespace(),
            username != "",
            let password = passwordField.text,
            password != "" else { return }
        
        delegate?.use(username: username, andPassword: password)
        dismiss(animated: true)
    }
    
    @IBAction func onCancel() {
        dismiss(animated: true)
    }
    
    @IBAction func onToggle() {
        passwordField.isSecureTextEntry = !passwordField.isSecureTextEntry
    }
    
}
