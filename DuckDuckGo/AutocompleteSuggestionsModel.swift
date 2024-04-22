//
//  AutocompleteSuggestionsModel.swift
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
import Suggestions

struct AutocompleteSuggestionsModel {

    private let suggestions: [Suggestion]
    private let sectionedSuggestions: [[IndexedSuggestion]]

    var isEmpty: Bool { suggestions.isEmpty }
    var count: Int { suggestions.count }

    var numberOfSections: Int { sectionedSuggestions.count }

    init(suggestionsResult: SuggestionResult) {
        self.suggestions = suggestionsResult.all

        let sectionsForDisplay = Self.makeSectionsForDisplay(using: suggestionsResult)
        sectionedSuggestions = sectionsForDisplay
    }

    func indexAfter(_ index: Int) -> Int {
        (index + 1 >= count) ? 0 : index + 1
    }

    func indexBefore(_ index: Int) -> Int {
        (index - 1 < 0) ? count - 1 : index - 1
    }

    func numberOfRows(in section: Int) -> Int {
        guard sectionedSuggestions.indices.contains(section) else { return 0 }

        return sectionedSuggestions[section].count
    }

    func suggestion(for index: Int) -> Suggestion? {
        guard suggestions.indices.contains(index) else { return nil }
        return suggestions[index]
    }

    func index(for indexPath: IndexPath) -> Int? {
        indexedSuggestion(for: indexPath)?.index
    }

    func suggestion(for indexPath: IndexPath) -> Suggestion? {
        indexedSuggestion(for: indexPath)?.suggestion
    }

    func indexPath(for itemIndex: Int) -> IndexPath? {
        guard suggestions.indices.contains(itemIndex) else { return nil }

        var section: Int = 0
        var row: Int = 0
        var currentIndex = itemIndex

        while true {
            let currentSectionCount = sectionedSuggestions[section].count
            if currentSectionCount > currentIndex {
                row = currentIndex
                break
            } else {
                currentIndex -= currentSectionCount
                section += 1
            }
        }

        return IndexPath(row: row, section: section)
    }

    private func indexedSuggestion(for indexPath: IndexPath) -> IndexedSuggestion? {
        guard sectionedSuggestions.indices.contains(indexPath.section),
              sectionedSuggestions[indexPath.section].indices.contains(indexPath.row) else {
            return nil
        }

        return sectionedSuggestions[indexPath.section][indexPath.row]
    }
}

private extension AutocompleteSuggestionsModel {
    static func makeSectionsForDisplay(using suggestionResult: SuggestionResult) -> [[IndexedSuggestion]] {
        var index = -1
        var topResults = [IndexedSuggestion]()
        var remoteSuggestions = [IndexedSuggestion]()
        var auxResults = [IndexedSuggestion]()

        topResults = suggestionResult.topHits.map {
            index += 1
            return IndexedSuggestion(index: index, suggestion: $0)
        }

        remoteSuggestions = suggestionResult.duckduckgoSuggestions.map {
            index += 1
            return IndexedSuggestion(index: index, suggestion: $0)
        }

        auxResults = suggestionResult.historyAndBookmarks.map {
            index += 1
            return IndexedSuggestion(index: index, suggestion: $0)
        }

        let results = [topResults, remoteSuggestions, auxResults]

        return results.filter { !$0.isEmpty }
    }
}

private struct IndexedSuggestion {
    let index: Int
    let suggestion: Suggestion
}
