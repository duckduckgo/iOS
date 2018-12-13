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
        let paddingHeight = collectionView.frame.size.height - FavoriteHomeCell.Constants.height - spaceUsedByFavorites
        
        return CGSize(width: 1, height: max(0, paddingHeight))
    }
    
}
