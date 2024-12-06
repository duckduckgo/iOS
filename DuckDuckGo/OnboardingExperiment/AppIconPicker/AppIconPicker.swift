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
    @StateObject private var viewModel = AppIconPickerViewModel()

    let layout = [GridItem(.adaptive(minimum: Metrics.iconSize), spacing: Metrics.spacing, alignment: .leading)]
    
    var body: some View {
        LazyVGrid(columns: layout, spacing: Metrics.spacing) {
            ForEach(viewModel.items, id: \.icon) { item in
                Image(uiImage: item.icon.mediumImage ?? UIImage())
                    .resizable()
                    .frame(width: Metrics.iconSize, height: Metrics.iconSize)
                    .cornerRadius(Metrics.cornerRadius)
                    .overlay {
                        strokeOverlay(isSelected: item.isSelected)
                    }
                    .onTapGesture {
                        viewModel.changeApp(icon: item.icon)
                    }
            }
        }
    }

    @ViewBuilder
    private func strokeOverlay(isSelected: Bool) -> some View {
        if isSelected {
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

#Preview {
    AppIconPicker()
}
