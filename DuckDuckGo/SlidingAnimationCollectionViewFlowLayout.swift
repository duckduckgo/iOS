//
//  SlidingAnimationCollectionViewFlowLayout.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 22/11/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit

class SlidingAnimationCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    private lazy var insertedItems = [IndexPath]()
    private lazy var deletedItems = [IndexPath]()
    
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
        super.prepare(forCollectionViewUpdates: updateItems)
        print("***", #function, updateItems)
        
        insertedItems.removeAll()
        deletedItems.removeAll()
        
        updateItems.forEach { item in
            
            switch item.updateAction {
            case .delete:
                if let path = item.indexPathBeforeUpdate {
                    deletedItems.append(path)
                }
                
            case .insert:
                if let path = item.indexPathAfterUpdate {
                    insertedItems.append(path)
                }
                
            default:
                print("no-op")
            }
            
        }
        
    }
   
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print("***", #function, itemIndexPath)
        guard let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath) else { return nil }
        if deletedItems.contains(itemIndexPath) {
            attributes.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -attributes.frame.size.height)
            attributes.alpha = 0.0
        }
        return attributes
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) else { return nil }
        print("***", #function, itemIndexPath, attributes)
        
        if insertedItems.contains(itemIndexPath) {
            attributes.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -attributes.frame.size.height)
            attributes.alpha = 0.0
        }
        
        return attributes
    }
    
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        print("***", #function)
    }
    
}
