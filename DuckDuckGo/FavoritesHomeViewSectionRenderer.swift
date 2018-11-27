//
//  FavoritesHomeViewSectionRenderer.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 26/11/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit

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
            cell.updateFor(link: link, at: indexPath)
            return cell
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
        bookmarksManager.moveFavorite(at: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath,
                        toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        print("***", #function, originalIndexPath, proposedIndexPath)
        guard originalIndexPath.section == proposedIndexPath.section else { return originalIndexPath }
        guard !isLastItem(proposedIndexPath) else { return originalIndexPath }
        return proposedIndexPath
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
            controller.delegate?.addNewFavorite()
        } else {
            let link = bookmarksManager.favorite(atIndex: indexPath.row)
            UISelectionFeedbackGenerator().selectionChanged()
            controller.delegate?.home(controller, didRequestUrl: link.url)
        }
    }
    
}
