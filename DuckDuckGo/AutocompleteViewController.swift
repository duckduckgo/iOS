//
//  AutocompleteViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 08/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class AutocompleteViewController: UIViewController {

    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    weak var delegate: AutocompleteViewControllerDelegate?

    private lazy var parser = AutocompleteParser()
    private var lastRequest: AutocompleteRequest?
    
    fileprivate var query = ""
    fileprivate var suggestions = [Suggestion]()
    fileprivate let minItems = 1
    fileprivate let maxItems = 6
    
    private var hidesBarsOnSwipeDefault = true
    private var isToolbarEnabledDefault = true

    @IBOutlet weak var tableView: UITableView!
    
    static func loadFromStoryboard() -> AutocompleteViewController {
        let storyboard = UIStoryboard.init(name: "Autocomplete", bundle: nil)
        return storyboard.instantiateInitialViewController() as! AutocompleteViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    private func configureNavigationBar() {
        hidesBarsOnSwipeDefault = navigationController?.hidesBarsOnSwipe ?? hidesBarsOnSwipeDefault
        isToolbarEnabledDefault = navigationController?.toolbar.isUserInteractionEnabled ?? isToolbarEnabledDefault
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.toolbar.isUserInteractionEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetNaviagtionBar()
    }

    private func resetNaviagtionBar() {
        navigationController?.hidesBarsOnSwipe = hidesBarsOnSwipeDefault
        navigationController?.toolbar.isUserInteractionEnabled = isToolbarEnabledDefault
    }
    
    func updateQuery(query: String) {
        self.query = query
        cancelInFlightRequests()
        requestSuggestions(query: query)
    }
    
    @IBAction func onPlusButtonPressed(_ button: UIButton) {
        let suggestion = suggestions[button.tag]
        delegate?.autocomplete(pressedPlusButtonForSuggestion: suggestion.suggestion)
    }
    
    private func cancelInFlightRequests() {
        if let inFlightRequest = lastRequest {
            inFlightRequest.cancel()
        }
    }
    
    private func requestSuggestions(query: String) {
        lastRequest = AutocompleteRequest(query: query, parser: parser)
        lastRequest!.execute() { [weak self] (suggestions, error) in
            guard let suggestions = suggestions, error == nil else {
                Logger.log(items: error ?? "Failed to retrieve suggestions")
                return
            }
            self?.updateSuggestions(suggestions)
        }
    }
    
    private func updateSuggestions(_ newSuggestions: [Suggestion]) {
        suggestions = newSuggestions
        tableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: type, for: indexPath) as! SuggestionTableViewCell
        cell.updateFor(query: query, suggestion: suggestions[indexPath.row])
        cell.plusButton.tag = indexPath.row
        return cell
    }
    
    private func noSuggestionsCell(forIndexPath indexPath: IndexPath) -> UITableViewCell {
        let type = NoSuggestionsTableViewCell.reuseIdentifier
        return tableView.dequeueReusableCell(withIdentifier: type, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if suggestions.isEmpty {
            return minItems
        }
        if suggestions.count > maxItems {
            return maxItems
        }
        return suggestions.count
    }
}

extension AutocompleteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let suggestion = suggestions[indexPath.row]
        delegate?.autocomplete(selectedSuggestion: suggestion.suggestion)
    }
}
