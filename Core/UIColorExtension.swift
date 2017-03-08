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
    
    public static var onboardingRealPrivacyBackground: UIColor {
        return lightOliveGreen
    }
    
    public static var onboardingContentBlockingBackground: UIColor {
        return amethyst
    }
    
    public static var onboardingTrackingBackground: UIColor {
        return fadedOrange
    }
    
    public static var onboardingPrivacyRightBackground: UIColor {
        return softBlue
    }
    
    private static var orange: UIColor {
        return UIColor(red:0.85, green:0.36, blue:0.25, alpha:1.0)
    }
    
    private static var fadedOrange: UIColor {
        return UIColor(red: 245.0 / 255.0, green: 139.0 / 255.0, blue: 107.0 / 255.0, alpha: 1.0)
    }
    
    private static var lightOliveGreen: UIColor {
        return UIColor(red: 147.0 / 255.0, green: 192.0 / 255.0, blue: 77.0 / 255.0, alpha: 1.0)
    }
    
    private static var amethyst: UIColor {
        return UIColor(red: 156.0 / 255.0, green: 108.0 / 255.0, blue: 211.0 / 255.0, alpha: 1.0)
    }
    
    private static var softBlue: UIColor {
        return UIColor(red: 106.0 / 255.0, green: 187.0 / 255.0, blue: 224.0 / 255.0, alpha: 1.0)
    }
}
