//
//  UIColorExtension.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 13/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

extension UIColor {
    public static var accent: UIColor {
        return UIColor.orange
    }
    
    public static var primary: UIColor {
        return UIColor.black
    }
    
    public static var background: UIColor {
        return greyBackground
    }
    
    public static var tint: UIColor {
        return UIColor.black
    }
    
    public static var greyBackground: UIColor {
        return UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
    }
    
    private static var orange: UIColor {
        return UIColor(red:0.85, green:0.36, blue:0.25, alpha:1.0)
    }
}
