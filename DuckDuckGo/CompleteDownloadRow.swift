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

struct CompleteDownloadRow: View {
    
    @State private var isSharePresented = false
    @State private var isPreviewPresented = false
    
    var rowModel: DownloadsListRow
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(rowModel.filename)
                    .font(Font(uiFont: Const.Font.filename))
                    .foregroundColor(.filename)
                Spacer()
                    .frame(height: Const.Spacing.betweenLabels)
                Text(rowModel.fileSize)
                    .font(Font(uiFont: Const.Font.fileSize))
                    .foregroundColor(.fileSize)
            }
            
            Spacer()
            
            shareButton
        }
        .frame(height: Const.Size.rowHeight)
        .listRowInsets(EdgeInsets.rowInsets)
        .contentShape(Rectangle())
        .onTapGesture {
            self.isPreviewPresented = true
        }
        .sheet(isPresented: $isPreviewPresented, content: {
            if let fileURL = rowModel.localFileURL {
                QuickLookPreviewView(localFileURL: fileURL)
                    .edgesIgnoringSafeArea(.all)
            } else {
                #warning("Pixel and/or display an error message?")
            }
        })
    }
    
    private var shareButton: some View {
        Button {
            self.isSharePresented = true
        } label: {
            Image.share
        }
        .buttonStyle(.plain)
        .animation(nil)
        .sheet(isPresented: $isSharePresented, content: {
            if let fileURL = rowModel.localFileURL {
                FileActivityView(localFileURL: fileURL)
                    .edgesIgnoringSafeArea(.all)
            } else {
                #warning("Pixel and/or display an error message?")
            }
        })
    }
}

private enum Const {
    enum Font {
        static let filename = UIFont.semiBoldAppFont(ofSize: 16)
        static let fileSize = UIFont.appFont(ofSize: 14)
    }
    
    enum Spacing {
        static let betweenLabels: CGFloat = 6
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
    static let share = Image("DownloadsShareIcon")
}
