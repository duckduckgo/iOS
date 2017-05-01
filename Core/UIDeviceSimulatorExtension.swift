//
//  UIDeviceSimulatorExtension.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 01/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

extension UIDevice {
    public var isSimulator: Bool {
        #if IOS_SIMULATOR
            return true
        #else
            return false
        #endif
    }
}
