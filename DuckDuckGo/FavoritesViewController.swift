//
//  FavoritesViewController.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

import Foundation
import UIKit
import Core
import DDGSync
import Bookmarks
import Persistence
import Combine

protocol FavoritesViewControllerDelegate: NSObjectProtocol {

    func favoritesViewController(_ controller: FavoritesViewController, didSelectFavorite: BookmarkEntity)
    func favoritesViewController(_ controller: FavoritesViewController, didRequestEditFavorite: BookmarkEntity)

}

class FavoritesViewController: UIViewController {

    @IBOutlet weak var emptyStateContainer: UIView!

    struct Constants {
        static let margin: CGFloat = 12
        static let footerPadding: CGFloat = 50
    }

    private let layout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView!
    private var renderer: FavoritesHomeViewSectionRenderer!

    private var theme: Theme?

    weak var delegate: FavoritesViewControllerDelegate?
    
    private let bookmarksDatabase: CoreDataDatabase
    private let syncService: DDGSyncing
    private let syncDataProviders: SyncDataProviders
    private let appSettings: AppSettings
    
    fileprivate var viewModelCancellable: AnyCancellable?
    private var localUpdatesCancellable: AnyCancellable?
    private var syncUpdatesCancellable: AnyCancellable?
    private var favoritesDisplayModeCancellable: AnyCancellable?

    var hasFavorites: Bool {
        renderer.viewModel.favorites.count > 0
    }

    override var isEditing: Bool {
        didSet {
            renderer.isEditing = isEditing
            collectionView.reloadData()
        }
    }
    
    init?(
        coder: NSCoder,
        bookmarksDatabase: CoreDataDatabase,
        syncService: DDGSyncing,
        syncDataProviders: SyncDataProviders,
        appSettings: AppSettings
    ) {
        self.bookmarksDatabase = bookmarksDatabase
        self.syncService = syncService
        self.syncDataProviders = syncDataProviders
        self.appSettings = appSettings
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        theme = ThemeManager.shared.currentTheme

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)

        collectionView.register(UINib(nibName: "FavoriteHomeCell", bundle: nil), forCellWithReuseIdentifier: "favorite")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.backgroundColor = .clear

        view.addSubview(collectionView)

        let favoritesListViewModel = FavoritesListViewModel(
            bookmarksDatabase: bookmarksDatabase,
            favoritesDisplayMode: appSettings.favoritesDisplayMode
        )

        renderer = FavoritesHomeViewSectionRenderer(allowsEditing: true, viewModel: favoritesListViewModel)
        renderer.install(into: self)

        // Has to happen after the renderer is installed
        collectionView.contentInset = .init(top: 8, left: 0, bottom: 0, right: 0)

        viewModelCancellable = renderer.viewModel.externalUpdates.sink { [weak self] _ in
            self?.collectionView.reloadData()
            self?.updateHeroImage()
        }

        favoritesDisplayModeCancellable = NotificationCenter.default.publisher(for: AppUserDefaults.Notifications.favoritesDisplayModeChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                self.renderer.viewModel.favoritesDisplayMode = self.appSettings.favoritesDisplayMode
                self.collectionView.reloadData()
            }

        registerForKeyboardNotifications()

        updateHeroImage()

        applyTheme(ThemeManager.shared.currentTheme)

        bindSyncService()
    }

    private func bindSyncService() {
        localUpdatesCancellable = renderer.viewModel.localUpdates
            .sink { [weak self] in
                self?.syncService.scheduler.notifyDataChanged()
            }

        syncUpdatesCancellable = syncDataProviders.bookmarksAdapter.syncDidCompletePublisher
            .sink { [weak self] _ in
                self?.renderer.viewModel.reloadData()
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if AppWidthObserver.shared.isLargeWidth {
            layout.minimumInteritemSpacing = 32
        } else {
            layout.minimumInteritemSpacing = 10
        }

        collectionView.frame = view.bounds
        collectionView.setNeedsLayout()
    }

    private func updateHeroImage() {
        emptyStateContainer.isHidden = renderer.viewModel.favorites.count > 0
    }

    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    @objc private func keyboardDidShow(notification: NSNotification) {
        guard !AppWidthObserver.shared.isLargeWidth else { return }
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardSize = keyboardFrame.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height + Constants.margin * 2, right: 0.0)
        collectionView.contentInset = contentInsets
        collectionView.scrollIndicatorInsets = contentInsets
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        collectionView.contentInset = contentInsets
        collectionView.scrollIndicatorInsets = contentInsets
    }
}

extension FavoritesViewController: FavoritesHomeViewSectionRendererDelegate {

    func favoritesRenderer(_ renderer: FavoritesHomeViewSectionRenderer, didSelect favorite: BookmarkEntity) {
        delegate?.favoritesViewController(self, didSelectFavorite: favorite)
    }

    func favoritesRenderer(_ renderer: FavoritesHomeViewSectionRenderer, didRequestEdit favorite: BookmarkEntity) {
        delegate?.favoritesViewController(self, didRequestEditFavorite: favorite)
    }

    func favoritesRenderer(_ renderer: FavoritesHomeViewSectionRenderer, favoriteDeleted favorite: BookmarkEntity) {
        updateHeroImage()
    }

}

extension FavoritesViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        renderer.collectionView(collectionView, didSelectItemAt: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 1, height: Constants.footerPadding)
    }

}

extension FavoritesViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return renderer.collectionView(collectionView, itemsForBeginning: session, at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        renderer.collectionView(collectionView, performDropWith: coordinator)
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return renderer.collectionView(collectionView, dropSessionDidUpdate: session, withDestinationIndexPath: destinationIndexPath)
    }

}

extension FavoritesViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return renderer.collectionView(collectionView, numberOfItemsInSection: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = renderer.collectionView(collectionView, cellForItemAt: indexPath)
        if let themable = cell as? Themable,
            let theme = theme {
            themable.decorate(with: theme)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return renderer.collectionView(collectionView, previewForHighlightingContextMenuWithConfiguration: configuration)
    }

    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return renderer.collectionView(collectionView, previewForHighlightingContextMenuWithConfiguration: configuration)
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return renderer.collectionView(collectionView, contextMenuConfigurationForItemAt: indexPath, point: point)
    }

}


extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath)
        -> CGSize {
            return renderer.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int)
        -> UIEdgeInsets {

            var insets = renderer.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: section) ?? UIEdgeInsets.zero

            insets.top += Constants.margin
            return insets
    }
}

extension FavoritesViewController: Themable {

    func decorate(with theme: Theme) {
        self.theme = theme
        view.backgroundColor = theme.backgroundColor
        collectionView.backgroundColor = .clear
        emptyStateContainer.backgroundColor = .clear
        
        collectionView.reloadData()
    }
}
