//
//  MainViewController+CookiesManaged.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import Core

extension MainViewController {
    
    func registerForCookiesManagedNotification() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showCookiesManagedNotification(_:)),
                                               name: .newSiteCookiesManaged,
                                               object: nil)
    }
    
    @objc private func showCookiesManagedNotification(_ notification: Notification) {
        
        guard let topURL = notification.userInfo?[AutoconsentUserScript.UserInfoKeys.topURL] as? URL,
              let isCosmetic = notification.userInfo?[AutoconsentUserScript.UserInfoKeys.isCosmetic] as? Bool,
              topURL == tabManager.current?.url
        else { return }
        
        viewCoordinator.omniBar.showOrScheduleCookiesManagedNotification(isCosmetic: isCosmetic)
    }
    
}
