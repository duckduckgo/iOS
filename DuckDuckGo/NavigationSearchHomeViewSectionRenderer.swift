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
    
    let enablePP = true
    
    struct Constants {
        static let privacyCellMaxWidth: CGFloat = CenteredSearchHomeCell.Constants.searchWidth
        static let itemSpacing: CGFloat = 10
    }
    
    weak var controller: HomeViewController!
    
    func install(into controller: HomeViewController) {
        self.controller = controller

        controller.collectionView.contentInset = UIEdgeInsets.zero

        controller.searchHeaderTransition = 1.0
        controller.disableContentUnderflow()
        controller.chromeDelegate?.setNavigationBarHidden(false)
        controller.collectionView.isScrollEnabled = false
        controller.settingsButton.isHidden = true
    }
    
    func openedAsNewTab() {
        controller.chromeDelegate?.omniBar.becomeFirstResponder()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return enablePP ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        if enablePP && indexPath.row == 0 {
            cell = privacyProtectionCell(for: collectionView, at: indexPath)
        } else {
            cell = navigationSearchCell(for: collectionView, at: indexPath)
        }
        return cell
    }
    
    private func navigationSearchCell(for collectionView: UICollectionView, at index: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "navigationSearch", for: index)
            as? NavigationSearchHomeCell else {
                fatalError("cell is not a NavigationSearchHomeCell")
        }
        
        var constant: CGFloat
        if collectionView.traitCollection.containsTraits(in: .init(verticalSizeClass: .compact)) {
            constant = -35
        } else {
            constant = 0
        }
        
        if enablePP {
            constant -= (65 + Constants.itemSpacing) / 2
        }
        
        cell.verticalConstraint.constant = constant
        
        return cell
    }
    
    private func privacyProtectionCell(for collectionView: UICollectionView, at index: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PrivacyHomeCell", for: index) as? PrivacyProtectionHomeCell else {
            fatalError("cell is not a PrivacyProtectionCell")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = collectionView.frame.size
        if enablePP {
            size.width = min(collectionView.frame.width - (HomeViewSectionRenderers.Constants.sideInsets * 2), Constants.privacyCellMaxWidth)
            if indexPath.row == 0 {
                size.height = 65
            } else {
                size.height -= 65
            }
        }
        
        return size
    }
  
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        controller.chromeDelegate?.omniBar.resignFirstResponder()
    }
    
    func launchNewSearch() {
        controller.chromeDelegate?.omniBar.becomeFirstResponder()
    }
    
}
