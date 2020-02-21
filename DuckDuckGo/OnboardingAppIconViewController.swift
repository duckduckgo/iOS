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

import UIKit

class OnboardingAppIconViewController: OnboardingContentViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let dataSource = AppIconDataSource()
    let worker = AppIconWorker(context: .onboarding)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = dataSource
        collectionView.reloadData()
        
        initSelection()
    }
    
    private func initSelection() {
        let icon = AppIconManager.shared.appIcon
        let index = dataSource.appIcons.firstIndex(of: icon) ?? 0
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
    }
    
    private var selectedIcon: AppIcon {
        guard let selection = collectionView.indexPathsForSelectedItems?.last else {
            return AppIconManager.shared.appIcon
        }
        
        return dataSource.appIcons[selection.row]
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
        
        let currentIcon = AppIconManager.shared.appIcon
        
        if currentIcon != selectedIcon {
            worker.changeAppIcon(selectedIcon) { _ in
                navigationHandler()
            }
        } else {
            navigationHandler()
        }
    }
}
