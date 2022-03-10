//
//  SaveLoginViewController.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import SwiftUI

class LoginPlusItem {
    enum LoginItemState {
        case new
        case update
    }
    
    private(set) var username: String?
    private(set) var password: String?
    private(set) var domain: String
    private(set) var state: LoginItemState
    
    internal init(username: String? = nil, password: String? = nil, domain: String) {
        self.username = username
        self.password = password
        self.domain = domain
        state = .new
    }
    
    internal init(loginItem: LoginPlusItem) {
        self.username = loginItem.username
        self.password = loginItem.password
        self.domain = loginItem.domain
        state = .update
    }
}

class SaveLoginViewController: UIViewController {
    private let loginItem: LoginPlusItem

    internal init(loginItem: LoginPlusItem) {
        self.loginItem = loginItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSaveLoginView()

    }
    
    private func setupSaveLoginView() {
        let loginState: SaveLoginViewModel.LoginViewState
        
        if loginItem.state == .new && loginItem.username != nil {
            loginState = .saveUsernameAndPassword
        } else if loginItem.username == nil {
            loginState = .saveUsername
        } else {
            loginState = .update
        }
        
        let viewModel = SaveLoginViewModel(
            website: loginItem.domain,
            password: loginItem.password ?? "",
            username: loginItem.username ?? "",
            state: loginState)
        
        viewModel.delegate = self
        
        let saveLoginView = SaveLoginView(loginViewModel: viewModel)
        let controller = UIHostingController(rootView: saveLoginView)
        controller.view.backgroundColor = .clear
        presentationController?.delegate = self
        installChildViewController(controller)
    }
    
    deinit {
        print("bye")
    }
}

extension SaveLoginViewController: UISheetPresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("dismiss")
    }
}

extension SaveLoginViewController: SaveLoginViewModelDelegate {
    func saveLoginModelDidSave(_ model: SaveLoginViewModel) {
        dismiss(animated: true, completion: nil)
    }
    
    func saveLoginModelDidCancel(_ model: SaveLoginViewModel) {
        dismiss(animated: true, completion: nil)
    }
}
