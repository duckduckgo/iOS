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

class AutocompleteViewController: UIViewController {
    
    private static let session = URLSession(configuration: .ephemeral)

    struct Constants {
        static let debounceDelay = 100 // millis
        static let minItems = 1
    }

    weak var delegate: AutocompleteViewControllerDelegate?
    weak var presentationDelegate: AutocompleteViewControllerPresentationDelegate?

    private var task: URLSessionDataTask?
    private var loader: SuggestionLoading?
    private var receivedResponse = false
    private var pendingRequest = false
    
    @Published fileprivate var query = ""
    fileprivate var queryDebounceCancellable: AnyCancellable?

    fileprivate var suggestions = [Suggestion]()
    fileprivate var selectedItem = -1
    
    private var historyCoordinator: HistoryCoordinating!
    private var bookmarksDatabase: CoreDataDatabase!
    private var appSettings: AppSettings!
    private lazy var cachedBookmarks: CachedBookmarks = {
        CachedBookmarks(bookmarksDatabase)
    }()

    var backgroundColor: UIColor {
        appSettings.currentAddressBarPosition.isBottom ?
            UIColor(designSystemColor: .background) :
            UIColor.black.withAlphaComponent(0.2)
    }

    var showBackground = true {
        didSet {
            view.backgroundColor = showBackground ? backgroundColor : UIColor.clear
        }
    }

    var selectedSuggestion: Suggestion? {
        let state = (suggestions: self.suggestions, selectedIndex: self.selectedItem)
        return state.suggestions.indices.contains(state.selectedIndex) ? state.suggestions[state.selectedIndex] : nil
    }

    private var hidesBarsOnSwipeDefault = true

    @IBOutlet weak var tableView: UITableView!
    var shouldOffsetY = false
    
    static func loadFromStoryboard(bookmarksDatabase: CoreDataDatabase,
                                   historyCoordinator: HistoryCoordinating,
                                   appSettings: AppSettings = AppDependencyProvider.shared.appSettings) -> AutocompleteViewController {
        let storyboard = UIStoryboard(name: "Autocomplete", bundle: nil)
        guard let controller = storyboard.instantiateInitialViewController() as? AutocompleteViewController else {
            fatalError("Failed to instatiate correct Autocomplete view controller")
        }
        controller.bookmarksDatabase = bookmarksDatabase
        controller.historyCoordinator = historyCoordinator
        controller.appSettings = appSettings
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        applyTheme(ThemeManager.shared.currentTheme)

        queryDebounceCancellable = $query
            .debounce(for: .milliseconds(Constants.debounceDelay), scheduler: RunLoop.main)
            .sink { [weak self] query in
                self?.requestSuggestions(query: query)
            }
    }
    
    private func configureTableView() {
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
        tableView.sectionFooterHeight = 1.0 / UIScreen.main.scale
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustForInCall()
        configureNavigationBar()
    }

    // If auto complete is used after the in-call banner is shown it has the wrong y position (should be zero)
    private func adjustForInCall() {
        let frame = self.view.frame
        self.view.frame = CGRect(x: 0, y: shouldOffsetY ? 45.5 : 0, width: frame.width, height: frame.height)
    }

    private func configureNavigationBar() {
        hidesBarsOnSwipeDefault = navigationController?.hidesBarsOnSwipe ?? hidesBarsOnSwipeDefault
        navigationController?.hidesBarsOnSwipe = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetNavigationBar()
    }

    private func resetNavigationBar() {
        navigationController?.hidesBarsOnSwipe = hidesBarsOnSwipeDefault
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tableView.reloadData()
    }

    func updateQuery(query: String) {
        selectedItem = -1
        cancelInFlightRequests()
        self.query = query
    }
    
    func willDismiss(with query: String) {
        guard suggestions.indices.contains(selectedItem) else { return }
        let suggestion = suggestions[selectedItem]
        firePixelForSelectedSuggestion(suggestion)
    }

    private func firePixelForSelectedSuggestion(_ suggestion: Suggestion) {
        switch suggestion {
        case .phrase:
            Pixel.fire(pixel: .autocompleteClickPhrase)
        case .website:
            Pixel.fire(pixel: .autocompleteClickWebsite)
        case .bookmark(_, _, isFavorite: let isFavorite, _):
            Pixel.fire(pixel: isFavorite ? .autocompleteClickFavorite : .autocompleteClickBookmark)
        case .historyEntry:
            Pixel.fire(pixel: .autocompleteClickHistory)
        case .unknown(value: let value):
            assertionFailure("Unknown suggestion \(value)")
        }
    }

    @IBAction func onPlusButtonPressed(_ button: UIButton) {
        let suggestion = suggestions[button.tag]
        delegate?.autocomplete(pressedPlusButtonForSuggestion: suggestion)
    }

    private func cancelInFlightRequests() {
        task?.cancel()
        task = nil
    }

