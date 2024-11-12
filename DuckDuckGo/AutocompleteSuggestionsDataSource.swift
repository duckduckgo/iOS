//
//  AutocompleteSuggestionsDataSource.swift
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
import BrowserServicesKit
import Suggestions
import History
import Persistence
import Networking

final class AutocompleteSuggestionsDataSource: SuggestionLoadingDataSource {

    typealias SuggestionsRequestCompletion = (Data?, Error?) -> Void
    typealias SuggestionsRequest = (URLRequest, @escaping SuggestionsRequestCompletion) -> Void

    private let historyManager: HistoryManaging
    private let bookmarksDatabase: CoreDataDatabase
    private let featureFlagger: FeatureFlagger
    private let tabsModel: TabsModel

    private var performSuggestionsRequest: SuggestionsRequest

    /// Specifically open tabs that do not have the same URL as the current tab so that we avoid shown them in the results.
    private lazy var candidateOpenTabs: [BrowserTab] = {
        tabsModel.tabs.compactMap {
            guard let url = $0.link?.url,
                  tabsModel.currentTab?.link?.url != $0.link?.url
            else { return nil }

            return OpenTab(title: $0.link?.displayTitle ?? "", url: url)
        }
    }()

    private lazy var cachedBookmarks: CachedBookmarks = {
        CachedBookmarks(bookmarksDatabase)
    }()
    
    var historyCoordinator: HistoryCoordinating {
        historyManager.historyCoordinator
    }

    var platform: Platform {
        .mobile
    }

    init(historyManager: HistoryManaging, bookmarksDatabase: CoreDataDatabase, featureFlagger: FeatureFlagger, tabsModel: TabsModel, performSuggestionsRequest: @escaping SuggestionsRequest) {
        self.historyManager = historyManager
        self.bookmarksDatabase = bookmarksDatabase
        self.featureFlagger = featureFlagger
        self.tabsModel = tabsModel
        self.performSuggestionsRequest = performSuggestionsRequest
    }

    func history(for suggestionLoading: Suggestions.SuggestionLoading) -> [HistorySuggestion] {
        return historyCoordinator.history ?? []
    }

    func bookmarks(for suggestionLoading: Suggestions.SuggestionLoading) -> [Suggestions.Bookmark] {
        return cachedBookmarks.all
    }

    func internalPages(for suggestionLoading: Suggestions.SuggestionLoading) -> [Suggestions.InternalPage] {
        return []
    }

    func openTabs(for suggestionLoading: any SuggestionLoading) -> [BrowserTab] {
        if featureFlagger.isFeatureOn(.autcompleteTabs) {
            return candidateOpenTabs
        }
        return []
    }

    func suggestionLoading(_ suggestionLoading: Suggestions.SuggestionLoading, suggestionDataFromUrl url: URL, withParameters parameters: [String: String], completion: @escaping (Data?, Error?) -> Void) {
        var queryURL = url
        parameters.forEach {
            queryURL = queryURL.appendingParameter(name: $0.key, value: $0.value)
        }
        var request = URLRequest.developerInitiated(queryURL)
        request.allHTTPHeaderFields = APIRequest.Headers().httpHeaders

        performSuggestionsRequest(request, completion)
    }

}
