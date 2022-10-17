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

class FavoritesViewController: UIViewController {

    @IBOutlet weak var emptyHeroView: UIView!

    struct Constants {
        static let margin: CGFloat = 12
        static let footerPadding: CGFloat = 50
    }

    private let layout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView!
    private var renderer: FavoritesHomeViewSectionRenderer!

    private var theme: Theme!

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)

        collectionView.register(UINib(nibName: "FavoriteHomeCell", bundle: nil), forCellWithReuseIdentifier: "favorite")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear

        view.addSubview(collectionView)

        renderer = FavoritesHomeViewSectionRenderer(allowsEditing: true)
        renderer.install(into: self)

        registerForKeyboardNotifications()

        applyTheme(ThemeManager.shared.currentTheme)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateHeroImage()
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
        emptyHeroView.isHidden = renderer.bookmarksManager.favoritesCount > 0
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

    func favoritesRenderer(_ renderer: FavoritesHomeViewSectionRenderer, didSelect favorite: Bookmark) {
        print("***", #function)
    }

    func favoritesRenderer(_ renderer: FavoritesHomeViewSectionRenderer, didRequestEdit favorite: Bookmark) {
        print("***", #function)
    }

    func favoritesRenderer(_ renderer: FavoritesHomeViewSectionRenderer, favoriteDeleted favorite: Bookmark) {
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

extension FavoritesViewController: UICollectionViewDataSource {

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
        view.backgroundColor = .clear
    }
}
