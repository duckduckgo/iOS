//
//  NewTabPageGridView.swift
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

struct NewTabPageGridView<Content: View>: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.isLandscapeOrientation) var isLandscape

    @State private var gridWidth: CGFloat = .zero
    @ViewBuilder var content: (_ columnsCount: Int) -> Content

    var body: some View {
        let columnsCount = NewTabPageGrid.columnsCount(for: horizontalSizeClass, isLandscape: isLandscape)

        LazyVGrid(columns: flexibleColumns(columnsCount, width: gridWidth), spacing: 24, content: {
            content(columnsCount)
        })
        .frame(maxWidth: .infinity)
        .background {
            // Observing frame directly on grid didn't work for some reason, resulting in `.zero` frame.
            Color.clear
                .onFrameUpdate(in: .local, using: FramePreferenceKey.self) { rect in
                    // Width needs to be reset, otherwise grid will grow forever with each size change (like rotation)
                    let newGridWidth = rect.width
                    if newGridWidth > gridWidth {
                        gridWidth = 0
                        Task { @MainActor in
                            gridWidth = rect.width
                            print("grid width: \(rect.width)")
                        }
                    }
                }
        }
    }

    private func flexibleColumns(_ count: Int, width: CGFloat) -> [GridItem] {
        let spacing: CGFloat?
        if width != .zero {
            let columnsWidth = NewTabPageGrid.Item.edgeSize * Double(count)
            let spacingsCount = count - 1
            // Calculate exact spacing so that there's no leading and trailing padding.
            spacing = max((width - columnsWidth) / Double(spacingsCount), 0)
        } else {
            spacing = nil
        }

        return Array(repeating: GridItem(.flexible(minimum: NewTabPageGrid.Item.edgeSize),
                                         spacing: spacing,
                                         alignment: .top),
                     count: count)
    }
}

private struct FramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

enum NewTabPageGrid {
    enum ColumnCount {
        static let compact = 4
        static let regular = 6
    }

    enum Item {
        static let edgeSize = 64.0
    }

    static func columnsCount(for sizeClass: UserInterfaceSizeClass?, isLandscape: Bool) -> Int {
        let usesWideLayout = isLandscape || sizeClass == .regular
        return usesWideLayout ? ColumnCount.regular : ColumnCount.compact
    }
}
