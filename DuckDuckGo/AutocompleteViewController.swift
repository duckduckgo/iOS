//
//  AutocompleteViewController.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

import Common
import UIKit
import Core
import DesignResourcesKit
import Suggestions
import Networking
import CoreData
import Persistence
import History
import Combine
import BrowserServicesKit
import SwiftUI

class AutocompleteViewController: UIHostingController<AutocompleteView> {

    private static let debounceDelayMS = 100
    private static let session = URLSession(configuration: .ephemeral)

    var selectedSuggestion: Suggestion?

    weak var delegate: AutocompleteViewControllerDelegate?
    weak var presentationDelegate: AutocompleteViewControllerPresentationDelegate?

    private let historyManager: HistoryManager
    var historyCoordinator: HistoryCoordinating {
        historyManager.historyCoordinator
    }

    private let bookmarksDatabase: CoreDataDatabase
    private let appSettings: AppSettings
    private let model: AutocompleteViewModel

    private var task: URLSessionDataTask?

    @Published private var query = ""
    private var queryDebounceCancellable: AnyCancellable?

    private lazy var cachedBookmarks: CachedBookmarks = {
        CachedBookmarks(bookmarksDatabase)
    }()

    private var lastResults: SuggestionResult?
    private var loader: SuggestionLoader?

    private var historyMessageManager: HistoryMessageManager

    init(historyManager: HistoryManager,
         bookmarksDatabase: CoreDataDatabase,
         appSettings: AppSettings,
         historyMessageManager: HistoryMessageManager = HistoryMessageManager()) {
        self.historyManager = historyManager
        self.bookmarksDatabase = bookmarksDatabase
        self.appSettings = appSettings
        self.historyMessageManager = historyMessageManager
        self.model = AutocompleteViewModel(isAddressBarAtBottom: appSettings.currentAddressBarPosition == .bottom,
                                           showMessage: historyManager.isHistoryFeatureEnabled() && historyMessageManager.shouldShow())
        super.init(rootView: AutocompleteView(model: model))
        self.model.delegate = self
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(designSystemColor: .background)

        queryDebounceCancellable = $query
            .debounce(for: .milliseconds(Self.debounceDelayMS), scheduler: RunLoop.main)
            .sink { [weak self] query in
                self?.requestSuggestions(query: query)
            }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        historyMessageManager.incrementDisplayCount()
        fireUsagePixels()
    }

    func keyboardMoveSelectionDown() {
        model.nextSelection()
    }

    func keyboardMoveSelectionUp() {
        model.previousSelection()
    }
    
    func updateQuery(_ query: String) {
        model.selection = nil
        guard self.query != query else { return }
        cancelInFlightRequests()
        self.query = query
        model.query = query
    }

    private func fireUsagePixels() {
        var bookmark = false
        var favorite = false
        var history = false

        lastResults?.all.forEach {
            switch $0 {
            case .bookmark(_, _, isFavorite: let isFavorite, _):
                if isFavorite {
                    favorite = true
                } else {
                    bookmark = true
                }

            case .historyEntry:
                history = true

            default: break
            }
        }

        if bookmark {
            Pixel.fire(pixel: .autocompleteDisplayedLocalBookmark)
        }

        if favorite {
            Pixel.fire(pixel: .autocompleteDisplayedLocalFavorite)
        }

        if history {
            Pixel.fire(pixel: .autocompleteDisplayedLocalHistory)
        }

    }

    private func cancelInFlightRequests() {
        task?.cancel()
        task = nil
    }

    private func requestSuggestions(query: String) {
        model.selection = nil

        loader = SuggestionLoader(dataSource: self, urlFactory: { phrase in
            guard let url = URL(trimmedAddressBarString: phrase),
                  let scheme = url.scheme,
                  scheme.description.hasPrefix("http"),
                  url.isValid else {
                return nil
            }

            return url
        })

        loader?.getSuggestions(query: query) { [weak self] result, error in
            guard let self, error == nil else { return }
            let updatedResults = result ?? .empty
            self.lastResults = updatedResults
            model.updateSuggestions(updatedResults)
            updateHeight()
        }

    }

    private func updateHeight() {
        guard let lastResults else { return }

        let messageHeight = model.isMessageVisible ? 196 : 0
        let cellHeight = 44
        let sectionPadding = 10
        let controllerPadding = 20

        let height =
            (lastResults.topHits.count * cellHeight) +
            (lastResults.topHits.isEmpty ? 0 : sectionPadding) +
            (lastResults.duckduckgoSuggestions.count * cellHeight) +
            (lastResults.duckduckgoSuggestions.isEmpty ? 0 : sectionPadding) +
            (lastResults.localSuggestions.count * cellHeight) +
            (lastResults.localSuggestions.isEmpty ? 0 : sectionPadding) +
            messageHeight +
            controllerPadding

        presentationDelegate?
            .autocompleteDidChangeContentHeight(height: CGFloat(height))
    }

}

extension AutocompleteViewController: AutocompleteViewModelDelegate {

    func onMessageDismissed() {
        historyMessageManager.dismissedByUser()
        updateHeight()
    }

    func onMessageShown() {
        historyMessageManager.shownToUser()
    }

    func onSuggestionSelected(_ suggestion: Suggestion) {
        switch suggestion {
        case .bookmark(_, _, let isFavorite, _):
            Pixel.fire(pixel: isFavorite ? .autocompleteClickFavorite : .autocompleteClickBookmark)

        case .historyEntry(_, let url, _):
            Pixel.fire(pixel: url.isDuckDuckGoSearch ? .autocompleteClickSearchHistory : .autocompleteClickSiteHistory)

        case .phrase:
            Pixel.fire(pixel: .autocompleteClickPhrase)

        case .website:
            Pixel.fire(pixel: .autocompleteClickWebsite)

        default:
            // NO-OP
            break
        }
        self.delegate?.autocomplete(selectedSuggestion: suggestion)
    }

    func onTapAhead(_ suggestion: Suggestion) {
        self.delegate?.autocomplete(pressedPlusButtonForSuggestion: suggestion)
    }

    func onSuggestionHighlighted(_ suggestion: Suggestion, forQuery query: String) {
        self.delegate?.autocomplete(highlighted: suggestion, for: query)
    }
}

extension AutocompleteViewController: SuggestionLoadingDataSource {

    func history(for suggestionLoading: Suggestions.SuggestionLoading) -> [HistorySuggestion] {
        return historyCoordinator.history ?? []
    }

    func bookmarks(for suggestionLoading: Suggestions.SuggestionLoading) -> [Suggestions.Bookmark] {
        return cachedBookmarks.all
    }

    func internalPages(for suggestionLoading: Suggestions.SuggestionLoading) -> [Suggestions.InternalPage] {
        return []
    }

    func suggestionLoading(_ suggestionLoading: Suggestions.SuggestionLoading, suggestionDataFromUrl url: URL, withParameters parameters: [String: String], completion: @escaping (Data?, Error?) -> Void) {
        var queryURL = url
        parameters.forEach {
            queryURL = queryURL.appendingParameter(name: $0.key, value: $0.value)
        }

        var request = URLRequest.developerInitiated(queryURL)
        request.allHTTPHeaderFields = APIRequest.Headers().httpHeaders
        task = Self.session.dataTask(with: request) { data, _, error in
            completion(data, error)
        }
        task?.resume()
    }

}

private extension SuggestionResult {
    static let empty = SuggestionResult(topHits: [], duckduckgoSuggestions: [], localSuggestions: [])
}

extension HistoryEntry: HistorySuggestion {

    public var numberOfVisits: Int {
        return numberOfTotalVisits
    }

}
