//
//  EasyTipViewExtension.swift
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

import EasyTipView

extension EasyTipView {
    
    static func updateGlobalPreferences() {
        var preferences = EasyTipView.Preferences()
        
        preferences.drawing.arrowHeight = 9
        preferences.drawing.arrowWidth = 18
        preferences.drawing.arrowPosition = .any
        
        preferences.drawing.font = UIFont.semiBoldAppFont(ofSize: 16)
        preferences.drawing.foregroundColor = UIColor.nearlyBlackLight
        preferences.drawing.backgroundColor = UIColor.white

        preferences.drawing.shadowOpacity = 0.5
        preferences.drawing.shadowOffset = CGSize(width: 0, height: 0)
        preferences.drawing.shadowRadius = 3

        preferences.drawing.textAlignment = .left
        preferences.drawing.textLineHeight = 20
        
        preferences.positioning.textHInset = 16
        preferences.positioning.textVInset = 12
        preferences.positioning.iconPadding = 8
        
        preferences.positioning.maxWidth = 276
        
        preferences.animating.dismissOnTap = false
        
        EasyTipView.globalPreferences = preferences
    }
    
    func handleGlobalTouch(completion: @escaping () -> Void) {
        
        let view = TouchView()
        UIApplication.shared.keyWindow?.addSubview(view)
        
        var token: NSObjectProtocol?
        token = NotificationCenter.default.addObserver(forName: TouchView.touchNotification, object: nil, queue: nil) { _ in
            view.removeFromSuperview()
            self.dismiss()
            completion()
            NotificationCenter.default.removeObserver(token!)
            token = nil // break reference cycle
        }
    }
    
}

class TouchView: UIView {

    static let touchNotification = NSNotification.Name(rawValue: "com.duckduckgo.touchwindow.notifications.touch")
    
    // can be zero because the hit test still gets called and that's what we need
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        NotificationCenter.default.post(name: TouchView.touchNotification, object: self)
        return super.hitTest(point, with: event)
    }
    
}
