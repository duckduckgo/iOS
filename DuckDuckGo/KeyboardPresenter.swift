//
//  KeyboardPresenter.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

@MainActor
protocol KeyboardPresenting {

    func showKeyboardOnLaunch(lastBackgroundDate: Date?)

}

final class KeyboardPresenter: KeyboardPresenting {

    private static let showKeyboardOnLaunchThreshold = TimeInterval(20)
    private let mainViewController: MainViewController

    init(mainViewController: MainViewController) {
        self.mainViewController = mainViewController
    }

    func showKeyboardOnLaunch(lastBackgroundDate: Date? = nil) {
        guard KeyboardSettings().onAppLaunch && shouldShowKeyboardOnLaunch(lastBackgroundDate: lastBackgroundDate) else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.mainViewController.enterSearch()
        }
    }

    private func shouldShowKeyboardOnLaunch(lastBackgroundDate: Date? = nil) -> Bool {
        guard let lastBackgroundDate else { return true }
        return Date().timeIntervalSince(lastBackgroundDate) > Self.showKeyboardOnLaunchThreshold
    }

}
