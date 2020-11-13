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

import UIKit
import Core
import os.log

class AutocompleteViewController: UIViewController {
    
    struct Constants {
        static let debounceDelay: TimeInterval = {
            if #available(iOS 13.0, *) {
                return 0.1
            }
            return 0.3
        }()
        
        static let minItems = 1
        static let maxLocalItems = 2
    }

    weak var delegate: AutocompleteViewControllerDelegate?
    weak var presentationDelegate: AutocompleteViewControllerPresentationDelegate?

    private var lastRequest: AutocompleteRequest?
    private var receivedResponse = false
    private var pendingRequest = false
    
    fileprivate var query = ""
    fileprivate var suggestions = [Suggestion]()
    fileprivate var selectedItem = -1
    
    private let bookmarksSearch = BookmarksSearch()

    var showBackground = true {
        didSet {
            view.backgroundColor = showBackground ? UIColor.black.withAlphaComponent(0.2) : UIColor.clear
        }
    }
    
    private var hidesBarsOnSwipeDefault = true
    
    private let debounce = Debounce(queue: .main, seconds: Constants.debounceDelay)

    @IBOutlet weak var tableView: UITableView!
    var shouldOffsetY = false
    
    static func loadFromStoryboard() -> AutocompleteViewController {
        let storyboard = UIStoryboard(name: "Autocomplete", bundle: nil)
        guard let controller = storyboard.instantiateInitialViewController() as? AutocompleteViewController else {
            fatalError("Failed to instatiate correct Autocomplete view controller")
        }
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        applyTheme(ThemeManager.shared.currentTheme)
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
        resetNaviagtionBar()
    }

    private func resetNaviagtionBar() {
        navigationController?.hidesBarsOnSwipe = hidesBarsOnSwipeDefault
    }

    func updateQuery(query: String) {
        self.query = query
        selectedItem = -1
        cancelInFlightRequests()
        debounce.schedule { [weak self] in
            self?.requestSuggestions(query: query)
        }
    }
    
    func willDismiss(with query: String) {
        guard selectedItem != -1, selectedItem < suggestions.count else { return }
        
        let suggestion = suggestions[selectedItem]
        if let url = suggestion.url {
            if query == url.absoluteString {
                firePixel(selectedSuggestion: suggestion)
            }
        } else if query == suggestion.suggestion {
            firePixel(selectedSuggestion: suggestion)
        }
    }

    @IBAction func onPlusButtonPressed(_ button: UIButton) {
        let suggestion = suggestions[button.tag]
        delegate?.autocomplete(pressedPlusButtonForSuggestion: suggestion)
    }

    private func cancelInFlightRequests() {
        if let inFlightRequest = lastRequest {
            inFlightRequest.cancel()
            lastRequest = nil
        }
    }

    private func requestSuggestions(query: String) {
        selectedItem = -1
        tableView.reloadData()
        pendingRequest = true
        
        lastRequest = AutocompleteRequest(query: query)
        lastRequest!.execute { [weak self] (suggestions, error) in
            guard let strongSelf = self else { return }
            
            let matches = strongSelf.bookmarksSearch.search(query: query)
            let notQueryMatches = matches.filter { $0.url.absoluteString != query }
            let filteredMatches = notQueryMatches.filter { $0.displayTitle != nil }.prefix(Constants.maxLocalItems)
            let localSuggestions = filteredMatches.map { Suggestion(type: "", suggestion: $0.displayTitle!, url: $0.url)}
            
            guard let suggestions = suggestions, error == nil else {
                os_log("%s", log: generalLog, type: .debug, error?.localizedDescription ?? "Failed to retrieve suggestions")
                self?.updateSuggestions(localSuggestions)
                return
            }

            let combinedSuggestions = localSuggestions + suggestions
            strongSelf.updateSuggestions(Array(combinedSuggestions))
            strongSelf.pendingRequest = false
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
        cell.updateFor(query: query, suggestion: suggestions[indexPath.row])
        cell.plusButton.tag = indexPath.row
        
        let currentTheme = ThemeManager.shared.currentTheme
        
        let color = indexPath.row == selectedItem ? currentTheme.tableCellSelectedColor : currentTheme.tableCellBackgroundColor
        
        cell.backgroundColor = color
        cell.tintColor = currentTheme.autocompleteCellAccessoryColor
        cell.label?.textColor = currentTheme.tableCellTextColor
        cell.setHighlightedStateBackgroundColor(currentTheme.tableCellHighlightedBackgroundColor)
        
        return cell
    }

    private func noSuggestionsCell(forIndexPath indexPath: IndexPath) -> UITableViewCell {
        let type = NoSuggestionsTableViewCell.reuseIdentifier
        guard let cell = tableView.dequeueReusableCell(withIdentifier: type, for: indexPath) as? NoSuggestionsTableViewCell else {
            fatalError("Failed to dequeue \(type) as NoSuggestionTableViewCell")
        }
        
        let currentTheme = ThemeManager.shared.currentTheme
        cell.backgroundColor = currentTheme.tableCellBackgroundColor
        cell.tintColor = currentTheme.autocompleteCellAccessoryColor
        cell.label?.textColor = currentTheme.tableCellTextColor
        cell.setHighlightedStateBackgroundColor(currentTheme.tableCellHighlightedBackgroundColor)
        
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receivedResponse ? max(Constants.minItems, suggestions.count) : 0
    }
    
    private func firePixel(selectedSuggestion: Suggestion) {
        let resultsIncludeBookmarks: Bool
        if let firstSuggestion = suggestions.first {
            resultsIncludeBookmarks = firstSuggestion.source == .local
        } else {
            resultsIncludeBookmarks = false
        }
        
        let params = [PixelParameters.autocompleteBookmarkCapable: bookmarksSearch.hasData ? "true" : "false",
                      PixelParameters.autocompleteIncludedLocalResults: resultsIncludeBookmarks ? "true" : "false"]
        
        if selectedSuggestion.source == .local {
            Pixel.fire(pixel: .autocompleteSelectedLocal, withAdditionalParameters: params)
        } else {
            Pixel.fire(pixel: .autocompleteSelectedRemote, withAdditionalParameters: params)
        }
    }
}

extension AutocompleteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let suggestion = suggestions[indexPath.row]
        firePixel(selectedSuggestion: suggestion)
        delegate?.autocomplete(selectedSuggestion: suggestion)
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
