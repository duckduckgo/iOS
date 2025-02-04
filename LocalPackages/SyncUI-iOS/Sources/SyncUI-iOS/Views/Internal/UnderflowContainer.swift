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

    let container = CoordinateSpace.named("container")
    let backgroundContent: () -> BackgroundContent
    let foregroundContent: () -> ForegroundContent

    func calcIsUnderflowing() -> Bool {
        guard contentSize != .zero && buttonsSize != .zero && foregroundContainerSize != .zero else {
            return false
        }
        return buttonsSize.height + contentSize.height > foregroundContainerSize.height
    }

    @State var isUnderflowing = false
    @State var contentSize: CGSize = .zero {
        didSet {
            isUnderflowing = calcIsUnderflowing()
        }
    }
    @State var buttonsSize: CGSize = .zero {
        didSet {
            isUnderflowing = calcIsUnderflowing()
        }
    }
    @State var foregroundContainerSize: CGSize = .zero {
        didSet {
            isUnderflowing = calcIsUnderflowing()
        }
    }

    @ViewBuilder
    func advancedView() -> some View {
        let foreground = foregroundContent()

        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    backgroundContent()
                        .background(ViewGeometry().onPreferenceChange(ViewSizeKey.self) {
                            contentSize = $0
                        })

                    // This is hidden so that we get the height we need to test for underscroll
                    foreground
                        .padding(.top, 8)
                        .hidden()
                }
            }

            VStack(spacing: 0) {
                Spacer()
                foreground
                    .padding(.top, 4)
                    .frame(maxWidth: .infinity)
                    .applyViewModifier(ThinMaterialBackgroundModifier(), if: isUnderflowing)
                    .background(ViewGeometry().onPreferenceChange(ViewSizeKey.self) {
                        buttonsSize = $0
                    })
            }
            .background(ViewGeometry().onPreferenceChange(ViewSizeKey.self) {
                foregroundContainerSize = $0
            })

        }
    }

    func simpleView() -> some View {
        ScrollView {
            VStack {
                backgroundContent()
                Spacer()
                foregroundContent()
            }
        }
    }

    var body: some View {
        if #available(iOS 16, *) {
            advancedView()
        } else {
            simpleView()
        }
    }

}

private struct ViewGeometry: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: ViewSizeKey.self, value: geometry.size)
        }
    }
}

private struct ViewSizeKey: PreferenceKey {
    
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }

}

private struct ThinMaterialBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.thinMaterialBackground()
    }
}
