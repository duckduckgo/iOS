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
    
    func showPrivacyGradeTip() {
        print("***", #function)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let omniBar = self?.chromeDelegate?.omniBar else { return }
            guard let grade = omniBar.siteRatingView else { return }
            guard let superView = self?.parent?.view else { return }

            let icon = EasyTipView.Icon(image: UIImage(named: "OnboardingIconBlockTrackers")!, position: .left, alignment: .topOrLeft)
            let tip = EasyTipView(text: "You're browsing with tracker protection and smarter encryption enabled by default.",
                                  icon: icon)

            tip.show(animated: true, forView: grade, withinSuperview: superView)
            tip.handleGlobalTouch()
        }

    }
    
    func showFireButtonTip() {
        print("***", #function)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let mainViewController = self?.parent as? MainViewController else { return }
            guard let button = mainViewController.fireButton else { return }
            guard let superView = self?.parent?.view else { return }

            var prefs = EasyTipView.globalPreferences
            prefs.positioning.hOffset = 2
            
            let icon = EasyTipView.Icon(image: UIImage(named: "OnboardingIconFlame")!, position: .left, alignment: .topOrLeft)
            let tip = EasyTipView(text: "Tap the Fire Button to erase your tabs and browsing data.",
                                  icon: icon,
                                  preferences: prefs)
            tip.show(forItem: button, withinSuperView: superView)
            tip.handleGlobalTouch()
        }
    }
        
}
