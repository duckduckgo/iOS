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
    
    let enablePP = true

    struct Constants {
        
        static let searchCenterOffset: CGFloat = 50
        static let scrollUpAdjustment: CGFloat = 46
        
        static let fixedSearchCenterOffset: CGFloat = 40
        
        static let searchWidth: CGFloat = CenteredSearchHomeCell.Constants.searchWidth
        static let searchWidthPad: CGFloat = CenteredSearchHomeCell.Constants.searchWidthPad
        
    }
    
    private var searchCenterOffset: CGFloat {
        return fixed && isPortrait ? Constants.fixedSearchCenterOffset : Constants.searchCenterOffset
    }
    
    private var overflowOffset: CGFloat = 0
    
    private weak var controller: HomeViewController!
    private weak var cell: CenteredSearchHomeCell?

    private var heightRatio: CGFloat {
        return fixed ? 1.875 : 2.0
    }
    
    private var indexPath: IndexPath?
    
    private let fixed: Bool
    
    var centeredSearch: UIView? {
        return cell?.searchBackground
    }
    
    init(fixed: Bool = false) {
        self.fixed = fixed
    }
    
    func install(into controller: HomeViewController) {
        self.controller = controller
        
        //controller.collectionView.isScrollEnabled = !fixed

        overflowOffset = controller.enableContentUnderflow()
        controller.searchHeaderTransition = 0.0
        cell?.searchHeaderTransition = 0.0
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        indexPath = IndexPath(row: 0, section: section)
        return enablePP ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        if indexPath.row == 0 {
            cell = centeredSearchCell(for: collectionView, at: indexPath)
        } else {
            cell = privacyProtectionCell(for: collectionView, at: indexPath)
        }
        return cell
    }
    
    private func centeredSearchCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "centeredSearch", for: indexPath) as? CenteredSearchHomeCell else {
            fatalError("cell is not a CenteredSearchHomeCell")
        }
        cell.tapped = self.tapped
        cell.targetSearchHeight = controller.chromeDelegate?.omniBar.editingBackground.frame.height ?? 0
        cell.targetSearchRadius = controller.chromeDelegate?.omniBar.editingBackground.layer.cornerRadius ?? 0
        self.cell = cell
        return cell
    }
    
    private func privacyProtectionCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PrivacyHomeCell", for: indexPath) as? PrivacyProtectionHomeCell else {
            fatalError("cell is not a PrivacyProtectionCell")
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath)
        -> CGSize {
            switch indexPath.row {
            case 0:
                let height = (collectionView.frame.height / heightRatio) - searchCenterOffset
                let width: CGFloat = collectionView.frame.width - (HomeViewSectionRenderers.Constants.sideInsets * 2)
                return CGSize(width: width, height: height)
            case 1:
                let searchWidth = isPad ? Constants.searchWidthPad : Constants.searchWidth
                let width: CGFloat = min(collectionView.frame.width - (HomeViewSectionRenderers.Constants.sideInsets * 2), searchWidth)
                return CGSize(width: width, height: 65)
            default:
                return .zero
            }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY: CGFloat = Constants.scrollUpAdjustment

        let targetHeight = (scrollView.frame.height / heightRatio) - searchCenterOffset
        let y = scrollView.contentOffset.y

        let diff = targetHeight - y - offsetY
        
        print("Offset: \(y)")

        guard diff < offsetY else {
            // search bar is in the center
            controller.searchHeaderTransition = 0.0
            cell?.searchHeaderTransition = 0.0
            return
        }
        
        guard diff > 0 else {
            // search bar is in the navigation bar
            controller.searchHeaderTransition = 1.0
            cell?.searchHeaderTransition = 1.0
            return
        }

        // search bar is transitioning
        let percent = 1 - (diff / 46)
        controller.searchHeaderTransition = percent
        cell?.searchHeaderTransition = percent
    }

    func tapped(view: CenteredSearchHomeCell) {
        activateSearch()
        controller.chromeDelegate?.omniBar.becomeFirstResponder()
    }
    
    private func activateSearch() {
        guard let thisIndexPath = indexPath else { return }
        
        if enablePP {
            var offset = controller.collectionView.contentOffset
            // TODO - numbers should come from frames/contraints 
            offset.y = 79 + (cell?.bounds.height ?? 0) + overflowOffset - 65
            controller.collectionView.setContentOffset(offset, animated: true)
        } else {
            let targetIndexPath = IndexPath(row: 0, section: thisIndexPath.section + 1)
            controller.collectionView.scrollToItem(at: targetIndexPath, at: .top, animated: true)
        }
        controller.chromeDelegate?.omniBar.becomeFirstResponder()
    }
    
    func omniBarCancelPressed() {
        guard let indexPath = indexPath else { return }
        controller.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        // TODO ?
        overflowOffset = controller.enableContentUnderflow()
    }
    
    func launchNewSearch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.activateSearch()
        }
    }
    
    func openedAsNewTab() {
        launchNewSearch()
    }
    
}
