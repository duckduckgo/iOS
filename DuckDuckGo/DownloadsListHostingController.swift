//
//  DownloadsListHostingController.swift
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

import SwiftUI

class DownloadsListHostingController: UIHostingController<DownloadsList> {
    required init?(coder aDecoder: NSCoder) {

        let dataSource = DownloadsListDataSource()
        let viewModel = DownloadsListViewModel(dataSource: dataSource)
        
        super.init(coder: aDecoder, rootView: DownloadsList(viewModel: viewModel))

        setupTableViewAppearance()
        
        viewModel.requestActivityViewHandler = { [weak self] url in
            self?.presentActivityView(for: url)
        }
    }
    
    private func setupTableViewAppearance() {
        // Required due to lack of SwiftUI API for changing the background color of List
        let appearance = UITableView.appearance(whenContainedInInstancesOf: [DownloadsListHostingController.self])
        appearance.backgroundColor = UIColor(named: "DownloadsListBackgroundColor")
    }
    
    private func presentActivityView(for url: URL) {
        // Required due to lack of SwuftUI support for detents
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityViewController.overrideUserInterfaceStyle()
        present(activityViewController, animated: true, completion: nil)
    }
}
