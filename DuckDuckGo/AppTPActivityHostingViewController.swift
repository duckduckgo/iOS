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
import Core

class AppTPActivityHostingViewController: UIHostingController<AppTPActivityView> {
    init(appTrackingProtectionDatabase: TemporaryAppTrackingProtectionDatabase) {
        let viewModel = AppTrackingProtectionListModel(appTrackingProtectionDatabase: appTrackingProtectionDatabase)
        
        let root = AppTPActivityView(viewModel: viewModel)
        
        super.init(rootView: root)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTableViewAppearance() {
        // Required due to lack of SwiftUI API for changing the background color of List
        let appearance = UITableView.appearance(whenContainedInInstancesOf: [DownloadsListHostingController.self])
        appearance.backgroundColor = UIColor(named: "DownloadsListBackgroundColor")
    }
}
