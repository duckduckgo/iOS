//
//  InterfaceMeasurement.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 13/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import CoreGraphics

public struct InterfaceMeasurement {
    
    public static let defaultStatusBarHeight: CGFloat = 20

    private static let iPhone4Size = CGSize(width: 320, height: 480)
    private static let iPhone5Size = CGSize(width: 320, height: 568)
    
    private let screen: UIScreen
    
    public init(forScreen screen: UIScreen) {
        self.screen = screen
    }
    
    public var isSmallScreenDevice: Bool {
        return hasiPhone4ScreenSize || hasiPhone5ScreenSize
    }
    
    public var hasiPhone4ScreenSize: Bool {
        return isNativeScaledSize(InterfaceMeasurement.iPhone4Size)
    }
    
    public var hasiPhone5ScreenSize: Bool {
        return isNativeScaledSize(InterfaceMeasurement.iPhone5Size)
    }
    
    private func isNativeScaledSize(_ size: CGSize) -> Bool {
        let scale = screen.scale
        let scaledWidth = screen.nativeBounds.size.width / scale
        let scaledHeight = screen.nativeBounds.size.height / scale
        let scaledSize = CGSize(width: scaledWidth, height: scaledHeight)
        return scaledSize == size
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
