//
//  TouchWindow.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
