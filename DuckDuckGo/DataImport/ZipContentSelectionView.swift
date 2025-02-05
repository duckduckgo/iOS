//
//  ZipContentSelectionView.swift
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

import SwiftUI
import DesignResourcesKit
import DuckUI
import Core

struct ZipContentSelectionView: View {

    @State var frame: CGSize = .zero
    @ObservedObject var viewModel: ZipContentSelectionViewModel

    var body: some View {
        GeometryReader { geometry in
            makeBodyView(geometry)
        }
    }

    private func makeBodyView(_ geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async { self.frame = geometry.size }

        return ZStack {
            CancelButtonHeader(action: viewModel.closeButtonPressed)
                .offset(x: 16, y: 16)
                .zIndex(1)

            HStack {
                VStack(spacing: 0) {
                    Title()

                    DataTypesContainer(viewModel: viewModel)

                    ContinueButton(viewModel: viewModel)
                }
                .padding(.horizontal)
                .background(GeometryReader { proxy -> Color in
                    DispatchQueue.main.async { viewModel.contentHeight = proxy.size.height }
                    return Color.clear
                })
                .useScrollView(shouldUseScrollView(), minHeight: frame.height)
            }
            .frame(maxWidth: Const.Size.maxWidth)
        }
        .background(Color(designSystemColor: .backgroundSheets))
        .ignoresSafeArea()
    }

    private func shouldUseScrollView() -> Bool {
        var useScrollView: Bool = false

        if #available(iOS 16.0, *) {
            useScrollView = AutofillViews.contentHeightExceedsScreenHeight(viewModel.contentHeight)
        } else {
            useScrollView = viewModel.contentHeight > frame.height + Const.Size.ios15scrollOffset
        }

        return useScrollView
    }
}

private struct CancelButtonHeader: View {
    let action: () -> Void

    var body: some View {
        VStack {
            HStack {
                Button {
                    action()
                } label: {
                    Text(UserText.actionCancel)
                        .daxBodyRegular()
                        .foregroundColor(Color(designSystemColor: .textPrimary))

                }

                Spacer()
            }
            Spacer()
        }
    }
}

private struct Title: View {
    var body: some View {
        Text(UserText.zipContentSelectionTitle)
            .daxTitle1()
            .foregroundColor(Color(designSystemColor: .textPrimary))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 56)
            .padding(.bottom, 24)
    }
}

private struct DataTypesContainer: View {
    @ObservedObject var viewModel: ZipContentSelectionViewModel
    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.importPreview, id: \.self) { importPreview in
                DataTypeRow(viewModel: viewModel, importPreview: importPreview)
            }
        }
        .background(Color(designSystemColor: .panel))
        .cornerRadius(10)
    }
}

private struct DataTypeRow: View {
    @ObservedObject var viewModel: ZipContentSelectionViewModel
    let importPreview: DataImportPreview

    var isSelected: Bool {
        viewModel.selectedTypes.contains(importPreview.type)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {  // Reduce duration
                        viewModel.toggleSelection(importPreview.type)
                    }
                } label: {
                    Image(isSelected ? .checkRecolorableBlue24 : .roundCheckbox24)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .animation(.none, value: isSelected)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())

                importPreview.icon
                    .frame(width: 24)
                    .padding(.trailing, 8)

                Text(importPreview.title)
                    .daxBodyRegular()
                    .foregroundColor(Color(designSystemColor: .textPrimary))

                Spacer()

                Text("\(importPreview.count)")
                    .daxBodyRegular()
                    .foregroundColor(Color(designSystemColor: .textSecondary))
                    .padding(.trailing, 8)
            }
            .padding(.leading, 8)
            .padding(.trailing, 16)
            .padding(.vertical, 2)

            if importPreview != viewModel.importPreview.last {
                Divider()
                    .foregroundColor(Color(designSystemColor: .lines))
                    .padding(.leading, 84)
                    .padding(.vertical, 0)
            }
        }

    }
}

private struct ContinueButton: View {
    @ObservedObject var viewModel: ZipContentSelectionViewModel

    var body: some View {
        Button {
            viewModel.optionsSelected()
        } label: {
            Text(UserText.zipContentSelectionButtonContinue)
        }
        .buttonStyle(PrimaryButtonStyle(disabled: viewModel.selectedTypes.isEmpty))
        .padding(.top, 44)
        .padding(.bottom, 8)
        .disabled(viewModel.selectedTypes.isEmpty)
    }
}

// MARK: - Constants

private enum Const {

    enum Size {
        static let ios15scrollOffset: CGFloat = 80.0
        static let maxWidth: CGFloat = 480.0
    }
}
