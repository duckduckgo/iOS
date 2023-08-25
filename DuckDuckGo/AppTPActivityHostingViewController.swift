//
//  AppTPActivityHostingViewController.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

import SwiftUI
import Persistence
import Core

#if APP_TRACKING_PROTECTION

class AppTPActivityHostingViewController: UIHostingController<AppTPActivityView> {
    init(appTrackingProtectionDatabase: CoreDataDatabase, setNavColor: ((Bool) -> Void)? = nil) {
        let feedbackModel = AppTrackingProtectionFeedbackModel(appTrackingProtectionDatabase: appTrackingProtectionDatabase)
        let viewModel = AppTrackingProtectionListViewModel(appTrackingProtectionDatabase: appTrackingProtectionDatabase)
        
        let root = AppTPActivityView(viewModel: viewModel, feedbackModel: feedbackModel, setNavColor: setNavColor)
        
        super.init(rootView: root)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "AppTPViewBackgroundColor")
    }
}

#endif
