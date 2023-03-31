//
//  FavoritesOverlay.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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
import Bookmarks
import Persistence
import Combine

protocol FavoritesOverlayDelegate: AnyObject {
    
    func favoritesOverlay(_ overlay: FavoritesOverlay, didSelect favorite: BookmarkEntity)
    func favoritesOverlay(_ controller: FavoritesOverlay, didRequestEditFavorite: BookmarkEntity)
}

class FavoritesOverlay: UIViewController {
    
    struct Constants {
        static let margin: CGFloat = 28
        static let footerPadding: CGFloat = 50
        static let collectionViewMaxWidth: CGFloat = 395
    }
    
    private let layout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView!
    private var renderer: FavoritesHomeViewSectionRenderer!
    
    private var theme: Theme!
    
    private var viewModelCancellable: AnyCancellable?
    
    weak var delegate: FavoritesOverlayDelegate?
    
    private lazy var collectionViewReorderingGesture =
        UILongPressGestureRecognizer(target: self, action: #selector(self.collectionViewReorderingGestureHandler(gesture:)))
    
    init(favoritesViewModel: FavoritesListInteracting) {
        renderer = FavoritesHomeViewSectionRenderer(allowsEditing: true,
                                                    viewModel: favoritesViewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        renderer.install(into: self)
        registerForKeyboardNotifications()
        applyTheme(ThemeManager.shared.currentTheme)
        
        viewModelCancellable = renderer.viewModel.externalUpdates.sink { [weak self] _ in
            self?.collectionView.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if AppWidthObserver.shared.isLargeWidth {
            layout.minimumInteritemSpacing = 32
        } else {
            layout.minimumInteritemSpacing = 10
        }
        collectionView.reloadData()
        
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        
        collectionView.register(UINib(nibName: "FavoriteHomeCell", bundle: nil), forCellWithReuseIdentifier: "favorite")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
        
        collectionView.dropDelegate = self
        collectionView.dragDelegate = self
        collectionViewReorderingGesture.delegate = self
        collectionView.addGestureRecognizer(collectionViewReorderingGesture)

        // Size constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        var widthConstraint = collectionView.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.collectionViewMaxWidth)
        let heightConstraint = collectionView.heightAnchor.constraint(equalTo: view.heightAnchor)
        let centerXConstraint = collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        
        // Use the full-width on iPad
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
           widthConstraint = collectionView.widthAnchor.constraint(equalTo: view.widthAnchor)
        }
        NSLayoutConstraint.activate([widthConstraint, heightConstraint, centerXConstraint])
        
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
    
    @objc func collectionViewReorderingGestureHandler(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            if let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) {
                UISelectionFeedbackGenerator().selectionChanged()
                UIMenuController.shared.hideMenu()
                collectionView.beginInteractiveMovementForItem(at: indexPath)
            }
            
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            
        case .ended:
            renderer.endReordering()
            collectionView.endInteractiveMovement()
            UIImpactFeedbackGenerator().impactOccurred()

        default:
            collectionView.cancelInteractiveMovement()
        }
    }
}

extension FavoritesOverlay: FavoritesHomeViewSectionRendererDelegate {
    
    func favoritesRenderer(_ renderer: FavoritesHomeViewSectionRenderer, didSelect favorite: BookmarkEntity) {
        delegate?.favoritesOverlay(self, didSelect: favorite)
    }
    
    func favoritesRenderer(_ renderer: FavoritesHomeViewSectionRenderer, didRequestEdit favorite: BookmarkEntity) {
        delegate?.favoritesOverlay(self, didRequestEditFavorite: favorite)
    }

    func favoritesRenderer(_ renderer: FavoritesHomeViewSectionRenderer, favoriteDeleted favorite: BookmarkEntity) {}
    
}

extension FavoritesOverlay: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        renderer.collectionView(collectionView, didSelectItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 1, height: Constants.footerPadding)
    }
}

extension FavoritesOverlay: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return renderer.collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = renderer.collectionView(collectionView, cellForItemAt: indexPath)
        if let themable = cell as? Themable {
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

extension FavoritesOverlay: UICollectionViewDelegateFlowLayout {
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

extension FavoritesOverlay: UICollectionViewDropDelegate, UICollectionViewDragDelegate {
    
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

extension FavoritesOverlay: Themable {
    
    func decorate(with theme: Theme) {
        self.theme = theme
        view.backgroundColor = AppWidthObserver.shared.isLargeWidth ? .clear : theme.backgroundColor
    }
}

extension FavoritesOverlay: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        gestureRecognizer == collectionViewReorderingGesture ? gestureRecognizerShouldBegin(gestureRecognizer) : false
    }
}
