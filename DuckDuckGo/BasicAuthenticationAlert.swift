//
//  BasicAuthenticationAlert.swift
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
import Core

class BasicAuthenticationAlert: UIAlertController {
    
    typealias LogInCompletion = (_ userName: String, _ password: String) -> Void
    typealias CancelCompletion = () -> Void

    private var didCallCompletion = false
    private var cancelCompletion: CancelCompletion!
    var usernameField: UITextField!
    var passwordField: UITextField!
    var logInAction: UIAlertAction!
    
    convenience init(host: String,
                     isEncrypted: Bool,
                     logInCompletion: @escaping LogInCompletion,
                     cancelCompletion: @escaping CancelCompletion = {}) {
        let message: String
        if isEncrypted {
            message = UserText.authAlertEncryptedConnectionMessage.format(arguments: host)
        } else {
            message = UserText.authAlertPlainConnectionMessage.format(arguments: host)
        }

        self.init(title: UserText.authAlertTitle, message: message, preferredStyle: .alert)
        overrideUserInterfaceStyle()

        self.cancelCompletion = cancelCompletion

        let keyboardAppearance = ThemeManager.shared.currentTheme.keyboardAppearance
        addTextField { textField in
            textField.accessibilityLabel = "Username"
            textField.placeholder = UserText.authAlertUsernamePlaceholder
            textField.keyboardAppearance = keyboardAppearance
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
            
            self.usernameField = textField
        }
        addTextField { textField in
            textField.accessibilityLabel = "Password"
            textField.placeholder = UserText.authAlertPasswordPlaceholder
            textField.keyboardAppearance = keyboardAppearance
            textField.textContentType = .password
            textField.isSecureTextEntry = true
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
            
            self.passwordField = textField
        }
        
        usernameField.addTarget(self, action: #selector(onTextChanged), for: .allEditingEvents)
        passwordField.addTarget(self, action: #selector(onTextChanged), for: .allEditingEvents)
        
        logInAction = createLogInAction(with: logInCompletion)
        addAction(title: UserText.actionCancel, style: .cancel) { [weak self] in
            self?.didCallCompletion = true
            cancelCompletion()
        }
        updateButtons()
    }

    deinit {
        if !didCallCompletion {
            cancelCompletion()
        }
    }

    private func createLogInAction(with completion: @escaping LogInCompletion) -> UIAlertAction {
        return addAction(title: UserText.authAlertLogInButtonTitle, style: .default) { [weak self] in
            guard let self else { return }
            guard let login = self.usernameField.text else { return }
            guard let password = self.passwordField.text else { return }

            self.didCallCompletion = true
            completion(login, password)
        }
    }
    
    @objc func onTextChanged() {
        updateButtons()
    }
    
    func updateButtons() {
        logInAction.isEnabled = !(usernameField.text?.isEmpty ?? true) && !(passwordField.text?.isEmpty ?? true)
    }
    
}
