//
//  HomeViewController+HomeScreenDelegate.swift
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

import Foundation
import EasyTipView

extension HomeViewController: HomeScreenTipsDelegate {
    
    func showPrivateSearchTip(didShow: @escaping (Bool) -> Void) {

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self,
                !self.omniBarTextFieldHasFocus,
                let superView = self.parent?.view else {
                didShow(false)
                return
            }
            
            let view: UIView!
            if self.isCenteredSearch {
                view = self.collectionView.centeredSearch
            } else {
                view = self.chromeDelegate?.omniBar
            }
            
            guard view != nil else {
                didShow(false)
                return
            }
            
            var preferences = EasyTipView.globalPreferences
            preferences.positioning.bubbleVInset = 8

            let icon = EasyTipView.Icon(image: UIImage(named: "OnboardingIconSearchPrivately48")!, position: .left, alignment: .centerOrMiddle)
            let tip = EasyTipView(text: UserText.contextualOnboardingSearchPrivately,
                                  icon: icon,
                                  preferences: preferences)
            tip.show(animated: true, forView: view, withinSuperview: superView)

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
    
    private var isCenteredSearch: Bool {
        return HomePageConfiguration().components().contains(where: {
            if case .centeredSearch = $0 { return true }
            return false
        })
    }
    
    func showCustomizeTip(didShow: @escaping (Bool) -> Void) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self,
                !self.omniBarTextFieldHasFocus,
                let omniBar = self.chromeDelegate?.omniBar,
                let settings = omniBar.settingsButton.imageView,
                let superView = self.parent?.view else {
                didShow(false)
                return
            }

            var preferences = EasyTipView.globalPreferences
            preferences.positioning.bubbleHInset = 8
                        
            let icon = EasyTipView.Icon(image: UIImage(named: "OnboardingIconCustomize48")!, position: .left, alignment: .centerOrMiddle)
            let tip = EasyTipView(text: UserText.contextualOnboardingCustomizeTheme,
                                  icon: icon,
                                  preferences: preferences)

            tip.show(animated: true, forView: settings, withinSuperview: superView)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                tip.handleGlobalTouch {
                    didShow(true)
                }
            }
        }

    }
 
    func installHomeScreenTips() {
        HomeScreenTips(delegate: self)?.trigger()
    }
    
}
