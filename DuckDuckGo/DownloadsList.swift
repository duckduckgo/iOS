//
//  DownloadsList.swift
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

struct DownloadsList: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: DownloadsListViewModel
    @State var editMode: EditMode = .inactive
  
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.sections) { section in
                        Section(header: Text(section.header)) {
                            ForEach(section.rows) { row in
                                switch row.type {
                                case .ongoing:
                                    OngoingDownloadRow(rowModel: row, cancelButtonAction: cancelDownload(for:))
                                case .complete:
                                    CompleteDownloadRow(rowModel: row)
                                }
                            }
                            .onDelete { offset in
                                self.delete(at: offset, in: section)
                            }
                        }
                    }
                    if editMode == .active {
                        DeleteAllSection()
                    }
                }
                .listStyle(.grouped)
                .environment(\.editMode, $editMode)
                
                HStack {
                    Spacer()
                    EditButton().environment(\.editMode, $editMode)
                }
                .padding()
            }
            .navigationBarTitle("Downloads", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") { presentationMode.wrappedValue.dismiss() }
                                    .opacity(editMode == .inactive ? 1.0 : 0.0))
        }
        .navigationViewStyle(.stack)
    }
    
    private func cancelDownload(for rowModel: DownloadsListRow) {
        viewModel.cancelDownload(for: rowModel)
    }
    
    private func delete(at offsets: IndexSet, in section: DownloadsListSection) {
        guard let sectionIndex = viewModel.sections.firstIndex(of: section) else { return }
        viewModel.deleteDownload(at: offsets, in: sectionIndex)
    }

}

struct DeleteAllSection: View {
    var body: some View {
        Section(header: Spacer()) {
            HStack {
                Spacer()
                Text("Delete All")
                    .foregroundColor(Color.red)
                Spacer()
            }
        }
        .deleteDisabled(true)
    }
}
