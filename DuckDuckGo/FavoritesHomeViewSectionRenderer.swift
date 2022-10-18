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

struct Favorite: Equatable {

    let id: String
    let url: URL?
    let title: String?

    var displayTitle: String {
        title ?? url?.absoluteString ?? ""
    }

}

protocol FavoritesViewModel {

    var count: Int { get }

    func move(_ favorite: Favorite, toIndexAt index: Int)

    func delete(_ favorite: Favorite)

    func favorite(atIndex: Int) -> Favorite?

}

class InMemoryFavoritesViewModel: FavoritesViewModel {

    static let shared: FavoritesViewModel = InMemoryFavoritesViewModel()

    var favorites = [

        Favorite(id: "1", url: URL(string: "https://www.bbc.co.uk"), title: "BBC"),
        Favorite(id: "2", url: URL(string: "https://news.ycombinator.com"), title: "Hacker News"),
        Favorite(id: "3", url: URL(string: "https://time.com"), title: "Time Magazine")

    ]

    var count: Int {
        favorites.count
    }

    func move(_ favorite: Favorite, toIndexAt index: Int) {
        guard let existingIndex = favorites.firstIndex(where: { $0 == favorite }) else {
            assertionFailure("Unknown favorite")
            return
        }
        favorites.remove(at: existingIndex)
        favorites.insert(favorite, at: index)
    }

    func favorite(atIndex index: Int) -> Favorite? {
        guard favorites.indices.contains(index) else { return nil }
        return favorites[index]
    }

    func delete(_ favorite: Favorite) {
        guard let index = favorites.firstIndex(where: { $0 == favorite }) else {
            assertionFailure("Unknown favorite")
            return
        }
        favorites.remove(at: index)
    }

}

class FavoritesHomeViewSectionRenderer: NSObject, HomeViewSectionRenderer {

    struct Constants {
        
        static let searchWidth: CGFloat = 380
        static let searchWidthPad: CGFloat = 455
        static let defaultHeaderHeight: CGFloat = 20
        static let horizontalMargin: CGFloat = 2
        static let largeModeMargin: CGFloat = 24
        
    }
    
    let viewModel: FavoritesViewModel

    private weak var controller: (UIViewController & FavoritesHomeViewSectionRendererDelegate)?
    
    private weak var reorderingCell: FavoriteHomeCell?

    var isEditing = false

    private let allowsEditing: Bool
    private let cellWidth: CGFloat
    private let cellHeight: CGFloat
    
    var isPad: Bool {
        return controller?.traitCollection.horizontalSizeClass == .regular
    }

    init(allowsEditing: Bool = true, viewModel: FavoritesViewModel = InMemoryFavoritesViewModel.shared) {
        guard let cell = (UINib(nibName: "FavoriteHomeCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView) else {
            fatalError("Failed to load FavoriteHomeCell")
        }
        
        self.allowsEditing = allowsEditing
        self.cellHeight = cell.frame.height
        self.cellWidth = cell.frame.width
        self.viewModel = viewModel
    }
    
    private var numberOfItems: Int {
        return viewModel.count
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

        guard let favorite = viewModel.favorite(atIndex: indexPath.row) else {
            return cell
        }

        cell.updateFor(favorite: favorite)
        cell.isEditing = isEditing

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
        let favorite = viewModel.favorite(atIndex: indexPath.row) else { return }
        Pixel.fire(pixel: .homeScreenDeleteFavorite)
        viewModel.delete(favorite)
        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: [indexPath])
            // self.controller?.favoritesRenderer(self, favoriteDeleted: favorite)
        }
    }
    
    private func editFavorite(_ cell: FavoriteHomeCell, _ collectionView: UICollectionView) {
        guard let indexPath = collectionView.indexPath(for: cell),
              let favorite = viewModel.favorite(atIndex: indexPath.row) else { return }
        
        Pixel.fire(pixel: .homeScreenEditFavorite)
        
        // controller?.favoritesRenderer(self, didRequestEdit: favorite)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.horizontalMargin + cellWidth, height: cellHeight)
    }
    
    func supportsReordering() -> Bool {
        return true
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
        if isEditing {
            guard let cell = collectionView.cellForItem(at: indexPath) as? FavoriteHomeCell else { return }
            editFavorite(cell, collectionView)
        } else {
            launchFavorite(in: collectionView, at: indexPath)
        }
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

        let targetedPreview = UITargetedPreview(view: cell.iconBackground)
        targetedPreview.parameters.backgroundColor = .clear
        return targetedPreview
    }

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {

        guard allowsEditing else { return nil }

        guard let cell = collectionView.cellForItem(at: indexPath) as? FavoriteHomeCell else { return nil }

        let edit = UIAction(title: UserText.favoriteMenuEdit,
                            image: UIImage(named: "Edit"),
                            identifier: nil,
                            discoverabilityTitle: nil,
                            state: .off) { [weak self] _ in
            self?.editFavorite(cell, collectionView)
        }

        let delete = UIAction(title: UserText.favoriteMenuDelete,
                              image: UIImage(named: "Trash"),
                              identifier: nil,
                              discoverabilityTitle: nil,
                              attributes: .destructive, state: .off) { [weak self] _ in
            self?.deleteFavorite(cell, collectionView)
        }

        let context = UIContextMenuConfiguration(identifier: indexPath as NSIndexPath) {
            guard let image = cell.iconImage.image else { return nil }
            return UIImageViewController(image: image)
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
        guard let favorite = viewModel.favorite(atIndex: indexPath.row) else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        // controller?.favoritesRenderer(self, didSelect: favorite)
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard coordinator.proposal.operation == .move,
              let dragItem = coordinator.items.first?.dragItem,
              let sourcePath = coordinator.items.first?.sourceIndexPath,
              let destinationPath = coordinator.destinationIndexPath,
              let cell = self.collectionView(collectionView, cellForItemAt: sourcePath) as? FavoriteHomeCell,
              let favorite = cell.favorite
        else { return }

        cell.isReordering = false

        viewModel.move(favorite, toIndexAt: destinationPath.row)
        coordinator.drop(dragItem, toItemAt: destinationPath)

        collectionView.performBatchUpdates {
            collectionView.moveItem(at: sourcePath, to: destinationPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let cell = self.collectionView(collectionView, cellForItemAt: indexPath) as? FavoriteHomeCell else { return [] }

        UIGraphicsBeginImageContextWithOptions(cell.iconBackground.frame.size, true, 1.0)
        defer {
            UIGraphicsEndImageContext()
        }

        cell.iconBackground.drawHierarchy(in: cell.iconBackground.frame, afterScreenUpdates: false)
        cell.isReordering = true
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            assertionFailure("Unable to create image from context")
            return []
        }

        let dragItem = UIDragItem(itemProvider: NSItemProvider(object: image))
        dragItem.previewProvider = { () -> UIDragPreview? in
            return UIDragPreview(view: cell.iconBackground)
        }
        return [
            dragItem
        ]
    }

    func collectionView(_ collectionView: UICollectionView,
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {

        guard collectionView.hasActiveDrag else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }

        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }

}
