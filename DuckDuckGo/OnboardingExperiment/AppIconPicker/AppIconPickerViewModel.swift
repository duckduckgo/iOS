//
//  AppIconPickerViewModel.swift
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

import Foundation

@MainActor
final class AppIconPickerViewModel: ObservableObject {

    struct DisplayModel {
        let icon: AppIcon
        let isSelected: Bool
    }

    @Published private(set) var items: [DisplayModel] = []

    private let appIconManager: AppIconManaging

    init(appIconManager: AppIconManaging = AppIconManager.shared) {
        self.appIconManager = appIconManager
        items = makeDisplayModels()
    }

    func changeApp(icon: AppIcon) {
        appIconManager.changeAppIcon(icon) { [weak self] error in
            guard let self, error == nil else { return }
            items = makeDisplayModels()
        }
    }

    private func makeDisplayModels() -> [DisplayModel] {
        AppIcon.allCases.map { appIcon in
            DisplayModel(icon: appIcon, isSelected: appIconManager.appIcon == appIcon)
        }
    }
}

protocol AppIconProviding {
    var appIcon: AppIcon { get }
}

protocol AppIconManaging: AppIconProviding {
    func changeAppIcon(_ appIcon: AppIcon, completionHandler: ((Error?) -> Void)?)
}

extension AppIconManaging {
    func changeAppIcon(_ appIcon: AppIcon) {
        changeAppIcon(appIcon, completionHandler: nil)
    }
}

extension AppIconManager: AppIconManaging {}
