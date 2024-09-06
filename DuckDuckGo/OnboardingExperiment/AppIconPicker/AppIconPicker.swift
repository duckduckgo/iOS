//
//  AppIconPicker.swift
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
import DuckUI

private enum Metrics {
    static let cornerRadius: CGFloat = 13.0
    static let iconSize: CGFloat = 56.0
    static let spacing: CGFloat = 16.0
    static let strokeFrameSize: CGFloat = 60
    static let strokeWidth: CGFloat = 3
    static let strokeInset: CGFloat = 1.5
}

struct AppIconPicker: View {
    @Environment(\.colorScheme) private var color

    @StateObject private var viewModel = AppIconPickerViewModel()

    let layout = [GridItem(.adaptive(minimum: Metrics.iconSize, maximum: Metrics.iconSize), spacing: Metrics.spacing)]
    
    var body: some View {
        LazyVGrid(columns: layout, spacing: Metrics.spacing) {
            ForEach(viewModel.items, id: \.self) { item in
                Image(uiImage: item.mediumImage ?? UIImage())
                    .resizable()
                    .frame(width: Metrics.iconSize, height: Metrics.iconSize)
                    .cornerRadius(Metrics.cornerRadius)
                    .overlay {
                        strokeOverlay(for: item)
                    }
                    .onTapGesture {
                        viewModel.changeApp(icon: item)
                    }
            }
        }
    }

    @ViewBuilder
    private func strokeOverlay(for item: AppIcon) -> some View {
        if viewModel.selectedAppIcon == item {
            RoundedRectangle(cornerRadius: Metrics.cornerRadius)
                .foregroundColor(.clear)
                .frame(width: Metrics.strokeFrameSize, height: Metrics.strokeFrameSize)
                .overlay(
                    RoundedRectangle(cornerRadius: Metrics.cornerRadius)
                        .inset(by: -Metrics.strokeInset)
                        .stroke(.blue, lineWidth: Metrics.strokeWidth)
                )
        }
    }

}

@MainActor
final class AppIconPickerViewModel: ObservableObject {
    let items = AppIcon.allCases

    @Published private(set) var selectedAppIcon: AppIcon

    private let appIconManager: AppIconManaging

    init(appIconManager: AppIconManaging = AppIconManager.shared) {
        self.appIconManager = appIconManager
        selectedAppIcon = appIconManager.appIcon
    }

    func changeApp(icon: AppIcon) {
        appIconManager.changeAppIcon(icon) { [weak self] error in
            guard let self, error == nil else { return }

            self.selectedAppIcon = self.appIconManager.appIcon
        }
    }
}

protocol AppIconManaging {
    var appIcon: AppIcon { get }
    func changeAppIcon(_ appIcon: AppIcon, completionHandler: ((Error?) -> Void)?)
}

extension AppIconManaging {
    func changeAppIcon(_ appIcon: AppIcon) {
        changeAppIcon(appIcon, completionHandler: nil)
    }
}

extension AppIconManager: AppIconManaging {}

#Preview {
    AppIconPicker()
}
