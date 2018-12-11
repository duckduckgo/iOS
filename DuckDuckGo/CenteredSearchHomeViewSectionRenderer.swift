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
    private weak var cell: CenteredSearchHomeCell?

    private var sectionHeight: CGFloat {
        return UIScreen.main.bounds.height * 1 / 2
    }
    private var hidden = false {
        didSet {
            controller.allowContentUnderflow = false
            controller.settingsButton.isHidden = hidden
            controller.searchHeaderTransition = 1.0
        }
    }
    private var indexPath: IndexPath!
    
    func install(into controller: HomeViewController) {
        self.controller = controller
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CenteredSearchHomeViewSectionRenderer.rotated),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        
        if TabsModel.get()?.count ?? 0 > 0 {
            hidden = true
            controller.chromeDelegate?.omniBar.becomeFirstResponder()
        }

        controller.allowContentUnderflow = true

        controller.searchHeaderTransition = 0.0
        cell?.searchHeaderTransition = 0.0

        Pixel.fire(pixel: .homeScreenShown)
    }
    
    @objc func rotated() {
        scrollViewDidScroll(controller.collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        indexPath = IndexPath(row: 0, section: section)
        return hidden ? 0 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "centeredSearch", for: indexPath) as? CenteredSearchHomeCell else {
            fatalError("cell is not a CenteredSearchHomeCell")
        }
        cell.omniBar = controller.chromeDelegate?.omniBar
        cell.tapped = self.tapped
        self.cell = cell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath)
        -> CGSize {
            let height = sectionHeight
            let width = collectionView.frame.width - (HomeViewSectionRenderers.Constants.sideInsets * 2)
            return CGSize(width: width, height: height)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY: CGFloat = 46
        
        let targetHeight = sectionHeight - offsetY
        let y = scrollView.contentOffset.y

        let diff = targetHeight - y

        guard diff < offsetY else {
            controller.searchHeaderTransition = 0.0
            cell?.searchHeaderTransition = 0.0
            return
        }
        guard diff > 0 else {
            controller.searchHeaderTransition = 1.0
            cell?.searchHeaderTransition = 1.0
            return
        }

        let percent = 1 - (diff / offsetY)
        controller.searchHeaderTransition = percent
        cell?.searchHeaderTransition = percent
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
        guard hidden else {
            controller.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            return
        }

        hidden = false
        
        controller.collectionView.performBatchUpdates({
            self.controller.chromeDelegate?.setNavigationBarHidden(true)
            self.controller.collectionView.insertItems(at: [indexPath])
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
