//
//  OmniNavigationController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 05/06/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class OmniNavigationBar: UINavigationBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: InterfaceMeasurement.screenWidth, height: OmniBar.Measurement.barHeight)
    }
}