    private func requestSuggestions(query: String) {
        selectedItem = -1
        tableView.reloadData()

        loader = SuggestionLoader(dataSource: self, urlFactory: { phrase in
            guard let url = URL(trimmedAddressBarString: phrase),
                  let scheme = url.scheme,
                  scheme.description.hasPrefix("http"),
                  url.isValid else {
                return nil
            }

            return url
        })
        pendingRequest = true

        loader?.getSuggestions(query: query) { [weak self] result, error in
            defer {
                self?.pendingRequest = false
            }
            guard error == nil else { return }
            self?.updateSuggestions(result?.all ?? [])
        }
    }

    private func updateSuggestions(_ newSuggestions: [Suggestion]) {
        receivedResponse = true
        suggestions = newSuggestions
        tableView.contentOffset = .zero
        tableView.reloadData()
        presentationDelegate?.autocompleteDidChangeContentHeight(height: tableView.contentSize.height)
    }

    @IBAction func onAutocompleteDismissed(_ sender: Any) {
        delegate?.autocompleteWasDismissed()
    }
}

extension AutocompleteViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if suggestions.isEmpty {
            return noSuggestionsCell(forIndexPath: indexPath)
        }
        return suggestionsCell(forIndexPath: indexPath)
    }

    private func suggestionsCell(forIndexPath indexPath: IndexPath) -> UITableViewCell {
        let type = SuggestionTableViewCell.reuseIdentifier
        guard let cell = tableView.dequeueReusableCell(withIdentifier: type, for: indexPath) as? SuggestionTableViewCell else {
            fatalError("Failed to dequeue \(type) as SuggestionTableViewCell")
        }
        
        let currentTheme = ThemeManager.shared.currentTheme
        
        cell.updateFor(query: query,
                       suggestion: suggestions[indexPath.row],
                       with: currentTheme,
                       isAddressBarAtBottom: appSettings.currentAddressBarPosition.isBottom)
        cell.plusButton.tag = indexPath.row
        
        let baseBackgroundColor = isPad ? UIColor(designSystemColor: .panel) : UIColor(designSystemColor: .background)
        let backgroundColor = indexPath.row == selectedItem ? currentTheme.tableCellSelectedColor : baseBackgroundColor

        cell.backgroundColor = backgroundColor
        cell.tintColor = currentTheme.autocompleteCellAccessoryColor

        return cell
    }

    private func noSuggestionsCell(forIndexPath indexPath: IndexPath) -> UITableViewCell {
        let type = NoSuggestionsTableViewCell.reuseIdentifier
        guard let cell = tableView.dequeueReusableCell(withIdentifier: type, for: indexPath) as? NoSuggestionsTableViewCell else {
            fatalError("Failed to dequeue \(type) as NoSuggestionTableViewCell")
        }
        
        let currentTheme = ThemeManager.shared.currentTheme
        cell.backgroundColor = appSettings.currentAddressBarPosition.isBottom ?
            UIColor(designSystemColor: .background) :
            UIColor(designSystemColor: .panel)

        cell.tintColor = currentTheme.autocompleteCellAccessoryColor
        cell.label?.textColor = currentTheme.tableCellTextColor

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if appSettings.currentAddressBarPosition.isBottom && suggestions.isEmpty {
            return view.frame.height
        }
        return 46
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receivedResponse ? max(Constants.minItems, suggestions.count) : 0
    }

}

extension AutocompleteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let suggestion = suggestions[indexPath.row]
        delegate?.autocomplete(selectedSuggestion: suggestion)
        firePixelForSelectedSuggestion(suggestion)
    }
}

extension AutocompleteViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return tableView == touch.view
    }
}

extension AutocompleteViewController: Themable {
    func decorate(with theme: Theme) {
        tableView.separatorColor = theme.tableCellSeparatorColor
        tableView.reloadData()
    }
}

extension AutocompleteViewController {
 
    func keyboardMoveSelectionDown() {
        guard !pendingRequest, !suggestions.isEmpty else { return }
        selectedItem = (selectedItem + 1 >= itemCount()) ? 0 : selectedItem + 1
        delegate?.autocomplete(highlighted: suggestions[selectedItem], for: query)
        tableView.reloadData()
    }

    func keyboardMoveSelectionUp() {
        guard !pendingRequest, !suggestions.isEmpty else { return }
        selectedItem = (selectedItem - 1 < 0) ? itemCount() - 1 : selectedItem - 1
        delegate?.autocomplete(highlighted: suggestions[selectedItem], for: query)
        tableView.reloadData()
    }
    
    func keyboardEscape() {
        delegate?.autocompleteWasDismissed()
    }
    
    private func itemCount() -> Int {
        return suggestions.count
    }

}

extension AutocompleteViewController: SuggestionLoadingDataSource {
    
    func history(for suggestionLoading: Suggestions.SuggestionLoading) -> [HistorySuggestion] {
        return historyCoordinator.history ?? []
    }

    func bookmarks(for suggestionLoading: Suggestions.SuggestionLoading) -> [Suggestions.Bookmark] {
        return cachedBookmarks.all
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

extension HistoryEntry: HistorySuggestion {

    public var numberOfVisits: Int {
        return numberOfTotalVisits
    }

}
