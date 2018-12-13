//
//  global.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 13/12/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit

/// Shortcut to `UIApplication.shared.statusBarOrientation.isPortrait`
///
/// Device orientation contains multiple states including unknown and flat, where as this approach is binary.
var isPortrait: Bool {
    return UIApplication.shared.statusBarOrientation.isPortrait
}
