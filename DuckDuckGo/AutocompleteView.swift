//
//  AutocompleteView.swift
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

import Foundation
import SwiftUI

struct AutocompleteView: View {

    @ObservedObject var model: AutocompleteViewModel

    var body: some View {
        List {
            if model.isMessageVisible {
                HistoryMessageView {
                    model.onDismissMessage()
                }
                .listRowBackground(Color(designSystemColor: .surface))
                .onAppear {
                    model.onShownToUser()
                }
            }

            SuggestionsSection(suggestions: model.topHits,
                               query: model.query,
                               onSuggestionSelected: model.onSuggestionSelected,
                               onSuggestionDeleted: model.deleteSuggestion)

            SuggestionsSection(suggestions: model.ddgSuggestions,
                               query: model.query,
                               onSuggestionSelected: model.onSuggestionSelected,
                               onSuggestionDeleted: model.deleteSuggestion)

            SuggestionsSection(suggestions: model.localResults,
                               query: model.query,
                               onSuggestionSelected: model.onSuggestionSelected,
                               onSuggestionDeleted: model.deleteSuggestion)

        }
        .offset(x: 0, y: -20)
        .padding(.bottom, -20)
        .modifier(HideScrollContentBackground())
        .background(Color(designSystemColor: .background))
        .modifier(CompactSectionSpacing())
        .modifier(DisableSelection())
        .modifier(DismissKeyboardOnSwipe())
        .environmentObject(model)
   }

}

private struct HistoryMessageView: View {

    var onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                onDismiss()
            } label: {
                Image("Close-24")
                    .foregroundColor(.primary)
            }
            .padding(.top, 4)
            .buttonStyle(.plain)

            VStack {
                Image("RemoteMessageAnnouncement")
                    .padding(8)

                Text(UserText.autocompleteHistoryWarningTitle)
                    .multilineTextAlignment(.center)
                    .daxHeadline()
                    .padding(2)

                Text(UserText.autocompleteHistoryWarningDescription)
                    .multilineTextAlignment(.center)
                    .daxFootnoteRegular()
                    .frame(maxWidth: 536)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
    }

}

private struct DismissKeyboardOnSwipe: ViewModifier {

    func body(content: Content) -> some View {
        if #available(iOS 16, *) {
            content.scrollDismissesKeyboard(.immediately)
        } else {
            content
        }
    }

}

private struct DisableSelection: ViewModifier {

    func body(content: Content) -> some View {
        if #available(iOS 17, *) {
            content.selectionDisabled()
        } else {
            content
        }
    }

}

private struct CompactSectionSpacing: ViewModifier {

    func body(content: Content) -> some View {
        if #available(iOS 17, *) {
            content.listSectionSpacing(.compact)
        } else {
            content
        }
    }

}

private struct HideScrollContentBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16, *) {
            content.scrollContentBackground(.hidden)
        } else {
            content
        }
    }
}

private struct SuggestionsSection: View {

    @EnvironmentObject var autocompleteViewModel: AutocompleteViewModel

    let suggestions: [AutocompleteViewModel.SuggestionModel]
    let query: String?
    var onSuggestionSelected: (AutocompleteViewModel.SuggestionModel) -> Void
    var onSuggestionDeleted: (AutocompleteViewModel.SuggestionModel) -> Void

    let selectedColor = Color(designSystemColor: .accent)
    let unselectedColor = Color(designSystemColor: .surface)

    var body: some View {
        Section {
            ForEach(suggestions.indices, id: \.self) { index in
                 Button {
                     onSuggestionSelected(suggestions[index])
                 } label: {
                    SuggestionView(model: suggestions[index], query: query)
                 }
                 .listRowBackground(autocompleteViewModel.selection == suggestions[index] ? selectedColor : unselectedColor)
                 .modifier(SwipeDeleteHistoryModifier(suggestion: suggestions[index], onSuggestionDeleted: onSuggestionDeleted))
            }
        }
    }

}

private struct SwipeDeleteHistoryModifier: ViewModifier {

    let suggestion: AutocompleteViewModel.SuggestionModel
    var onSuggestionDeleted: (AutocompleteViewModel.SuggestionModel) -> Void

    func body(content: Content) -> some View {

        switch suggestion.suggestion {
        case .historyEntry:
            content.swipeActions {
                Button(role: .destructive) {
                    onSuggestionDeleted(suggestion)
                } label: {
                    Label("Delete", image: "Trash-24")
                }
            }

        default:
            content
        }

    }

}

