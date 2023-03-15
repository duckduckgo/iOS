//
//  UnderflowContainer.swift
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

import SwiftUI

struct UnderflowContainer<BackgroundContent: View, ForegroundContent: View>: View {

    let space = CoordinateSpace.named("overContent")

    @Environment(\.verticalSizeClass) var verticalSizeClass

    var isCompact: Bool {
        verticalSizeClass == .compact
    }

    @State var minHeight = 0.0 {
        didSet {
            print("***", minHeight)
        }
    }

    let background: () -> BackgroundContent
    let foreground: () -> ForegroundContent

    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    background()
                    Spacer()
                    ZStack {
                        EmptyView()
                    }
                    .frame(minHeight: minHeight)
                }
            }

            VStack {
                Spacer()
                foreground()
                    .modifier(SizeModifier())
                    .padding(.top, isCompact ? 8 : 0)
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(.container)
                    .applyUnderflowBackgroundOnPhone(isCompact: isCompact)
            }
        }
        .onPreferenceChange(SizePreferenceKey.self) { self.minHeight = $0.height + 8 }
    }

}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        print(#function, value)
        if value.height == 0 || value.width == 0 {
            value = nextValue()
        }
    }
}

struct SizeModifier: ViewModifier {
    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
        }
    }

    func body(content: Content) -> some View {
        content.background(sizeView)
    }
}
