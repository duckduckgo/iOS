//
//  UIViewExtension.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 21/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

extension UIView {
    
    public func insertWithEqualSize(subView: UIView) {
        insertSubview(subView, at: 0)
        addEqualWidthConstraint(subView: subView)
        addEqualHeightConstraint(subView: subView)
    }
    
    public func addEqualHeightConstraint(subView: UIView) {
        addConstraint(NSLayoutConstraint(
            item: subView,
            attribute: .height, relatedBy: .equal, toItem: self,
            attribute: .height, multiplier: 1, constant: 0))
        
    }
    
    public func addEqualWidthConstraint(subView: UIView) {
        addConstraint(NSLayoutConstraint(
            item: subView,
            attribute: .width, relatedBy: .equal, toItem: self,
            attribute: .width, multiplier: 1, constant: 0))
    }
    
}
