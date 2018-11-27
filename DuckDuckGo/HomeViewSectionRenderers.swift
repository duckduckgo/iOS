//
//  HomeViewSectionRenderer.swift
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
    
    @objc optional func install(into controller: HomeViewController)
    
    @objc optional func omniBarCancelPressed()
    
    @objc optional func openedAsNewTab()
    
    @objc optional func menuItemsFor(itemAt: Int) -> [UIMenuItem]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    
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
    
    @objc optional func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool
    
    @objc optional func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    
}

class HomeViewSectionRenderers: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var theme: Theme

    private let controller: HomeViewController
    
    private var renderers = [HomeViewSectionRenderer]()
    
    init(controller: HomeViewController, theme: Theme) {
        self.controller = controller
        self.theme = theme
        super.init()
    }
    
    func install(renderer: HomeViewSectionRenderer) {
        renderer.install?(into: controller)
        renderers.append(renderer)
    }
    
    func rendererFor(section: Int) -> HomeViewSectionRenderer {
        return renderers[section]
    }
    
    func omniBarCancelPressed() {
        renderers.forEach { renderer in
            renderer.omniBarCancelPressed?()
        }
    }
    
    func openedAsNewTab() {
        renderers.forEach { renderer in
            renderer.openedAsNewTab?()
        }
    }
    
    // MARK: UICollectionViewDataSource
        
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return renderers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return renderers[section].collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = renderers[indexPath.section].collectionView(collectionView, cellForItemAt: indexPath)
        if let themable = cell as? ThemableCollectionViewCell {
            themable.decorate(with: theme)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        print("***", #function)
        return renderers[indexPath.section].collectionView?(collectionView, canMoveItemAt: indexPath) ?? false
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("***", #function)
        renderers[sourceIndexPath.section].collectionView?(collectionView, moveItemAt: sourceIndexPath, to: destinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return renderers[indexPath.section].collectionView?(collectionView, shouldSelectItemAt: indexPath) ?? false
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        renderers[indexPath.section].collectionView?(collectionView, didSelectItemAt: indexPath)
    }
    
    // we can't set this in the storyboard because we're using a custom layout for animations
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 10, height: 10)
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
