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
                Spacer()
                    .frame(height: 4.0)
                Text(rowModel.fileSize)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button {
                self.isSharePresented = true
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            .buttonStyle(.plain)
            .animation(nil)
            .sheet(isPresented: $isSharePresented, onDismiss: {
                print("Dismiss")
            }, content: {
                ActivityViewController(rowModel: rowModel)
            })
        }
        .frame(height: 72.0)
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
                }
            } else {
                #warning("Pixel and/or display an error message?")
            }
        })
    }
}