private struct SuggestionView: View {

    @EnvironmentObject var autocompleteModel: AutocompleteViewModel

    let model: AutocompleteViewModel.SuggestionModel
    let query: String?

    var tapAheadImage: Image? {
        guard model.canShowTapAhead else { return nil }
        return Image(autocompleteModel.isAddressBarAtBottom ?
                      "Arrow-Circle-Down-Left-16" : "Arrow-Circle-Up-Left-16")
    }

    var body: some View {
        Group {

            switch model.suggestion {
            case .phrase(let phrase):
                SuggestionListItem(icon: Image("Find-Search-24"),
                                   title: phrase,
                                   query: query,
                                   indicator: tapAheadImage) {
                    autocompleteModel.onTapAhead(model)
                }

            case .website(let url):
                SuggestionListItem(icon: Image("Globe-24"),
                                   title: url.formattedForSuggestion())

            case .bookmark(let title, let url, let isFavorite, _) where isFavorite:
                SuggestionListItem(icon: Image("Bookmark-Fav-24"),
                                   title: title,
                                   subtitle: url.formattedForSuggestion())

            case .bookmark(let title, let url, _, _):
                SuggestionListItem(icon: Image("Bookmark-24"),
                                   title: title,
                                   subtitle: url.formattedForSuggestion())

            case .historyEntry(_, let url, _) where url.isDuckDuckGoSearch:
                SuggestionListItem(icon: Image("History-24"),
                                   title: url.searchQuery ?? "",
                                   subtitle: UserText.autocompleteSearchDuckDuckGo)

            case .historyEntry(let title, let url, _):
                SuggestionListItem(icon: Image("History-24"),
                                   title: title ?? "",
                                   subtitle: url.formattedForSuggestion())

            case .openTab(title: let title, url: let url):
                SuggestionListItem(icon: Image("OpenTab-24"),
                                   title: title,
                                   subtitle: "\(UserText.autocompleteSwitchToTab) · \(url.formattedForSuggestion())")

            case .internalPage, .unknown:
                FailedAssertionView("Unknown or unsupported suggestion type")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

}

private struct SuggestionListItem: View {

    let icon: Image
    let title: String
    let subtitle: String?
    let query: String?
    let indicator: Image?
    let onTapIndicator: (() -> Void)?

    init(icon: Image,
         title: String,
         subtitle: String? = nil,
         query: String? = nil,
         indicator: Image? = nil,
         onTapIndicator: ( () -> Void)? = nil) {

        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.query = query
        self.indicator = indicator
        self.onTapIndicator = onTapIndicator
    }

    var body: some View {

        HStack {
            icon
                .resizable()
                .frame(width: 24, height: 24)
                .tintIfAvailable(Color(designSystemColor: .icons))

            VStack(alignment: .leading, spacing: 2) {

                Group {
                    // Can't use dax modifiers because they are not typed for Text
                    if let query, title.hasPrefix(query) {
                        Text(query)
                            .font(Font(uiFont: UIFont.daxBodyRegular()))
                            .foregroundColor(Color(designSystemColor: .textPrimary))
                        +
                        Text(title.dropping(prefix: query))
                            .font(Font(uiFont: UIFont.daxBodyBold()))
                            .foregroundColor(Color(designSystemColor: .textPrimary))
                    } else {
                        Text(title)
                            .font(Font(uiFont: UIFont.daxBodyRegular()))
                            .foregroundColor(Color(designSystemColor: .textPrimary))
                    }
                }
                .lineLimit(1)

                if let subtitle {
                    Text(subtitle)
                        .daxFootnoteRegular()
                        .foregroundColor(Color(designSystemColor: .textSecondary))
                        .lineLimit(1)
                }
            }

            if let indicator {
                Spacer()
                indicator
                    .highPriorityGesture(TapGesture().onEnded {
                        onTapIndicator?()
                    })
                    .tintIfAvailable(Color.secondary)
            }
        }
    }
}

private extension URL {

    func formattedForSuggestion() -> String {
        let string = absoluteString
            .dropping(prefix: "https://")
            .dropping(prefix: "http://")
            .droppingWwwPrefix()
        return pathComponents.isEmpty ? string : string.dropping(suffix: "/")
    }

}
