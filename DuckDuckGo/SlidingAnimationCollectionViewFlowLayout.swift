//
//  SlidingAnimationCollectionViewFlowLayout.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 22/11/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit

class SlidingAnimationCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        print("***", #function)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("***", #function)
    }
    
    override func prepare(forAnimatedBoundsChange oldBounds: CGRect) {
        super.prepare(forAnimatedBoundsChange: oldBounds)
        print("***", #function, oldBounds)
    }
    
    override func prepare() {
        super.prepare()
        print("***", #function)
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        print("***", #function, updateItems)
    }
    
    override func finalizeAnimatedBoundsChange() {
        super.finalizeAnimatedBoundsChange()
        print("***", #function)
    }
    
}
