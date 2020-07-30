//
//  FavoritesHomeViewSectionRenderer.swift
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

protocol FavoritesHomeViewSectionRendererDelegate: class {
    
    func favoritesRenderer(_ renderer: FavoritesHomeViewSectionRenderer,
                           didSelect link: Link)
    
}

class FavoritesHomeViewSectionRenderer: NSObject, HomeViewSectionRenderer {
    
    struct Constants {
        
        static let searchWidth: CGFloat = CenteredSearchHomeCell.Constants.searchWidth
        static let searchWidthPad: CGFloat = CenteredSearchHomeCell.Constants.searchWidthPad
        static let defaultHeaderHeight: CGFloat = 20
        static let horizontalMargin: CGFloat = 2
        
    }
    
    private lazy var bookmarksManager = BookmarksManager()

    private weak var controller: (UIViewController & FavoritesHomeViewSectionRendererDelegate)?
    
    private weak var reorderingCell: FavoriteHomeCell?
    
    private let allowsEditing: Bool
    private let cellWidth: CGFloat
    private let cellHeight: CGFloat
    
    var isPad: Bool {
        return controller?.traitCollection.horizontalSizeClass == .regular
    }

    init(allowsEditing: Bool = true) {
        guard let cell = (UINib(nibName: "FavoriteHomeCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView) else {
            fatalError("Failed to load FavoriteHomeCell")
        }
        
        self.allowsEditing = allowsEditing
        self.cellHeight = cell.frame.height
        self.cellWidth = cell.frame.width
    }
    
    private var numberOfItems: Int {
        return bookmarksManager.favoritesCount
    }
    
    private var headerHeight: CGFloat {
        return Constants.defaultHeaderHeight
    }
    
    func install(into controller: HomeViewController) {
        self.controller = controller
    }
    
    func install(into controller: UIViewController & FavoritesHomeViewSectionRendererDelegate) {
        self.controller = controller
    }
    
    func endReordering() {
        if let cell = reorderingCell {
            cell.isReordering = false
            reorderingCell = nil
        }
    }
    
    func sectionMargin(in collectionView: UICollectionView) -> CGFloat {
        if FormFactorConfigurator.shared.isPadFormFactor {
            // (WIP) extract to constant
            return 24
        }
        
        let margin: CGFloat
        if isPad {
            margin = (collectionView.frame.width - Constants.searchWidthPad) / 2
        } else {
            let defaultMargin = HomeViewSectionRenderers.Constants.sideInsets
            let landscapeMargin = (collectionView.frame.width - Constants.searchWidth + defaultMargin) / 2
            margin = isPortrait ? defaultMargin : landscapeMargin
        }
        
        return margin
    }
    
    // Visible margin is adjusted for offset inside Favorite Cells
    func visibleMargin(in collectionView: UICollectionView) -> CGFloat {
        return sectionMargin(in: collectionView) + Constants.horizontalMargin
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets? {
        let margin = sectionMargin(in: collectionView)
        
        return UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                               withReuseIdentifier: EmptyCollectionReusableView.reuseIdentifier,
                                                               for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favorite", for: indexPath) as? FavoriteHomeCell else {
            fatalError("not a FavoriteCell")
        }

        guard let link = bookmarksManager.favorite(atIndex: indexPath.row) else {
            return cell
        }
        cell.updateFor(link: link)

        // can't use captured index path because deleting items can change it
        cell.onDelete = { [weak self, weak collectionView, weak cell] in
            guard let collectionView = collectionView else { return }
            guard let cell = cell else { return }
            
            self?.deleteFavorite(cell, collectionView)
        }
        cell.onEdit = { [weak self, weak collectionView, weak cell] in
            guard let collectionView = collectionView else { return }
            guard let cell = cell else { return }
            
            self?.editFavorite(cell, collectionView)
        }
        return cell

    }
    
    private func deleteFavorite(_ cell: FavoriteHomeCell, _ collectionView: UICollectionView) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        Pixel.fire(pixel: .homeScreenDeleteFavorite)
        bookmarksManager.deleteFavorite(at: indexPath.row)
        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: [indexPath])
        })
    }
    
    private func editFavorite(_ cell: FavoriteHomeCell, _ collectionView: UICollectionView) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        Pixel.fire(pixel: .homeScreenEditFavorite)
        let alert = EditBookmarkAlert.buildAlert(
            title: UserText.alertSaveFavorite,
            bookmark: bookmarksManager.favorite(atIndex: indexPath.row),
            saveCompletion: { [weak self, weak collectionView] newLink in
                guard let collectionView = collectionView else { return }
                self?.updateFavorite(at: indexPath, in: collectionView, with: newLink)
            })
        controller?.present(alert, animated: true, completion: nil)
    }
    
    private func updateFavorite(at indexPath: IndexPath, in collectionView: UICollectionView, with link: Link) {
        bookmarksManager.updateFavorite(at: indexPath.row, with: link)
        collectionView.performBatchUpdates({
            collectionView.reloadItems(at: [indexPath])
        })
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.horizontalMargin + cellWidth, height: cellHeight)
    }
    
    func supportsReordering() -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard allowsEditing else {
            return false
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? FavoriteHomeCell {
            cell.isReordering = true
            reorderingCell = cell
            return true
        }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        bookmarksManager.moveFavorite(at: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath,
                        toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath? {
        guard originalIndexPath.section == proposedIndexPath.section else { return originalIndexPath }
        return proposedIndexPath
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize? {
        return CGSize(width: 1, height: headerHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize? {
        return CGSize(width: 1, height: Constants.defaultHeaderHeight)
    }

    func menuItemsFor(itemAt: Int) -> [UIMenuItem]? {
        return [
            UIMenuItem(title: UserText.favoriteMenuDelete, action: FavoriteHomeCell.Actions.delete),
            UIMenuItem(title: UserText.favoriteMenuEdit, action: FavoriteHomeCell.Actions.edit)
        ]
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        launchFavorite(in: collectionView, at: indexPath)
    }

    private func launchFavorite(in: UICollectionView, at indexPath: IndexPath) {
        guard let link = bookmarksManager.favorite(atIndex: indexPath.row) else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        controller?.favoritesRenderer(self, didSelect: link)
    }
    
    private func addNewFavorite(in collectionView: UICollectionView, at indexPath: IndexPath) {
        Pixel.fire(pixel: .homeScreenAddFavorite)
        let alert = EditBookmarkAlert.buildAlert(
            title: UserText.alertSaveFavorite,
            bookmark: nil,
            saveCompletion: { [weak self] newLink in
                Pixel.fire(pixel: .homeScreenAddFavoriteOK)
                self?.saveNewFavorite(newLink, in: collectionView, at: indexPath)
            },
            cancelCompletion: {
                Pixel.fire(pixel: .homeScreenAddFavoriteCancel)
            }
        )
        controller?.present(alert, animated: true, completion: nil)
    }
    
    private func saveNewFavorite(_ link: Link, in collectionView: UICollectionView, at indexPath: IndexPath) {
        bookmarksManager.save(favorite: link)
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: [indexPath])
        })
    }
    
}
