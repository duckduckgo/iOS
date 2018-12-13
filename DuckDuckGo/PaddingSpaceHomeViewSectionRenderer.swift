//
//  PaddingSpaceHomeViewSectionRenderer.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 12/12/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit

class PaddingSpaceHomeViewSectionRenderer: HomeViewSectionRenderer {
    
    lazy var bookmarksManager = BookmarksManager()
    
    var paddingHeight: CGFloat = 0
    var controller: HomeViewController!
    
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

        let itemsPerRow = collectionView.frame.width > 320 ? 4 : 3
        let rows = CGFloat((bookmarksManager.favoritesCount / itemsPerRow) + 1)
        let spaceUsedByCells = (rows * FavoriteHomeCell.Constants.height)
        let spaceUsedByLineSpacing = (rows - 2) * 10
        let spaceUsedByFavorites = spaceUsedByCells + spaceUsedByLineSpacing
        paddingHeight = collectionView.frame.size.height - FavoriteHomeCell.Constants.height - spaceUsedByFavorites
        
        return CGSize(width: 1, height: max(0, paddingHeight))
    }
    
    @objc func onKeyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = value.cgRectValue.height
        guard keyboardHeight > paddingHeight else { return }
        let height = keyboardHeight - 50 // roughly the navigation bar
        controller.collectionView.contentInset = UIEdgeInsets(top: HomeCollectionView.Constants.topInset, left: 0, bottom: height, right: 0)
    }
    
    @objc func onKeyboardWillHide(notification: Notification) {
        controller.collectionView.contentInset = UIEdgeInsets(top: HomeCollectionView.Constants.topInset, left: 0, bottom: 0, right: 0)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
