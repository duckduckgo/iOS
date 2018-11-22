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
    
    override func finalizeAnimatedBoundsChange() {
        super.finalizeAnimatedBoundsChange()
        print("***", #function)
    }
    
    override func prepare() {
        super.prepare()
        print("***", #function)
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        print("***", #function, updateItems)

        var unprocessedItems = [UICollectionViewUpdateItem]()
        
        updateItems.forEach { item in
            
            switch item.updateAction {
                
            case .delete:
                deleteItem(item)
                
            default:
                print("*** unknown updateAction", item)
                unprocessedItems.append(item)
            }
            
        }
        
        if !unprocessedItems.isEmpty {
            super.prepare(forCollectionViewUpdates: unprocessedItems)
        }
        
    }
    
    private func deleteItem(_ item: UICollectionViewUpdateItem) {
        guard let path = item.indexPathBeforeUpdate else { return }
        guard let view = collectionView?.cellForItem(at: path) else { return }
        UIView.animate(withDuration: 0.3) {
            view.frame.origin.y = -view.frame.size.height
        }
    }
    
}
