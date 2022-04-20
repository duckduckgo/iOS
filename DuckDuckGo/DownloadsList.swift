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
    
    @State private var isCancelDownloadAlertPresented: Bool = false
    
    var body: some View {
        NavigationView {
            listOrEmptyState
                .navigationBarTitle(Text(UserText.downloadsScreenTitle), displayMode: .inline)
                .navigationBarItems(trailing: doneButton)
        }
        .navigationViewStyle(.stack)
    }
    
    private var doneButton: some View {
        Button(action: {
            if #available(iOS 15.0, *) {
                presentationMode.wrappedValue.dismiss()
            } else {
                // Because: presentationMode.wrappedValue.dismiss() for view wrapped in NavigationView() does not work in iOS 14 and lower
                if var topController = UIApplication.shared.windows.first!.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    topController.dismiss(animated: true)
                }
            }
        },
               label: { Text(UserText.navigationTitleDone).foregroundColor(.barButton).bold() })
            .opacity(editMode == .inactive ? 1.0 : 0.0)
    }
    
    @ViewBuilder
    private var listOrEmptyState: some View {
        if viewModel.sections.isEmpty {
            emptyState
        } else {
            listWithBottomToolbar
        }
    }
    
    private var emptyState: some View {
        VStack {
            Spacer()
                .frame(height: 32)
            Text(UserText.emptyDownloads)
                .font(Font(uiFont: Const.Font.emptyState))
                .foregroundColor(.emptyState)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.background)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    @ViewBuilder
    private var listWithBottomToolbar: some View {
        if #available(iOS 15.0, *) {
            list.toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    toolbarButtons
                }
            }
        } else if #available(iOS 14.0, *) {
            list.toolbar {
                toolbarContent
            }
        } else {
            // Due to no proper toolbar support in SwiftUI for iOS 13
            VStack {
                list
                HStack {
                    toolbarButtons
                }
                .padding()
            }
        }
    }
    
    @ViewBuilder
    private var toolbarButtons: some View {
        Button {
            self.deleteAll()
        } label: {
            Text(UserText.downloadsListDeleteAllButton)
                .foregroundColor(.deleteAll)
        }
        .buttonStyle(.plain)
        .opacity(editMode == .active ? 1.0 : 0.0)
        Spacer()
        EditButton().environment(\.editMode, $editMode)
            .foregroundColor(.barButton)
            .buttonStyle(.plain)
    }
    
    @available(iOS 14.0, *)
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // Required due to iOS 14 issue of buttons ignoring styling
        ToolbarItem(placement: .bottomBar) {
            HStack {
                Button {
                    self.deleteAll()
                } label: {
                    Text(UserText.downloadsListDeleteAllButton)
                        .foregroundColor(.deleteAll)
                }
                .foregroundColor(.deleteAll)
                .buttonStyle(.plain)
                
                Spacer(minLength: 0)
            }
            .opacity(editMode == .active ? 1.0 : 0.0)
        }
        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }
        ToolbarItem(placement: .bottomBar) {
            HStack {
                EditButton().environment(\.editMode, $editMode)
                    .foregroundColor(.barButton)
                Spacer(minLength: 0)
            }
        }
    }
    
    private var list: some View {
        List {
            ForEach(viewModel.sections) { section in
                Section(header: Text(section.header)) {
                    ForEach(section.rows) { rowModel in
                        row(for: rowModel)
                    }
                    .onDelete { offset in
                        self.delete(at: offset, in: section)
                    }
                }
                .listRowBackground(Color.rowBackground)
            }
        }
        .environment(\.editMode, $editMode)
        .listStyle(.grouped)
    }
    
    @ViewBuilder
    private func row(for rowModel: DownloadsListRowViewModel) -> some View {
        if let rowModel = rowModel as? OngoingDownloadRowViewModel {
            OngoingDownloadRow(rowModel: rowModel,
                               cancelButtonAction: { self.isCancelDownloadAlertPresented = true })
                .alert(isPresented: $isCancelDownloadAlertPresented) { makeCancelDownloadAlert(for: rowModel) }
                .deleteDisabled(true)
        } else if let rowModel = rowModel as? CompleteDownloadRowViewModel {
            CompleteDownloadRow(rowModel: rowModel,
                                shareButtonAction: { buttonFrame in share(rowModel, from: buttonFrame) })
        }
    }
    
    private func cancelDownload(for rowModel: OngoingDownloadRowViewModel) {
        viewModel.cancelDownload(for: rowModel)
    }
    
    private func delete(at offsets: IndexSet, in section: DownloadsListSectionViewModel) {
        guard let sectionIndex = viewModel.sections.firstIndex(of: section) else { return }
        viewModel.deleteDownload(at: offsets, in: sectionIndex)
    }
    
    private func deleteAll() {
        editMode = .inactive
        viewModel.deleteAllDownloads()
    }
    
    private func share(_ rowModel: CompleteDownloadRowViewModel, from rectangle: CGRect) {
        viewModel.showActivityView(for: rowModel, from: rectangle)
    }
}

extension DownloadsList {
    private func makeCancelDownloadAlert(for row: OngoingDownloadRowViewModel) -> Alert {
        Alert(
            title: Text(UserText.cancelDownloadAlertTitle),
            message: Text(UserText.cancelDownloadAlertDescription),
            primaryButton: .cancel(Text(UserText.cancelDownloadAlertResumeAction)),
            secondaryButton: .destructive(Text(UserText.cancelDownloadAlertCancelAction), action: {
                cancelDownload(for: row)
            })
        )
    }
}

private enum Const {
    enum Font {
        static let emptyState = UIFont.appFont(ofSize: 16)
    }
}

private extension Color {
    static let barButton = Color("DownloadsListBarButtonColor")
    static let emptyState = Color("DownloadsListEmptyStateColor")
    static let deleteAll = Color("DownloadsListDestructiveColor")
    static let background = Color("DownloadsListBackgroundColor")
    static let rowBackground = Color("DownloadsListRowBackgroundColor")
}
