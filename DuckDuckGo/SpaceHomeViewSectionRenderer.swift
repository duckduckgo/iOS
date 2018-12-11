//
//  SpaceHomeViewSectionRenderer.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 11/12/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit

class SpaceHomeViewSectionRenderer: HomeViewSectionRenderer {
    
    private let height: CGFloat
    
    init(height: CGFloat) {
        self.height = height
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
        return CGSize(width: 1, height: height)
    }
    
}
