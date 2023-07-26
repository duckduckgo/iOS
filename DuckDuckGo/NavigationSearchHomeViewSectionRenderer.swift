//
//  NavigationSearchHomeViewSectionRenderer.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

class NavigationSearchHomeViewSectionRenderer: HomeViewSectionRenderer {
    
    private let fixed: Bool
    
    init(fixed: Bool) {
        self.fixed = fixed
    }
    
    weak var controller: HomeViewController?
    
    func install(into controller: HomeViewController) {
        self.controller = controller

        controller.collectionView.contentInset = UIEdgeInsets.zero

        controller.searchHeaderTransition = 1.0
        controller.disableContentUnderflow()
        controller.chromeDelegate?.setNavigationBarHidden(false)
        controller.collectionView.isScrollEnabled = !fixed
        controller.settingsButton.isHidden = true
        
        if !fixed {
            controller.hideLogo()
        }
    }
    
    func openedAsNewTab(allowingKeyboard: Bool) {
        if allowingKeyboard && KeyboardSettings().onNewTab {
            launchNewSearch()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "space", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }

    func launchNewSearch() {
        controller?.chromeDelegate?.omniBar.becomeFirstResponder()
    }
    
}
