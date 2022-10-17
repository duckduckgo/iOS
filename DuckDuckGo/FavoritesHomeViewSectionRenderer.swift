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

protocol FavoritesHomeViewSectionRendererDelegate: AnyObject {
    
    func favoritesRenderer(_ renderer: FavoritesHomeViewSectionRenderer,
                           didSelect favorite: Bookmark)

    func favoritesRenderer(_ renderer: FavoritesHomeViewSectionRenderer,
                           didRequestEdit favorite: Bookmark)

    func favoritesRenderer(_ renderer: FavoritesHomeViewSectionRenderer,
                           favoriteDeleted favorite: Bookmark)
}

class FavoritesHomeViewSectionRenderer: NSObject, HomeViewSectionRenderer {
    
    struct Constants {
        
        static let searchWidth: CGFloat = 380
        static let searchWidthPad: CGFloat = 455
        static let defaultHeaderHeight: CGFloat = 20
        static let horizontalMargin: CGFloat = 2
        static let largeModeMargin: CGFloat = 24
        
    }
    
    let bookmarksManager: BookmarksManager

    private weak var controller: (UIViewController & FavoritesHomeViewSectionRendererDelegate)?
    
    private weak var reorderingCell: FavoriteHomeCell?
    
    private let allowsEditing: Bool
    private let cellWidth: CGFloat
    private let cellHeight: CGFloat
    
    var isPad: Bool {
        return controller?.traitCollection.horizontalSizeClass == .regular
    }

    init(allowsEditing: Bool = true, bookmarksManager: BookmarksManager = BookmarksManager()) {
        guard let cell = (UINib(nibName: "FavoriteHomeCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView) else {
            fatalError("Failed to load FavoriteHomeCell")
        }
        
        self.allowsEditing = allowsEditing
        self.bookmarksManager = bookmarksManager
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
        if controller is FavoritesOverlay {
            return Constants.largeModeMargin
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

        guard let favorite = bookmarksManager.favorite(atIndex: indexPath.row) else {
            return cell
        }

        cell.updateFor(favorite: favorite)

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
        guard let indexPath = collectionView.indexPath(for: cell),
        let favorite = bookmarksManager.favorite(atIndex: indexPath.row) else { return }
        Pixel.fire(pixel: .homeScreenDeleteFavorite)
        bookmarksManager.delete(favorite)
        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: [indexPath])
            self.controller?.favoritesRenderer(self, favoriteDeleted: favorite)
        }
    }
    
    private func editFavorite(_ cell: FavoriteHomeCell, _ collectionView: UICollectionView) {
        guard let indexPath = collectionView.indexPath(for: cell),
              let favorite = bookmarksManager.favorite(atIndex: indexPath.row) else { return }
        
        Pixel.fire(pixel: .homeScreenEditFavorite)
        
        controller?.favoritesRenderer(self, didRequestEdit: favorite)
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
        guard let favorite = bookmarksManager.favorite(atIndex: sourceIndexPath.row) else {
            return
        }
        bookmarksManager.updateIndex(of: favorite.objectID, newIndex: destinationIndexPath.row)
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

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        launchFavorite(in: collectionView, at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return previewForConfiguration(configuration, inCollectionView: collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return previewForConfiguration(configuration, inCollectionView: collectionView)
    }

    func previewForConfiguration(_ configuration: UIContextMenuConfiguration, inCollectionView collectionView: UICollectionView) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
                let cell = collectionView.cellForItem(at: indexPath) as? FavoriteHomeCell else {
            return nil
        }

        let targetedPreview = UITargetedPreview(view: cell.iconImage)
        targetedPreview.parameters.backgroundColor = .clear
        return targetedPreview
    }

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {

        guard allowsEditing else { return nil }

        guard let cell = collectionView.cellForItem(at: indexPath) as? FavoriteHomeCell else { return nil }

        let edit = UIAction(title: UserText.favoriteMenuEdit,
                            image: UIImage(systemName: "square.and.pencil"),
                            identifier: nil,
                            discoverabilityTitle: nil,
                            state: .off) { [weak self] _ in
            self?.editFavorite(cell, collectionView)
        }

        let delete = UIAction(title: UserText.favoriteMenuDelete,
                              image: UIImage(systemName: "trash"),
                              identifier: nil,
                              discoverabilityTitle: nil,
                              attributes: .destructive, state: .off) { [weak self] _ in
            self?.deleteFavorite(cell, collectionView)
        }

        let context = UIContextMenuConfiguration(identifier: indexPath as NSIndexPath) {
            guard let image = cell.iconImage.image else { return nil }
            return ImagePreviewer(image: image)
        } actionProvider: { _ in
            let title = (cell.favorite?.title ?? "") + "\n" + (cell.favorite?.url?.absoluteString ?? "")
            return UIMenu(title: title, options: .displayInline, children: [
                edit,
                delete
            ])
        }

        return context
    }

    private func launchFavorite(in: UICollectionView, at indexPath: IndexPath) {
        guard let favorite = bookmarksManager.favorite(atIndex: indexPath.row) else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        controller?.favoritesRenderer(self, didSelect: favorite)
    }
    
}

private class ImagePreviewer: UIViewController {

    let image: UIImage

    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        view.addSubview(imageView)
        view.frame = imageView.frame
        preferredContentSize = view.frame.size

    }

}
