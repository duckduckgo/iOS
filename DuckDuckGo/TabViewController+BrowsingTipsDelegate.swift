//
//  TabViewController+BrowsingTipsDelegate.swift
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

extension TabViewController: BrowsingTipsDelegate {
    
    func showPrivacyGradeTip(didShow: @escaping (Bool) -> Void) {

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self,
                !self.omniBarTextFieldHasFocus,
                let omniBar = self.chromeDelegate?.omniBar,
                let grade = omniBar.siteRatingView,
                let superView = self.parent?.view else {
                didShow(false)
                return
            }

            self.delegate?.showBars()

            var preferences = EasyTipView.globalPreferences
            preferences.positioning.bubbleHInset = 8
            
            let icon = EasyTipView.Icon(image: UIImage(named: "OnboardingIconBlockTrackers48")!, position: .left, alignment: .centerOrMiddle)
            let tip = EasyTipView(text: UserText.contextualOnboardingPrivacyGrade,
                                  icon: icon,
                                  preferences: preferences)

            tip.show(animated: true, forView: grade, withinSuperview: superView)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                tip.handleGlobalTouch {
                    didShow(true)
                }
            }
        }

    }
    
    func showFireButtonTip(didShow: @escaping (Bool) -> Void) {

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self,
                !self.omniBarTextFieldHasFocus,
                let mainViewController = self.parent as? MainViewController,
                let button = mainViewController.fireButton,
                let superView = self.parent?.view else {
                didShow(false)
                return
            }
            
            self.delegate?.showBars()
            
            var preferences = EasyTipView.globalPreferences
            preferences.positioning.bubbleHInset = 8

            let icon = EasyTipView.Icon(image: UIImage(named: "OnboardingIconFlame48")!, position: .left, alignment: .centerOrMiddle)
            let tip = EasyTipView(text: UserText.contextualOnboardingFireButton,
                                  icon: icon,
                                  preferences: preferences)
            tip.show(forItem: button, withinSuperView: superView)            

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                tip.handleGlobalTouch {
                    didShow(true)
                }
            }
        }
    }
    
    private var omniBarTextFieldHasFocus: Bool {
        return self.chromeDelegate?.omniBar.textField.isFirstResponder ?? false
    }

}
