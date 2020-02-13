//
//  OnboardingAppIconViewController.swift
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

import Foundation

class OnboardingAppIconViewController: OnboardingContentViewController {
    
    @IBOutlet weak var videoContainerView: VideoContainerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var header: String {
        return title ?? ""
    }
    
    override var subtitle: String? {
        return nil
    }
    
    override var continueButtonTitle: String {
        return UserText.onboardingSetAppIcon
    }
    
    override func onContinuePressed(navigationHandler: @escaping () -> Void) {
        navigationHandler()
    }
}
