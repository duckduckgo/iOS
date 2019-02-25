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
    
    func showPrivateSearchTip() {
        print("***", #function)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let view = self?.chromeDelegate?.omniBar.searchStackContainer else { return }
            guard let superView = self?.parent?.view else { return }
            
            let tip = EasyTipView(text: "Learn how you are kept safe and private while browsing",
                                  icon: EasyTipView.Icon(image: UIImage(named: "Home")!, position: .left, alignment: .topOrLeft))
            tip.show(animated: true, forView: view, withinSuperview: superView)
            tip.handleGlobalTouch()
        }
        
    }
    
    func showCustomizeTip() {
        print("***", #function)
        
        
    }
 
    func installHomeScreenTips() {
        HomeScreenTips(delegate: self)?.trigger()
    }
    
}
