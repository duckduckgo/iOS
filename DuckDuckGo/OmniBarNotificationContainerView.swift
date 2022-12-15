//
//  OmniBarNotificationContainerView.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

import Foundation
import UIKit
import SwiftUI

protocol OmniBarNotificationAnimated: UIViewController {
    func startAnimation(_ completion: @escaping () -> Void)
}

final class OmniBarNotificationContainerView: UIView {
    
    enum AnimationType {
        case cookiesManaged
    }
    
    var currentNotificationController: UIHostingController<OmniBarNotification>?
    
    func prepareAnimation(_ type: AnimationType) {
        removeOldNotificationView()

        let model = makeNotificationModel(for: type)
        let notificationViewController = UIHostingController(rootView: OmniBarNotification(model: model),
                                                ignoreSafeArea: true)
                
        #warning("pass the VC here")
        window?.rootViewController?.addChild(notificationViewController)
        
        addSubview(notificationViewController.view)
        currentNotificationController = notificationViewController
        setupConstraints()
    }
    
    func startAnimation(completion: @escaping () -> Void) {
        currentNotificationController?.rootView.model.showNotification(completion: completion)
    }
    
    private func removeOldNotificationView() {
        guard let notificationView = currentNotificationController?.view else { return }
        
        notificationView.removeFromSuperview()
    }
    
    private func setupConstraints() {
        guard let notificationView = currentNotificationController?.view else { return }

        notificationView.backgroundColor = .clear
        notificationView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            notificationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            notificationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            notificationView.bottomAnchor.constraint(equalTo: bottomAnchor),
            notificationView.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
    private func makeNotificationModel(for type: AnimationType) -> OmniBarNotificationModel {
        let isLightTheme = ThemeManager.shared.currentTheme.currentImageSet == .light
        let notificationText: String
        let notificationAnimationName: String
        switch type {
        case .cookiesManaged:
            #warning("get the text from UserText and animation based on theme")
            notificationText = "Cookies managed"
            notificationAnimationName = isLightTheme ? "cookie-icon-animated-40-light" : "cookie-icon-animated-40-light"
        }
        
        return OmniBarNotificationModel(text: notificationText, animationName: notificationAnimationName)
    }
    
}
