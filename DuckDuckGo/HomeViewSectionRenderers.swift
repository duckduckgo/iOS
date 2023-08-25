//
//  HomeViewSectionRenderers.swift
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

protocol HomeViewSectionRenderer: AnyObject {

    // MARK: required

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    
    // MARK: optional
    
    func install(into controller: HomeViewController)
    
    func remove(from controller: HomeViewController)
    
    func omniBarCancelPressed()
    
    func openedAsNewTab(allowingKeyboard: Bool)

    func launchNewSearch()
    
    func supportsReordering() -> Bool
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize?
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize?
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets?

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration?

    func collectionView(_ collectionView: UICollectionView,
                        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview?

    func collectionView(_ collectionView: UICollectionView,
                        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview?

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem]

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator)

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal

    func endReordering()

    func didAppear()
    
}

/// Each renderer added becomes a section in the containing collection view.
class HomeViewSectionRenderers: NSObject,
                                UICollectionViewDelegate,
                                UICollectionViewDelegateFlowLayout,
                                UICollectionViewDataSource,
                                UICollectionViewDragDelegate,
                                UICollectionViewDropDelegate {
    
    struct Constants {
        
        static let sideInsets: CGFloat = 25
        
    }
    
    private weak var controller: HomeViewController!
    private var theme: Theme
    private var renderers = [HomeViewSectionRenderer]()
    
    init(controller: HomeViewController, theme: Theme) {
        self.controller = controller
        self.theme = theme
        super.init()
    }

    func didAppear() {
        renderers.forEach {
            $0.didAppear()
        }
    }

    func install(renderer: HomeViewSectionRenderer) {
        renderer.install(into: controller)
        renderers.append(renderer)
    }
    
    func remove(renderer: HomeViewSectionRenderer) -> Int? {
        renderer.remove(from: controller)
        guard let index = (renderers.firstIndex { $0 === renderer }) else {
            return nil
        }
        renderers.remove(at: index)
        return index
    }
    
    func rendererFor(section: Int) -> HomeViewSectionRenderer {
        return renderers[section]
    }
    
    func omniBarCancelPressed() {
        renderers.forEach { renderer in
            renderer.omniBarCancelPressed()
        }
    }
    
    func openedAsNewTab(allowingKeyboard: Bool) {
        renderers.forEach { renderer in
            renderer.openedAsNewTab(allowingKeyboard: allowingKeyboard)
        }
    }
    
    func launchNewSearch() {
        renderers.forEach { renderer in
            renderer.launchNewSearch()
        }
    }
    
    func endReordering() {
        renderers.forEach { renderer in
            renderer.endReordering()
        }
    }

    func refresh() {
        renderers.forEach { renderer in
            if let renderer = renderer as? HomeMessageViewSectionRenderer {
                renderer.refresh()
            }
        }
    }

    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        renderers.forEach {
            $0.scrollViewDidScroll(scrollView)
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
        if let themable = cell as? Themable {
            themable.decorate(with: theme)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = renderers[indexPath.section].collectionView(collectionView,
                                                               viewForSupplementaryElementOfKind: kind,
                                                               at: indexPath)
        if let themable = cell as? Themable {
            themable.decorate(with: theme)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return renderers[indexPath.section].collectionView(collectionView, shouldSelectItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        renderers[indexPath.section].collectionView(collectionView, didSelectItemAt: indexPath)
    }

    // MARK: UICollectionViewDelegate
     
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return renderers[section].collectionView(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section)
            ?? CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return renderers[section].collectionView(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section)
            ?? CGSize.zero
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return renderers[indexPath.section].collectionView(collectionView,
                                                           contextMenuConfigurationForItemAt: indexPath,
                                                           point: point)
    }

    func collectionView(_ collectionView: UICollectionView,
                        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        return renderers[indexPath.section].collectionView(collectionView,
                                                           previewForDismissingContextMenuWithConfiguration: configuration)
    }

    func collectionView(_ collectionView: UICollectionView,
                        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        return renderers[indexPath.section].collectionView(collectionView,
                                                           previewForHighlightingContextMenuWithConfiguration: configuration)
    }

    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath)
        -> CGSize {
            return renderers[indexPath.section].collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int)
        -> UIEdgeInsets {
            
            return renderers[section].collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: section) ??
                UIEdgeInsets(top: 0, left: Constants.sideInsets, bottom: 0, right: Constants.sideInsets)
    }

    // MARK: Drag and Drop

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return renderers[indexPath.section].collectionView(collectionView, itemsForBeginning: session, at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let section = coordinator.destinationIndexPath?.section else { return }
        renderers[section].collectionView(collectionView, performDropWith: coordinator)
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        guard let section = destinationIndexPath?.section else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
        return renderers[section].collectionView(collectionView, dropSessionDidUpdate: session, withDestinationIndexPath: destinationIndexPath)
    }

}

extension HomeViewSectionRenderers: Themable {
    
    func decorate(with theme: Theme) {
        self.theme = theme
    }
    
}
