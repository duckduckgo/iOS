//
//  NewTabPageViewController.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

import SwiftUI

final class NewTabPageViewController: UIHostingController<NewTabPageView>, NewTabPage {

    init() {
        let newTabPageView = NewTabPageView(messagesModel: NewTabPageMessagesModel(),
                                            favoritesModel: FavoritesModel())
        super.init(rootView: newTabPageView)
    }
    
    @available(*, unavailable)
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let isDragging: Bool = false

    weak var chromeDelegate: BrowserChromeDelegate?
    weak var delegate: HomeControllerDelegate?

    func launchNewSearch() {

    }

    func openedAsNewTab(allowingKeyboard: Bool) {

    }

    func omniBarCancelPressed() {

    }

    func dismiss() {

    }

    func showNextDaxDialog() {

    }

    func onboardingCompleted() {

    }

    func reloadFavorites() {

    }
}
