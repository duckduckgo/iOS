//
//  SlidingAnimationCollectionViewFlowLayout.swift
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

class SlidingAnimationCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    private lazy var insertedItems = [IndexPath]()
    private lazy var deletedItems = [IndexPath]()
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)

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
                
            default: break
                
            }
            
        }
        
    }
   
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath) else { return nil }
        if deletedItems.contains(itemIndexPath) {
            applySlideProperties(to: attributes)
        }
        return attributes
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) else { return nil }
        if insertedItems.contains(itemIndexPath) {
            applySlideProperties(to: attributes)
        }
        return attributes
    }
    
    func applySlideProperties(to attributes: UICollectionViewLayoutAttributes) {
        attributes.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -attributes.frame.size.height)
        attributes.alpha = 0.0
    }
    
}
