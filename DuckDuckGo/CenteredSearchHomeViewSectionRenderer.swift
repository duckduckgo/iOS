//
//  CenteredSearchHomeViewSectionRenderer.swift
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
import Core

class CenteredSearchHomeViewSectionRenderer: HomeViewSectionRenderer {
    
    private weak var controller: HomeViewController!
    
    private var hidden = false {
        didSet {
            controller.settingsButton.isHidden = hidden
        }
    }
    private var indexPath: IndexPath!
    
    func install(into controller: HomeViewController) {
        self.controller = controller
        
        controller.chromeDelegate?.omniBar.useCancellableState()
        
        if TabsModel.get()?.count ?? 0 > 0 {
            hidden = true
            controller.chromeDelegate?.omniBar.becomeFirstResponder()
        }

        controller.chromeDelegate?.setNavigationBarHidden(!hidden)
        
        Pixel.fire(pixel: .homeScreenShown)
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
        Pixel.fire(pixel: .homeScreenSearchTapped)
        
        hidden = true
        
        self.controller.chromeDelegate?.setNavigationBarHidden(false)
        self.controller.chromeDelegate?.omniBar.becomeFirstResponder()
        controller.collectionView.performBatchUpdates({
            self.controller.collectionView.deleteItems(at: [indexPath])
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
