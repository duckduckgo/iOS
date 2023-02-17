//
//  OmniBarNotificationAnimator.swift
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

import UIKit

enum OmniBarNotificationType {
    case cookiePopupManaged
    case cookiePopupHidden
}

final class OmniBarNotificationAnimator: NSObject {
    
    func showNotification(_ type: OmniBarNotificationType, in omniBar: OmniBar) {
        
        omniBar.notificationContainer.alpha = 0
        omniBar.notificationContainer.prepareAnimation(type)
        omniBar.textField.alpha = 0
        
        let fadeDuration = Constants.Duration.fade
        let animationStartOffset = 2 * fadeDuration
        
        UIView.animate(withDuration: fadeDuration) {
            omniBar.privacyInfoContainer.alpha = 0
        }
        
        UIView.animate(withDuration: fadeDuration, delay: fadeDuration) {
            omniBar.notificationContainer.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationStartOffset) {
            
            omniBar.notificationContainer.startAnimation {
                UIView.animate(withDuration: fadeDuration) {
                    omniBar.notificationContainer.alpha = 0
                }
                
                UIView.animate(withDuration: fadeDuration, delay: fadeDuration) {
                    omniBar.textField.alpha = 1
                    omniBar.privacyInfoContainer.alpha = 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2 * fadeDuration) {
                    omniBar.notificationContainer.removePreviousNotification()
                }
            }
        }
    }
    
    func cancelAnimations(in omniBar: OmniBar) {
        omniBar.privacyInfoContainer.alpha = 0
        omniBar.notificationContainer.removePreviousNotification()
        omniBar.textField.alpha = 1
        omniBar.privacyInfoContainer.alpha = 1
    }
}

private enum Constants {
    enum Duration {
        static let fade: TimeInterval = 0.25
    }
}
