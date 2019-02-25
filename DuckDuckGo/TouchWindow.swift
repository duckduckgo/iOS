//
//  TouchWindow.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 25/02/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import UIKit

class TouchWindow: UIWindow {

    static let touchNotification = NSNotification.Name(rawValue: "com.duckduckgo.touchwindow.notifications.touch")
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        NotificationCenter.default.post(name: TouchWindow.touchNotification, object: self)
        return super.hitTest(point, with: event)
    }
    
}
