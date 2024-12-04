//
//  MainViewController+AddFavoriteFlow.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
    
    func registerForApplicationEvents() {
        
        _ = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification,
                                                   object: nil,
                                                   queue: .main) { [weak self] _ in
            DaxDialogs.shared.resumeRegularFlow()
            self?.hideMenuHighlighter()
        }
    }
    
    var canDisplayAddFavoriteVisualIndicator: Bool {
        
        guard DaxDialogs.shared.isAddFavoriteFlow,
              let tab = currentTab, !tab.isError, let url = tab.url else { return false }
        
        return !url.isDuckDuckGo
    }
    
    func hideMenuHighlighter() {
        ViewHighlighter.hideAll()
    }
    
    func showMenuHighlighterIfNeeded() {
        guard canDisplayAddFavoriteVisualIndicator, let window = view.window, presentedViewController == nil else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard self.canDisplayAddFavoriteVisualIndicator else { return }
            ViewHighlighter.hideAll()
            ViewHighlighter.showIn(window, focussedOnView: self.presentedMenuButton)
        }

    }
    
}
