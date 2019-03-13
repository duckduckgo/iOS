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

class FavoritesHomeViewSectionRenderer: HomeViewSectionRenderer {
    
    struct Constants {
        
        static let searchWidth: CGFloat = CenteredSearchHomeCell.Constants.searchWidth
        static let searchWidthPad: CGFloat = CenteredSearchHomeCell.Constants.searchWidthPad
        
    }
    
    private lazy var bookmarksManager = BookmarksManager()

    private weak var controller: HomeViewController!
    
    private weak var reorderingCell: FavoriteHomeCell?
    
    // Plus one for the add button
    private var numberOfItems: Int {
        return bookmarksManager.favoritesCount + 1
    }
    
    func install(into controller: HomeViewController) {
        self.controller = controller
    }
    
    func endReordering() {
        if let cell = reorderingCell {
            cell.isReordering = false
            reorderingCell = nil
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int)
        -> UIEdgeInsets? {

        let margin: CGFloat
        if isPad {
            margin = (controller.collectionView.frame.width - Constants.searchWidthPad) / 2
        } else {
            let defaultMargin = HomeViewSectionRenderers.Constants.sideInsets
            let landscapeMargin = (controller.collectionView.frame.width - Constants.searchWidth + defaultMargin) / 2
            margin = isPortrait ? defaultMargin : landscapeMargin
        }

        return UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isLastItem(indexPath) {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "addFavorite", for: indexPath)
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favorite", for: indexPath) as? FavoriteHomeCell else {
                fatalError("not a FavoriteCell")
            }

            guard let link = bookmarksManager.favorite(atIndex: indexPath.row) else {
                return cell
            }
            cell.updateFor(link: link)

            // can't use captured index path because deleting items can change it
            cell.onDelete = { [weak self] in
                self?.deleteFavorite(cell, collectionView)
            }
            cell.onEdit = { [weak self] in
                self?.editFavorite(cell, collectionView)
            }
            return cell
        }
        
    }
    
    private func deleteFavorite(_ cell: FavoriteHomeCell, _ collectionView: UICollectionView) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        bookmarksManager.deleteFavorite(at: indexPath.row)
        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: [indexPath])
        })
    }
    
    private func editFavorite(_ cell: FavoriteHomeCell, _ collectionView: UICollectionView) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let alert = EditBookmarkAlert.buildAlert (
            title: UserText.alertSaveFavorite,
            bookmark: bookmarksManager.favorite(atIndex: indexPath.row),
            saveCompletion: { [weak self] newLink in
                self?.updateFavorite(at: indexPath, in: collectionView, with: newLink)
            })
        controller.present(alert, animated: true, completion: nil)
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
        return CGSize(width: FavoriteHomeCell.Constants.width, height: FavoriteHomeCell.Constants.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if let cell = collectionView.cellForItem(at: indexPath) as? FavoriteHomeCell {
            cell.isReordering = true
            reorderingCell = cell
        }
        return !isLastItem(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        bookmarksManager.moveFavorite(at: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath,
                        toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath? {
        guard originalIndexPath.section == proposedIndexPath.section else { return originalIndexPath }
        guard !isLastItem(proposedIndexPath) else { return originalIndexPath }
        return proposedIndexPath
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize? {
        
        return CGSize(width: 1, height: 39)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize? {
        
        return CGSize(width: 1, height: 10)
    }

    func menuItemsFor(itemAt: Int) -> [UIMenuItem]? {
        return [
            UIMenuItem(title: UserText.favoriteMenuDelete, action: FavoriteHomeCell.Actions.delete),
            UIMenuItem(title: UserText.favoriteMenuEdit, action: FavoriteHomeCell.Actions.edit)
        ]
    }
    
    private func isLastItem(_ indexPath: IndexPath) -> Bool {
        return indexPath.row + 1 == numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isLastItem(indexPath) {
            addNewFavorite(in: collectionView, at: indexPath)
        } else {
            launchFavorite(in: collectionView, at: indexPath)
        }
    }

    private func launchFavorite(in: UICollectionView, at indexPath: IndexPath) {
        guard let link = bookmarksManager.favorite(atIndex: indexPath.row) else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        controller.launch(link)
    }
    
    private func addNewFavorite(in collectionView: UICollectionView, at indexPath: IndexPath) {
        let alert = EditBookmarkAlert.buildAlert (
            title: UserText.alertSaveFavorite,
            bookmark: nil,
            saveCompletion: { [weak self] newLink in
                self?.saveNewFavorite(newLink, in: collectionView, at: indexPath)
            }
        )
        controller.present(alert, animated: true, completion: nil)
    }
    
    private func saveNewFavorite(_ link: Link, in collectionView: UICollectionView, at indexPath: IndexPath) {
        bookmarksManager.save(favorite: link)
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: [indexPath])
        })
    }
    
}
