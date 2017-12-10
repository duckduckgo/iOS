//
//  UIDeviceExtension.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 10/12/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

extension UIDevice {

    class var isPhone : Bool {
        get {
            return UIDevice().userInterfaceIdiom == .phone
        }
    }

}
