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
    
    @ViewBuilder var content: (_ columnsCount: Int) -> Content

    var body: some View {
        let columnsCount = NewTabPageGrid.columnsCount(for: horizontalSizeClass, isLandscape: isLandscape)

        LazyVGrid(columns: flexibleColumns(columnsCount), content: {
            content(columnsCount)
        })
        .padding(0)
        .offset(.zero)
        .clipped()
    }

    private func flexibleColumns(_ count: Int) -> [GridItem] {
        Array(repeating: GridItem(.flexible(minimum: NewTabPageGrid.Item.edgeSize), alignment: .top), count: count)
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
