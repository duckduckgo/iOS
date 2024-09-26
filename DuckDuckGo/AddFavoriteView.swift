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
import DuckUI
import Core

struct AddFavoriteView: View {
    @Environment(\.dismiss) var dismiss

    @ObservedObject private(set) var viewModel: AddFavoriteViewModel

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .center, spacing: 8) {

            Group {
                headerView
                searchInputField
                    .padding(.top, 24)
            }
            .padding(.horizontal, Metrics.horizontalPadding)

            if !viewModel.searchTerm.isEmpty {
                searchList
                    .applyBackground()
                    .padding(24)

                customEntryButton
            }

            Spacer()

        }
        .background(Color(designSystemColor: .background))
        .frame(maxWidth: .infinity)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Text(verbatim: "Cancel")
                }
            }
        }
        .tintIfAvailable(Color(designSystemColor: .textPrimary))
        .onAppear {
            isFocused = true
        }
        .onDisappear {
            viewModel.clear()
        }
    }

    private var customEntryButton: some View {
        Button {
            viewModel.addCustomWebsite()
        } label: {
            Text(UserText.addFavoriteCustomWebsiteButtonTitle)
        }
        .buttonStyle(SecondaryButtonStyle(compact: true, fullWidth: false))
    }

    @ViewBuilder
    private var searchList: some View {
        LazyVStack {
            if !viewModel.results.isEmpty {
                ForEach(viewModel.results) { result in
                    Button {
                        viewModel.addFavorite(for: result)
                        dismiss()
                    } label: {
                        FavoriteSearchResultItemView(result: result, isDisabled: !result.isActionable)
                    }
                    .disabled(!result.isActionable)
                }
            } else if viewModel.wasSearchCompleted {
                FavoriteNoResultsItemView()
                    .disabled(true)
            }
        }
    }

    private var searchInputField: some View {
        HStack(spacing: 8) {
            Group {
                TextField(text: $viewModel.searchTerm) {
                    Text(UserText.addFavoriteSearchPlaceholder)
                }
                .foregroundStyle(Color(designSystemColor: .textPrimary))
                .daxBodyRegular()
                .focused($isFocused)
                .textInputAutocapitalization(.never)
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .textFieldStyle(.automatic)

                if !viewModel.searchTerm.isEmpty {
                    Button {
                        viewModel.clear()
                    } label: {
                        Image(.clear16)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 16)
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .inset(by: 1)
                .stroke(Color(designSystemColor: .accent), lineWidth: 2)
                .foregroundStyle(Color(designSystemColor: .panel))
        }
    }

    @ViewBuilder
    private var headerView: some View {
        Image(.favoritesAdd128)

        Text(UserText.addFavoriteHeader)
            .daxTitle2()
            .multilineTextAlignment(.center)
            .foregroundStyle(Color(designSystemColor: .textPrimary))

        Text(UserText.addFavoriteSubheader)
            .daxBodyRegular()
            .multilineTextAlignment(.center)
            .foregroundStyle(Color(designSystemColor: .textSecondary))
    }

    private struct Metrics {
        static let horizontalPadding: CGFloat = 24
        static let listHorizontalPadding: CGFloat = 8
    }
}

#Preview {
    AddFavoriteView(viewModel: .preview)
}

struct PreviewBookmarksSearch: BookmarksStringSearch {
    let hasData: Bool = false
    func search(query: String) -> [any BookmarksStringSearchResult] {
        []
    }
}
