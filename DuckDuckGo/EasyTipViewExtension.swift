//
//  EasyTipViewExtension.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 25/02/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import EasyTipView

extension EasyTipView {
    
    static func updateGlobalPreferences() {
        var preferences = EasyTipView.Preferences()
        preferences.drawing.backgroundColor = UIColor.white
        preferences.drawing.font = UIFont(name: "ProximaNova-Regular", size: 14)!
        preferences.drawing.foregroundColor = UIColor.charcoalGrey
        preferences.drawing.shadowOpacity = 0.1
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
