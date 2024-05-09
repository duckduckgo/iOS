//
//  AutocompleteViewModel.swift
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

import Core
import Suggestions
import SwiftUI

// TODO handle pressing enter on selection
protocol AutocompleteViewModelDelegate: NSObjectProtocol {

    func onSuggestionSelected(_ suggestion: Suggestion)
    func onTapAhead(_ suggestion: Suggestion)
    func onMessageDismissed()

}

class AutocompleteViewModel: ObservableObject {

    @Published var selection: SuggestionModel? {
        didSet {
            print(selection?.id.uuidString ?? "<nil> selection")
        }
    }
    @Published var topHits = [SuggestionModel]()
    @Published var ddgSuggestions = [SuggestionModel]()
    @Published var localResults = [SuggestionModel]()
    @Published var query: String?
    @Published var isEmpty = true

    @Published var isMessageVisible = true

    weak var delegate: AutocompleteViewModelDelegate?

    let isAddressBarAtBottom: Bool

    init(isAddressBarAtBottom: Bool, showMessage: Bool) {
        self.isAddressBarAtBottom = isAddressBarAtBottom
        self.isMessageVisible = showMessage
    }

    var emptySuggestion: SuggestionModel {
        SuggestionModel(suggestion: .phrase(phrase: query ?? ""), canShowTapAhead: false)
    }

    func updateSuggestions(_ suggestions: SuggestionResult) {
        topHits = suggestions.topHits.map { SuggestionModel(suggestion: $0) }
        ddgSuggestions = suggestions.duckduckgoSuggestions.map { SuggestionModel(suggestion: $0) }
        localResults = suggestions.localSuggestions.map { SuggestionModel(suggestion: $0) }
        isEmpty = topHits.isEmpty && ddgSuggestions.isEmpty && localResults.isEmpty
    }

    func onDismissMessage() {
        withAnimation {
            isMessageVisible = false
            delegate?.onMessageDismissed()
        }
    }

    func onSuggestionSelected(_ model: SuggestionModel) {
        delegate?.onSuggestionSelected(model.suggestion)
    }

    func onTapAhead(_ model: SuggestionModel) {
        delegate?.onTapAhead(model.suggestion)
    }

    func nextSelection() {
        let all = topHits + ddgSuggestions + localResults
        guard let selection else {
            selection = all.first
            return
        }

        guard let index = all.firstIndex(of: selection) else {
            return
        }

        let nextIndex = index + 1
        if all.indices.contains(nextIndex) {
            self.selection = all[nextIndex]
        }
    }

    func previousSelection() {
        guard let selection else { return }
        let all = topHits + ddgSuggestions + localResults

        guard let index = all.firstIndex(of: selection) else {
            return
        }

        let nextIndex = index - 1
        if all.indices.contains(nextIndex) {
            self.selection = all[nextIndex]
        }
    }

    struct SuggestionModel: Identifiable, Equatable {
        let id = UUID()
        let suggestion: Suggestion
        var canShowTapAhead = true

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
    }

}
