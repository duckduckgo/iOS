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
import DesignResourcesKit

class DownloadsListHostingController: UIHostingController<DownloadsList> {
    required init?(coder aDecoder: NSCoder) {

        let dataSource = DownloadsListDataSource()
        let viewModel = DownloadsListViewModel(dataSource: dataSource)
        
        super.init(coder: aDecoder, rootView: DownloadsList(viewModel: viewModel))

        setUpAppearances()
        
        viewModel.requestActivityViewHandler = { [weak self] url, rectangle in
            self?.presentActivityView(for: url, from: rectangle)
        }
    }
    
    private func setUpAppearances() {
        // Required due to lack of SwiftUI APIs for changing the background color of List and nav bars
        let appearance = UITableView.appearance(whenContainedInInstancesOf: [DownloadsListHostingController.self])
        appearance.backgroundColor = UIColor(designSystemColor: .background)
        
        let navAppearance = UINavigationBar.appearance(whenContainedInInstancesOf: [DownloadsListHostingController.self])
        navAppearance.backgroundColor = UIColor(designSystemColor: .background)
        navAppearance.barTintColor = UIColor(designSystemColor: .background)
        navAppearance.shadowImage = UIImage()
    }
    
    private func presentActivityView(for url: URL, from rect: CGRect) {
        // Required due to lack of SwuftUI support for detents
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityViewController.overrideUserInterfaceStyle()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityViewController.popoverPresentationController?.sourceView = UIApplication.shared.windows.first
            activityViewController.popoverPresentationController?.permittedArrowDirections = .right
            activityViewController.popoverPresentationController?.sourceRect = rect
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
}
