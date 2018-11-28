//
//  CenteredSearchHomeViewSectionRenderer.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 26/11/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit

class CenteredSearchHomeViewSectionRenderer: HomeViewSectionRenderer {
    
    private weak var controller: HomeViewController!
    
    private var hidden = false
    private var indexPath: IndexPath!
    
    func install(into controller: HomeViewController) {
        self.controller = controller
        
        controller.chromeDelegate?.omniBar.useCancellableState()
        
        if TabsModel.get()?.count ?? 0 > 0 {
            hidden = true
            controller.chromeDelegate?.omniBar.becomeFirstResponder()
        }

        controller.chromeDelegate?.setNavigationBarHidden(!hidden)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        indexPath = IndexPath(row: 0, section: section)
        return hidden ? 0 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "centeredSearch", for: indexPath) as? CenteredSearchHomeCell else {
            fatalError("cell is not CenteredSearchCell")
        }
        cell.tapped = self.tapped
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath)
        -> CGSize {
            let height = UIScreen.main.bounds.height * 1 / 2
            let width = collectionView.frame.width - (HomeViewSectionRenderers.Constants.sideInsets * 2)
            return CGSize(width: width, height: height)
    }
    
    func tapped(view: CenteredSearchHomeCell) {
        hidden = true
        
        self.controller.chromeDelegate?.setNavigationBarHidden(false)
        self.controller.chromeDelegate?.omniBar.alpha = 0.0
        self.controller.chromeDelegate?.omniBar.becomeFirstResponder()
        controller.collectionView.performBatchUpdates({
            self.controller.collectionView.deleteItems(at: [indexPath])
        }, completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.controller.chromeDelegate?.omniBar.alpha = 1.0
            }
        })
        
    }
    
    func omniBarCancelPressed() {
        hidden = false
        
        controller.collectionView.performBatchUpdates({
            self.controller.chromeDelegate?.setNavigationBarHidden(true)
            self.controller.collectionView.insertItems(at: [indexPath])
        })
    }
    
}
