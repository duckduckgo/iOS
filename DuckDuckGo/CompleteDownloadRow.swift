//
//  CompleteDownloadRow.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import GRDB

private struct ShareButtonFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}

struct CompleteDownloadRow: View {
    @State private var isPreviewPresented = false
    @State private var shareButtonFrame: CGRect = .zero
    
    var rowModel: CompleteDownloadRowViewModel
    
    var shareButtonAction: (CGRect) -> Void
    
    var body: some View {
        HStack {
            Button {
                self.isPreviewPresented = true
            } label: {
                VStack(alignment: .leading) {
                    Text(rowModel.filename)
                        .font(Font(uiFont: Const.Font.filename))
                        .foregroundColor(.filename)
                        .lineLimit(2)
                    Spacer()
                        .frame(height: Const.Spacing.betweenLabels)
                    Text(rowModel.fileSize)
                        .font(Font(uiFont: Const.Font.fileSize))
                        .foregroundColor(.fileSize)
                }
            }
            Spacer(minLength: Const.Spacing.betweenLabelsAndShareButton)

            shareButton
        }
        .frame(height: Const.Size.rowHeight)
        .listRowInsets(EdgeInsets.rowInsets)
        .contentShape(Rectangle())
        .sheet(isPresented: $isPreviewPresented, content: {
            QuickLookPreviewView(localFileURL: rowModel.fileURL)
                .edgesIgnoringSafeArea(.all)
        })
    }
    
    private var shareButton: some View {
        Button {
            self.shareButtonAction(shareButtonFrame)
        } label: {
            Image.share
        }
        .accessibilityLabel(UserText.actionShare)
        .buttonStyle(.plain)
        .animation(nil)
        .background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: ShareButtonFramePreferenceKey.self, value: geometryProxy.frame(in: .global))
            }
        )
        .onPreferenceChange(ShareButtonFramePreferenceKey.self) { newFrame in
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.shareButtonFrame = newFrame
            }
        }
    }
}

extension CompleteDownloadRow: Equatable {
    static func == (lhs: CompleteDownloadRow, rhs: CompleteDownloadRow) -> Bool {
        lhs.rowModel.filename == rhs.rowModel.filename && lhs.rowModel.fileSize == rhs.rowModel.fileSize
    }
}

private enum Const {
    enum Font {
        static let filename = UIFont.semiBoldAppFont(ofSize: 16)
        static let fileSize = UIFont.appFont(ofSize: 14)
    }
    
    enum Spacing {
        static let betweenLabels: CGFloat = 6
        static let betweenLabelsAndShareButton: CGFloat = 20
    }
    
    enum Size {
        static let rowHeight: CGFloat = 76
    }
}

private extension EdgeInsets {
    static let rowInsets = EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
}

private extension Color {
    static let filename = Color("DownloadsListFilenameColor")
    static let fileSize = Color("DownloadsListFileSizeColor")
}

private extension Image {
    static let share = Image("Share-24")
}
