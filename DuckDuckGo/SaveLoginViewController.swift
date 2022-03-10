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

class SaveLoginViewController: UIViewController {
    let domain: String
    
    //TODO create LoginPlusItem
    internal init(domain: String) {
        self.domain = domain
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
        let viewModel = SaveLoginViewModel(
            website: domain,
            password: "",
            username: "")
        
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
