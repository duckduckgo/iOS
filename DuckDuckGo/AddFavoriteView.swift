//
//  AddFavoriteView.swift
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
import Bookmarks
import Combine

struct AddFavoriteView: View {
    @Environment(\.dismiss) var dismiss

    @ObservedObject private(set) var searchViewModel: FavoriteSearchViewModel
    let favoritesCreating: MenuBookmarksInteracting

    @State var selectedItems = Set<WebPageSearchResultValue>()

    var body: some View {
        List {
            Section {
                TextField(text: $searchViewModel.searchTerm) {
                    Text(verbatim: "Website URL")
                }
                .overlay(alignment: .trailing, content: {
                    if !searchViewModel.searchTerm.isEmpty {
                        Button {
                            searchViewModel.clear()
                        } label: {
                            Image(.remove)
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 16)
                                .overlay {
                                    Circle().stroke(.black)
                                }
                        }
                    }
                })
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .textFieldStyle(.automatic)
            }

            Section {
                ForEach(searchViewModel.results) { result in
                    Button {
                        selectedItems.insert(result)
                    } label: {
                        FavoriteSearchResultItemView(result: result, isSelected: selectedItems.contains(result))
                    }
                }
            }
        }
        .navigationTitle("Add Favorite")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Text(verbatim: "Cancel")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    for item in selectedItems {
                        favoritesCreating.createOrToggleFavorite(title: item.name, url: item.url)
                    }
                    dismiss()
                } label: {
                    Text(verbatim: "Save")
                }
                .disabled(selectedItems.isEmpty)
            }
        }
        .tintIfAvailable(.black)
        .if(searchViewModel.results.isEmpty) {
            $0.mediumDetents()
        }
        .if(!searchViewModel.results.isEmpty) {
            $0.largeDetents()
        }
    }
}

private extension View {
    @ViewBuilder
    func mediumDetents() -> some View {
        if #available(iOS 16, *) {
            self.presentationDetents([.medium])
        } else {
            self
        }
    }

    @ViewBuilder
    func largeDetents() -> some View {
        if #available(iOS 16, *) {
            self.presentationDetents([.large])
        } else {
            self
        }
    }
}

#Preview {
    AddFavoriteView(searchViewModel: .fakeShared, favoritesCreating: NullMenuBookmarksInteracting())
}
