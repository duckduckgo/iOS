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
        preferences.drawing.arrowPosition = .any
        preferences.drawing.backgroundColor = UIColor.white
        preferences.drawing.font = UIFont(name: "ProximaNova-Regular", size: 14)!
        preferences.drawing.foregroundColor = UIColor.charcoalGrey
        preferences.drawing.shadowOpacity = 0.3
        preferences.drawing.shadowOffset = CGSize(width: 0, height: 1)
        preferences.drawing.textAlignment = .left
        preferences.drawing.textLineHeight = 22
        preferences.animating.dismissOnTap = false
        EasyTipView.globalPreferences = preferences
    }
    
    func handleGlobalTouch() {
        var token: NSObjectProtocol?
        token = NotificationCenter.default.addObserver(forName: TouchWindow.touchNotification, object: nil, queue: nil) { _ in
            self.dismiss()
            NotificationCenter.default.removeObserver(token!)
        }
    }
    
}
