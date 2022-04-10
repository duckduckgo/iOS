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
    
    private lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        return blurEffectView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        
        setupBlurBackgroundView()
        setupSaveLoginView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        blurView.frame = self.view.frame
    }
    
    private func setupBlurBackgroundView() {
        view.addSubview(blurView)
    }

    private func setupSaveLoginView() {
        let newUser = SaveLoginViewModel(title: UserText.loginPlusSaveLoginTitleNewUser,
                                           subtitle: UserText.loginPlusSaveLoginMessageNewUser,
                                           confirmButtonLabel: UserText.loginPlusSaveLoginSaveCTA,
                                           cancelButtonLabel: UserText.loginPlusSaveLoginNotNowCTA)
        
        let viewModel = SaveLoginViewModel(title: UserText.loginPlusSaveLoginTitle,
                                           confirmButtonLabel: UserText.loginPlusSaveLoginSaveCTA,
                                           cancelButtonLabel: UserText.loginPlusSaveLoginNotNowCTA)
        
        let userInfo = SaveLoginViewModel(title: UserText.loginPlusSaveLoginTitle,
                                          password: "sdfisdoifjsdiofjiosdfj",
                                           confirmButtonLabel: UserText.loginPlusSaveLoginSaveCTA,
                                           cancelButtonLabel: UserText.loginPlusSaveLoginNotNowCTA)



        let saveLoginView = SaveLoginView(viewModel: userInfo, layoutType: .newUser)
        let controller = UIHostingController(rootView: saveLoginView)
        controller.view.backgroundColor = .clear
        //presentationController?.delegate = self
        installChildViewController(controller)
    }
}
