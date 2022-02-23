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
                    .frame(height: 6.0)
                Text(rowModel.fileSize)
                    .font(Font(uiFont: Const.Font.fileSize))
                    .foregroundColor(.fileSize)
            }
            Spacer()
            Button {
                self.isSharePresented = true
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20.0, height: 20.0)
            }
            .buttonStyle(.plain)
            .animation(nil)
            .sheet(isPresented: $isSharePresented, onDismiss: {
                print("Dismiss")
            }, content: {
                ActivityViewController(rowModel: rowModel)
            })
        }
        .frame(height: 76.0)
        .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
        .contentShape(Rectangle())
        .onTapGesture {
            self.isPreviewPresented.toggle()
        }
        .sheet(isPresented: $isPreviewPresented, onDismiss: {
            isPreviewPresented = false
        }, content: {
            if let localFileURL = rowModel.localFileURL {
                QuickLookPreviewRepresentable(localFileURL: localFileURL, isPresented: $isPreviewPresented) {
                    self.isPreviewPresented = false
                }.edgesIgnoringSafeArea(.all)

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
}

private extension Color {
    static let filename = Color(UIColor.darkGreyish)
    static let fileSize = Color(UIColor.greyish3)
}
