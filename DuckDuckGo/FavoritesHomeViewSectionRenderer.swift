//
//  FavoritesHomeViewSectionRenderer.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 26/11/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class FavoritesHomeViewSectionRenderer: HomeViewSectionRenderer {
    
    private lazy var bookmarksManager = BookmarksManager()

    private weak var controller: HomeViewController!
    
    // The add button is the plus one
    private var numberOfItems: Int {
        return bookmarksManager.favoritesCount + 1
    }
    
    func install(into controller: HomeViewController) {
        self.controller = controller
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

            let link = bookmarksManager.favorite(atIndex: indexPath.row)
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
            },
            cancelCompletion: {})
        controller.present(alert, animated: true, completion: nil)
    }
    
    private func updateFavorite(at indexPath: IndexPath, in collectionView: UICollectionView, with link: Link) {
        bookmarksManager.updateFavorite(at: indexPath.row, with: link)
        collectionView.performBatchUpdates({
            collectionView.reloadItems(at: [indexPath])
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath)
        -> CGSize {
            return CGSize(width: 68, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return !isLastItem(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        bookmarksManager.moveFavorite(at: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath,
                        toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        guard originalIndexPath.section == proposedIndexPath.section else { return originalIndexPath }
        guard !isLastItem(proposedIndexPath) else { return originalIndexPath }
        return proposedIndexPath
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: 1, height: 39)
    }

    func menuItemsFor(itemAt: Int) -> [UIMenuItem] {
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
            let link = bookmarksManager.favorite(atIndex: indexPath.row)
            UISelectionFeedbackGenerator().selectionChanged()
            controller.delegate?.home(controller, didRequestUrl: link.url)
        }
    }

    private func addNewFavorite(in collectionView: UICollectionView, at indexPath: IndexPath) {
        let alert = EditBookmarkAlert.buildAlert (
            title: UserText.alertSaveFavorite,
            bookmark: nil,
            saveCompletion: { [weak self] newLink in
                self?.saveNewFavorite(newLink, in: collectionView, at: indexPath)
            },
            cancelCompletion: {})
        controller.present(alert, animated: true, completion: nil)
    }
    
    private func saveNewFavorite(_ link: Link, in collectionView: UICollectionView, at indexPath: IndexPath) {
        bookmarksManager.save(favorite: link)
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: [indexPath])
        })
    }
    
}
