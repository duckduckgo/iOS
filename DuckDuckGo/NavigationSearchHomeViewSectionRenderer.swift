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
    
    struct Constants {
        static let privacyCellMaxWidth: CGFloat = CenteredSearchHomeCell.Constants.searchWidth
        static let itemSpacing: CGFloat = 10
    }
    
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
    }
    
    func openedAsNewTab() {
        if KeyboardSettings().onNewTab {
            launchNewSearch()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fixed ? 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "navigationSearch", for: indexPath)
            as? NavigationSearchHomeCell else {
                fatalError("cell is not a NavigationSearchHomeCell")
        }
        
        var constant: CGFloat
        if collectionView.traitCollection.containsTraits(in: .init(verticalSizeClass: .compact)) {
            constant = 0
        } else {
            constant = -34
        }
        
        cell.verticalConstraint.constant = constant
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
  
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        controller?.chromeDelegate?.omniBar.resignFirstResponder()
    }
    
    func launchNewSearch() {
        controller?.chromeDelegate?.omniBar.becomeFirstResponder()
    }
    
}
