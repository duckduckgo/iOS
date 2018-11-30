//
//  NavigationSearchHomeViewSectionRenderer.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 26/11/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit

class NavigationSearchHomeViewSectionRenderer: HomeViewSectionRenderer {
    
    weak var controller: HomeViewController!
    
    func install(into controller: HomeViewController) {
        self.controller = controller
        controller.chromeDelegate?.setNavigationBarHidden(false)
        controller.collectionView.isScrollEnabled = false
        controller.settingsButton.isHidden = true
    }
    
    func openedAsNewTab() {
        controller.chromeDelegate?.omniBar.becomeFirstResponder()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "navigationSearch", for: indexPath)
            as? NavigationSearchHomeCell else {
                fatalError("cell is not a NavigationSearchHomeCell")
        }
        cell.frame = collectionView.bounds
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
        controller.chromeDelegate?.omniBar.resignFirstResponder()
    }
    
}
