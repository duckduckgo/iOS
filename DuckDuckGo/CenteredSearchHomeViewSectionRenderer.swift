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

    private var indexPath: IndexPath?
    
    func install(into controller: HomeViewController) {
        self.controller = controller
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CenteredSearchHomeViewSectionRenderer.rotated),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        
        controller.allowContentUnderflow()

        controller.searchHeaderTransition = 0.0
        cell?.searchHeaderTransition = 0.0

        Pixel.fire(pixel: .homeScreenShown)
    }
    
    @objc func rotated() {
        scrollViewDidScroll(controller.collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if indexPath == nil {
            indexPath = IndexPath(row: 0, section: section)
            if TabsModel.get()?.count ?? 0 > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.activateSearch()
                }
            }
        }
        
        return 1
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
            let height = (collectionView.frame.height / 2) - 50
            let width = collectionView.frame.width - (HomeViewSectionRenderers.Constants.sideInsets * 2)
            return CGSize(width: width, height: height)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY: CGFloat = 96
        
        let targetHeight = (scrollView.frame.height / 2) - offsetY
        let y = scrollView.contentOffset.y

        let diff = targetHeight - y

        guard diff < offsetY else {
            // centered search bar is visible
            controller.searchHeaderTransition = 0.0
            cell?.searchHeaderTransition = 0.0
            return
        }
        
        guard diff > 0 else {
            // centered search bar is not visible
            controller.searchHeaderTransition = 1.0
            cell?.searchHeaderTransition = 1.0
            return
        }

        // centered search bar is transitioning
        let percent = 1 - (diff / offsetY)
        controller.searchHeaderTransition = percent
        cell?.searchHeaderTransition = percent
    }

    func tapped(view: CenteredSearchHomeCell) {
        Pixel.fire(pixel: .homeScreenSearchTapped)
        activateSearch()
        controller.chromeDelegate?.omniBar.becomeFirstResponder()
    }
    
    private func activateSearch() {
        guard let thisIndexPath = indexPath else { return }
        let targetIndexPath = IndexPath(row: 0, section: thisIndexPath.section + 1)
        controller.collectionView.scrollToItem(at: targetIndexPath, at: .top, animated: true)
        controller.chromeDelegate?.omniBar.becomeFirstResponder()
    }
    
    func omniBarCancelPressed() {
        guard let indexPath = indexPath else { return }
        controller.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
    
    func launchNewSearch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.activateSearch()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
