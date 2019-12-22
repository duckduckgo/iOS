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
    
    struct Constants {
        
        static let searchCenterOffset: CGFloat = 50
        static let scrollUpAdjustment: CGFloat = 46
        
        static let fixedSearchCenterOffset: CGFloat = 40
        
    }
    
    private var searchCenterOffset: CGFloat {
        return fixed && isPortrait ? Constants.fixedSearchCenterOffset : Constants.searchCenterOffset
    }
    
    private var overflowOffset: CGFloat = 0
    
    private weak var controller: HomeViewController?
    private weak var cell: CenteredSearchHomeCell?

    private var heightRatio: CGFloat {
        return fixed ? 1.875 : 2.0
    }
    
    private var indexPath: IndexPath?
    
    private let fixed: Bool
    
    var centeredSearch: UIView? {
        return cell?.searchBackground
    }
    
    init(fixed: Bool) {
        self.fixed = fixed
    }
    
    func install(into controller: HomeViewController) {
        self.controller = controller
        
        controller.collectionView.isScrollEnabled = !fixed

        overflowOffset = controller.enableContentUnderflow()
        controller.searchHeaderTransition = 0.0
        cell?.searchHeaderTransition = 0.0
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        indexPath = IndexPath(row: 0, section: section)
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "centeredSearch", for: indexPath) as? CenteredSearchHomeCell else {
            fatalError("cell is not a CenteredSearchHomeCell")
        }
        cell.tapped = self.tapped
        cell.targetSearchHeight = controller?.chromeDelegate?.omniBar.editingBackground.frame.height ?? 0
        cell.targetSearchRadius = controller?.chromeDelegate?.omniBar.editingBackground.layer.cornerRadius ?? 0
        self.cell = cell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath)
        -> CGSize {
            let height = (collectionView.frame.height / heightRatio) - searchCenterOffset
            let width: CGFloat = collectionView.frame.width - (HomeViewSectionRenderers.Constants.sideInsets * 2)
            return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize? {
        
        return CGSize(width: 1, height: controller?.chromeDelegate?.omniBar.textFieldBottomSpacing ?? 0)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY: CGFloat = Constants.scrollUpAdjustment

        let targetHeight = (scrollView.frame.height / heightRatio) - searchCenterOffset
        let y = scrollView.contentOffset.y

        let diff = targetHeight - y - offsetY

        guard diff < offsetY else {
            // search bar is in the center
            controller?.searchHeaderTransition = 0.0
            cell?.searchHeaderTransition = 0.0
            return
        }
        
        guard diff > 0 else {
            // search bar is in the navigation bar
            controller?.searchHeaderTransition = 1.0
            cell?.searchHeaderTransition = 1.0
            return
        }

        // search bar is transitioning
        let percent = 1 - (diff / 46)
        controller?.searchHeaderTransition = percent
        cell?.searchHeaderTransition = percent
    }

    func tapped(view: CenteredSearchHomeCell) {
        activateSearch()
        controller?.chromeDelegate?.omniBar.becomeFirstResponder()
    }
    
    private func activateSearch() {
        guard let controller = self.controller else {
            return
        }
        
        var offset = controller.collectionView.contentOffset
        let omniBarBottomSpacing = controller.chromeDelegate?.omniBar.textFieldBottomSpacing ?? 0
        offset.y = (cell?.bounds.height ?? 0) + overflowOffset + omniBarBottomSpacing
        controller.collectionView.setContentOffset(offset, animated: true)
        controller.chromeDelegate?.omniBar.becomeFirstResponder()
    }
    
    func omniBarCancelPressed() {
        guard let controller = self.controller, let indexPath = indexPath else { return }
        controller.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        overflowOffset = controller.enableContentUnderflow()
    }
    
    func launchNewSearch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.activateSearch()
        }
    }
    
}
