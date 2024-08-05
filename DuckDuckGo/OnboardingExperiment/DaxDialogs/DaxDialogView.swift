//
//  DaxDialogView.swift
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
import DesignResourcesKit

// MARK: - Metrics

private enum Metrics {
    static let contentPadding: CGFloat = 24.0
    static let shadowRadius: CGFloat = 5.0
    static let stackSpacing: CGFloat = 8

    enum DaxLogo {
        static let size: CGFloat = 54.0
        static let horizontalPadding: CGFloat = 10
    }
}

// MARK: - DaxDialog

enum DaxDialogLogoPosition {
    case top
    case left
}

struct DaxDialogView<Content: View>: View {

    @Environment(\.colorScheme) var colorScheme

    @State private var logoPosition: DaxDialogLogoPosition

    private let matchLogoAnimation: (id: String, namespace: Namespace.ID)?
    private let showDialogBox: Binding<Bool>
    private let cornerRadius: CGFloat
    private let arrowSize: CGSize
    private let onTapGesture: (() -> Void)?
    private let content: Content

    init(
        logoPosition: DaxDialogLogoPosition,
        matchLogoAnimation: (String, Namespace.ID)? = nil,
        showDialogBox: Binding<Bool> = .constant(true),
        cornerRadius: CGFloat = 16.0,
        arrowSize: CGSize = .init(width: 16.0, height: 8.0),
        onTapGesture: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        _logoPosition = State(initialValue: logoPosition)
        self.matchLogoAnimation = matchLogoAnimation
        self.showDialogBox = showDialogBox
        self.cornerRadius = cornerRadius
        self.arrowSize = arrowSize
        self.onTapGesture = onTapGesture
        self.content = content()
    }

    var body: some View {
        Group {
            switch logoPosition {
            case .top:
                topLogoViewContentView
            case .left:
                leftLogoContentView
            }
        }
        .onTapGesture {
            onTapGesture?()
        }
    }

    private var topLogoViewContentView: some View {
        VStack(alignment: .leading, spacing: stackSpacing) {
            daxLogo
                .padding(.leading, Metrics.DaxLogo.horizontalPadding)

            wrappedContent
                .visibility(showDialogBox.wrappedValue ? .visible : .invisible)
        }
    }

    private var leftLogoContentView: some View {
        HStack(alignment: .top, spacing: stackSpacing) {
            daxLogo

            wrappedContent
                .visibility(showDialogBox.wrappedValue ? .visible : .invisible)
        }

    }

    private var stackSpacing: CGFloat {
        Metrics.stackSpacing + arrowSize.height
    }

    @ViewBuilder
    private var daxLogo: some View {
        let icon = Image(.daxIconExperiment)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: Metrics.DaxLogo.size, height: Metrics.DaxLogo.size)

        if let matchLogoAnimation {
            icon.matchedGeometryEffect(id: matchLogoAnimation.id, in: matchLogoAnimation.namespace)
        } else {
            icon
        }
    }

    private var wrappedContent: some View {
        let backgroundColor = Color(designSystemColor: .surface)
        let shadowColors: (Color, Color) = colorScheme == .light ?
        (.black.opacity(0.08), .black.opacity(0.1)) :
        (.black.opacity(0.20), .black.opacity(0.16))

        return content
            .padding(.all, Metrics.contentPadding)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: shadowColors.0, radius: 16, x: 0, y: 8)
            .shadow(color: shadowColors.1, radius: 6, x: 0, y: 2)
            .overlay(
                Triangle()
                    .frame(width: arrowSize.width, height: arrowSize.height)
                    .foregroundColor(backgroundColor)
                    .rotationEffect(Angle(degrees: logoPosition == .top ? 0 : -90), anchor: .bottom)
                    .offset(arrowOffset)
                ,
                alignment: .topLeading
            )
    }

    private var arrowOffset: CGSize {
        switch logoPosition {
        case .top:
            let leadingOffset = Metrics.DaxLogo.horizontalPadding + Metrics.DaxLogo.size / 2 - arrowSize.width / 2
            return CGSize(width: leadingOffset, height: -arrowSize.height)
        case .left:
            let topOffset = Metrics.DaxLogo.size / 2 - arrowSize.width / 2
            return CGSize(width: -arrowSize.height, height: topOffset)
        }
    }
}

// MARK: - Preview

#Preview("Dax Dialog Top Logo") {
    ZStack {
        Color.green.ignoresSafeArea()

        DaxDialogView(logoPosition: .top) {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 20) {
                    Text(verbatim: "Hi there.")

                    Text(verbatim: "Ready for a better, more private internet?")
                }
            }
        }
        .padding()
    }
}

#Preview("Dax Dialog Left Logo") {
    ZStack {
        Color.green.ignoresSafeArea()

        DaxDialogView(logoPosition: .left) {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 20) {
                    Text(verbatim: "Hi there.")

                    Text(verbatim: "Ready for a better, more private internet?")
                }
            }
        }
        .padding()
    }
}
