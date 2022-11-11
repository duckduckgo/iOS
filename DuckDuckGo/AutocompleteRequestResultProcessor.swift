//
//  AutocompleteRequestResultProcessor.swift
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

import Foundation
import Core

class AutocompleteRequestResultProcessor {
    
    private var autoCompleteRequestData: Data?
    private var autoCompleteRequestError: Error?
    private var listOfAutocompleteEntries: [AutocompleteEntry]!
    private var listOfSuggestionsFromAutocompleteData: [Suggestion]!
    
    init() {}
    
    public func processResult(data: Data?, error: Error?) throws -> [Suggestion] {
        self.clearListOfAutocompleteEntries()
        self.clearListOfSuggestionsFromAutocompleteData()
        self.setAutoCompleteRequestData(data: data)
        self.setAutoCompleteRequestError(error: error)
        try self.throwErrorIfAutoCompleteRequestErrorInNotNil()
        try self.throwErrorIfAutoCompleteRequestDataIsNil()
        try self.setListOfAutocompleteEntriesFromJSONDecoderData()
        self.discardNilResultsInListOfAutoCompleteEntries()
        self.discardEntiresFromListOfAuthoCompleteEntriesThatDontContainPhrases()
        self.createListOfAutoCompletePhraseSuggestionsFromAutoCompleteEntries()
        return listOfSuggestionsFromAutocompleteData
    }
    
    private func clearListOfAutocompleteEntries() {
        self.listOfAutocompleteEntries = []
    }
    
    private func clearListOfSuggestionsFromAutocompleteData() {
        self.listOfSuggestionsFromAutocompleteData = []
    }
    
    private func setAutoCompleteRequestData(data: Data?) {
        self.autoCompleteRequestData = data
    }
    
    private func setAutoCompleteRequestError(error: Error?) {
        self.autoCompleteRequestError = error
    }
    
    private func throwErrorIfAutoCompleteRequestErrorInNotNil() throws {
        if autoCompleteRequestError != nil {
            throw autoCompleteRequestError!
        }
    }
    
    private func throwErrorIfAutoCompleteRequestDataIsNil() throws {
        if autoCompleteRequestData == nil {
            throw ApiRequestError.noData
        }
    }
    
    private func setListOfAutocompleteEntriesFromJSONDecoderData() throws {
        self.listOfAutocompleteEntries = try JSONDecoder().decode([AutocompleteEntry].self, from: autoCompleteRequestData!)
    }
    
    private func discardNilResultsInListOfAutoCompleteEntries() {
        listOfAutocompleteEntries = listOfAutocompleteEntries.compactMap { return $0 }
    }
    
    private func discardEntiresFromListOfAuthoCompleteEntriesThatDontContainPhrases() {
        listOfAutocompleteEntries = listOfAutocompleteEntries.compactMap {
            if $0.phrase == nil {
                return nil
            }
            return $0
        }
    }
    
    private func createListOfAutoCompletePhraseSuggestionsFromAutoCompleteEntries() {
        for entry in listOfAutocompleteEntries {
            if isEntryNavNil(entry) {
                self.appendNilNavAutocompleteSuggestionToListFromAutocompleteEntry(entry: entry)
            } else {
                self.appendNonNilNavAutocompleteSuggestionToListFromAutocompleteEntry(entry: entry)
            }
        }
    }
    
    private func isEntryNavNil(_ entry: AutocompleteEntry) -> Bool {
        return entry.isNav == nil
    }
            
    private func appendNilNavAutocompleteSuggestionToListFromAutocompleteEntry(entry: AutocompleteEntry) {
        let navAutocompleteSuggestion = createNilNavAutoCompleteSuggestionFromPhrase(autocompletePhrase: entry.phrase!)
        listOfSuggestionsFromAutocompleteData.append(navAutocompleteSuggestion)
    }
    
    private func createNilNavAutoCompleteSuggestionFromPhrase(autocompletePhrase: String) -> Suggestion {
        let url = URL.webUrl(from: autocompletePhrase)
        return createSuggestionFromPhraseAndURL(autocompletePhrase: autocompletePhrase, url: url)
    }
    
    private func createSuggestionFromPhraseAndURL(autocompletePhrase: String, url: URL?) -> Suggestion {
        return Suggestion(source: .remote, suggestion: autocompletePhrase, url: url)
    }
    
    private func appendNonNilNavAutocompleteSuggestionToListFromAutocompleteEntry(entry: AutocompleteEntry) {
        let nonNilNavAutoCompleteSuggestion = createNonNilNavAutoCompleteSuggestionFromEntry(autocompleteEntry: entry)
        listOfSuggestionsFromAutocompleteData.append(nonNilNavAutoCompleteSuggestion)
    }
    
    private func createNonNilNavAutoCompleteSuggestionFromEntry(autocompleteEntry: AutocompleteEntry) -> Suggestion {
        if isEntryANav(autocompleteEntry) {
            return createNavAutoCompleteSuggestionFromEntry(autocompleteEntry: autocompleteEntry)
        }
        return createNonNavAutoCompleteSuggeztionFromEntry(autocompleteEntry: autocompleteEntry)
    }
    
    private func isEntryANav(_ entry: AutocompleteEntry) -> Bool {
        return entry.isNav!
    }
    
    private func createNavAutoCompleteSuggestionFromEntry(autocompleteEntry: AutocompleteEntry) -> Suggestion {
        let url = URL(string: "http://\(autocompleteEntry.phrase!)")
        return createSuggestionFromPhraseAndURL(autocompletePhrase: autocompleteEntry.phrase!, url: url)
    }
    
    private func createNonNavAutoCompleteSuggeztionFromEntry(autocompleteEntry: AutocompleteEntry) -> Suggestion {
        return createSuggestionFromPhraseAndURL(autocompletePhrase: autocompleteEntry.phrase!, url: nil)
    }
    
}
