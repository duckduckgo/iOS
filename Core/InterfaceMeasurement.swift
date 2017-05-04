//
//  InterfaceMeasurement.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 13/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public struct InterfaceMeasurement {
    
    public static let defaultStatusBarHeight: CGFloat = 20
    
    private static let iPhone4Height: CGFloat = 480
    private static let iPhone5Height: CGFloat = 568

    public static var isSmallScreenDevice: Bool {
        return hasiPhone4ScreenSize || hasiPhone5ScreenSize
    }
    
    public static var hasiPhone4ScreenSize: Bool {
        let nativeHeight = UIScreen.main.nativeBounds.size.height
        return (nativeHeight / UIScreen.main.scale) == iPhone4Height
    }
    
    public static var hasiPhone5ScreenSize: Bool {
        let nativeHeight = UIScreen.main.nativeBounds.size.height
        return (nativeHeight / UIScreen.main.scale) == iPhone5Height
    }
}

public extension UIViewController {
    
    public var statusBarSize: CGFloat {
        return prefersStatusBarHidden ? 0 : InterfaceMeasurement.defaultStatusBarHeight
    }
    
    public var navigationBarSize: CGFloat {
        guard let navBar = navigationController?.navigationBar else { return 0 }
        return navBar.isHidden ? 0 : navBar.frame.height
    }
    
    public var decorHeight: CGFloat {
        return statusBarSize + navigationBarSize
    }
}
