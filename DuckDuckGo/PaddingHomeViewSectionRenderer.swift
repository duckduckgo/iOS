//
//  PaddingHomeViewSectionRenderer.swift
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

class PaddingHomeViewSectionRenderer: HomeViewSectionRenderer {

    lazy var bookmarksManager = BookmarksManager()

    var paddingHeight: CGFloat = 0
    var controller: HomeViewController?

    let cellHeight: CGFloat
    
    var isPad: Bool {
        return controller?.traitCollection.horizontalSizeClass == .regular
    }

    init() {
        guard let cell = (UINib(nibName: "FavoriteHomeCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView) else {
            fatalError("Failed to load FavoriteHomeCell")
        }
        cellHeight = cell.frame.size.height
    }

    func install(into controller: HomeViewController) {

        self.controller = controller

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "space", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let maxFavoritesPerRow = isPad ? 5 : 4
        let itemsPerRow = collectionView.frame.width > 320 ? maxFavoritesPerRow : 3
        let rows = ceil(CGFloat(bookmarksManager.favoritesCount) / CGFloat(itemsPerRow))
        let spaceUsedByCells = (rows * cellHeight)
        let spaceUsedByLineSpacing = (rows - 2) * 10
        let spaceUsedByFavorites = spaceUsedByCells + spaceUsedByLineSpacing

        paddingHeight = collectionView.frame.size.height - cellHeight - spaceUsedByFavorites

        return CGSize(width: 1, height: max(0, paddingHeight))
    }

    @objc func onKeyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = value.cgRectValue.height
        guard keyboardHeight > paddingHeight else { return }
        let height = keyboardHeight - 50 // roughly the navigation bar
        controller?.collectionView.contentInset = UIEdgeInsets(top: HomeCollectionView.Constants.topInset, left: 0, bottom: height, right: 0)
    }

    @objc func onKeyboardWillHide(notification: Notification) {
        controller?.collectionView.contentInset = UIEdgeInsets(top: HomeCollectionView.Constants.topInset, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize? {
        return CGSize(width: 1, height: 20)
    }

}
