//
//  HomeComponents.swift
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

class ThemableCollectionViewCell: UICollectionViewCell, Themable {
    func decorate(with theme: Theme) {
    }
}

@objc protocol HomeViewSectionRenderer {
    
    var numberOfItems: Int { get }
    
    @objc optional func install(into controller: HomeViewController)
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       canMoveItemAt indexPath: IndexPath) -> Bool
    
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       moveItemAt sourceIndexPath: IndexPath,
                                       to destinationIndexPath: IndexPath)
    
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath,
                                       toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath
}

class HomeViewSectionRenderers: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private var renderers = [HomeViewSectionRenderer]()
    
    private var controller: HomeViewController
    
    private var deleteAction = #selector(ShortcutCell.doDelete)
    
    init(controller: HomeViewController) {
        self.controller = controller
        super.init()
    }
    
    func install(renderer: HomeViewSectionRenderer) {
        renderer.install?(into: controller)
        renderers.append(renderer)
    }
    
    // MARK: UICollectionViewDataSource
        
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return renderers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return renderers[section].numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return renderers[indexPath.section].collectionView(collectionView, cellForItemAt: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        print("***", #function)
        return renderers[indexPath.section].collectionView?(collectionView, canMoveItemAt: indexPath) ?? false
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("***", #function)
        renderers[sourceIndexPath.section].collectionView?(collectionView, moveItemAt: sourceIndexPath, to: destinationIndexPath)
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath,
                        toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        print("***", #function)
        return renderers[originalIndexPath.section].collectionView?(collectionView,
                                                                    targetIndexPathForMoveFromItemAt: originalIndexPath,
                                                                    toProposedIndexPath: proposedIndexPath) ?? originalIndexPath
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath)
        -> CGSize {
            return renderers[indexPath.section].collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
    }
    
}

class NavigationSearchHomeViewSectionRenderer: HomeViewSectionRenderer {
    
    func install(into controller: HomeViewController) {
        controller.chromeDelegate?.setNavigationBarHidden(false)
    }
    
    let numberOfItems: Int = 1
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let view = collectionView.dequeueReusableCell(withReuseIdentifier: "navigationSearch", for: indexPath)
            as? ThemableCollectionViewCell else {
            fatalError("cell is not a ThemableCollectionViewCell")
        }
        view.frame = collectionView.bounds
        view.decorate(with: ThemeManager.shared.currentTheme)
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath)
        -> CGSize {
            return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

class CenteredSearchHomeViewSectionRenderer: HomeViewSectionRenderer {
    
    private weak var controller: HomeViewController!
    
    private var hidden = false
    private var indexPath: IndexPath!
    
    var numberOfItems: Int {
        return hidden ? 0 : 1
    }
    
    func install(into controller: HomeViewController) {
        self.controller = controller
        controller.chromeDelegate?.setNavigationBarHidden(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.indexPath = indexPath
        guard let view = collectionView.dequeueReusableCell(withReuseIdentifier: "centeredSearch", for: indexPath)
            as? CenteredSearchCell else {
            fatalError("cell is not CenteredSearchCell")
        }
        view.decorate(with: ThemeManager.shared.currentTheme)
        view.tapped = self.tapped
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath)
        -> CGSize {
        let height = (collectionView.frame.height * 2 / 3)
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tapped(view: CenteredSearchCell) {
        hidden = true
        
        controller.collectionView.performBatchUpdates({
            controller.chromeDelegate?.setNavigationBarHidden(false)
            self.controller.collectionView.deleteItems(at: [indexPath])
        }, completion: { _ in
            self.controller.chromeDelegate?.omniBar.becomeFirstResponder()
        })
    
    }
    
}

class ShortcutsHomeViewSectionRenderer: HomeViewSectionRenderer {
    
    let numberOfItems: Int = 9
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isLastItem(indexPath) {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "addShortcut", for: indexPath)
        } else {
            guard let view = collectionView.dequeueReusableCell(withReuseIdentifier: "shortcut", for: indexPath) as? ShortcutCell else {
                fatalError("not a ShortcutCell")
            }
            return view
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath)
        -> CGSize {
        return CGSize(width: 80, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        print("***", #function, indexPath)
        return !isLastItem(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("***", #function)
    }

    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath,
                        toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        print("***", #function, originalIndexPath, proposedIndexPath)
        guard originalIndexPath.section == proposedIndexPath.section else { return originalIndexPath }
        guard !isLastItem(proposedIndexPath) else { return originalIndexPath }
        return proposedIndexPath
    }
    
    func isLastItem(_ indexPath: IndexPath) -> Bool {
        return indexPath.row + 1 == numberOfItems
    }
    
}
