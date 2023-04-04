//
//  SuggestionTrayViewController.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
import Bookmarks

class SuggestionTrayViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var variableWidthConstraint: NSLayoutConstraint!
    @IBOutlet var fullWidthConstraint: NSLayoutConstraint!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var variableHeightConstraint: NSLayoutConstraint!
    @IBOutlet var fullHeightConstraint: NSLayoutConstraint!
    
    weak var autocompleteDelegate: AutocompleteViewControllerDelegate?
    weak var favoritesOverlayDelegate: FavoritesOverlayDelegate?
    
    var dismissHandler: (() -> Void)?
    
    private let appSettings = AppUserDefaults()

    private var autocompleteController: AutocompleteViewController?
    private var favoritesOverlay: FavoritesOverlay?
    private var willRemoveAutocomplete = false
    private let bookmarksSearch: BookmarksStringSearch
    private let favoritesModel: FavoritesListInteracting

    var selectedSuggestion: Suggestion? {
        autocompleteController?.selectedSuggestion
    }
    
    enum SuggestionType: Equatable {
    
        case autocomplete(query: String)
        case favorites
        
        func hideOmnibarSeparator() -> Bool {
            switch self {
            case .autocomplete: return true
            case .favorites: return false
            }
        }
        
        static func == (lhs: SuggestionTrayViewController.SuggestionType, rhs: SuggestionTrayViewController.SuggestionType) -> Bool {
            switch (lhs, rhs) {
            case let (.autocomplete(queryLHS), .autocomplete(queryRHS)):
                return queryLHS == queryRHS
            case (.favorites, .favorites):
                return true
            default:
                return false
            }
        }
    }
    
    required init?(coder: NSCoder, favoritesViewModel: FavoritesListInteracting, bookmarksSearch: BookmarksStringSearch) {
        self.favoritesModel = favoritesViewModel
        self.bookmarksSearch = bookmarksSearch
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        installDismissHandler()
    }

    @IBAction func onDismiss() {
        dismissHandler?()
    }
    
    override var canBecomeFirstResponder: Bool { return true }
    
    func canShow(for type: SuggestionType) -> Bool {
        var canShow = false
        switch type {
        case .autocomplete(let query):
            canShow = canDisplayAutocompleteSuggestions(forQuery: query)
        case.favorites:
            canShow = canDisplayFavorites
        }
        return canShow
    }
    
    func show(for type: SuggestionType) {
        switch type {
        case .autocomplete(let query):
            displayAutocompleteSuggestions(forQuery: query)
        case .favorites:
            if isPad {
                removeAutocomplete()
                displayFavoritesIfNeeded()
            } else {
                willRemoveAutocomplete = true
                displayFavoritesIfNeeded { [weak self] in
                    self?.removeAutocomplete()
                    self?.willRemoveAutocomplete = false
                }
            }
        }
    }
    
    func willDismiss(with query: String) {
        guard !query.isEmpty else { return }
        
        if let autocomplete = autocompleteController {
            autocomplete.willDismiss(with: query)
        }
    }
    
    var contentFrame: CGRect {
        return containerView.frame
    }
    
    func didHide() {
        removeAutocomplete()
        removeFavorites()
    }
    
    @objc func keyboardMoveSelectionDown() {
        autocompleteController?.keyboardMoveSelectionDown()
    }

    @objc func keyboardMoveSelectionUp() {
        autocompleteController?.keyboardMoveSelectionUp()
    }
    
    func float(withWidth width: CGFloat) {
        autocompleteController?.showBackground = false
        
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
 
        backgroundView.layer.cornerRadius = 16
        backgroundView.backgroundColor = ThemeManager.shared.currentTheme.tableCellBackgroundColor
        backgroundView.clipsToBounds = false
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOffset = .init(width: 0, height: 10)
        backgroundView.layer.shadowOpacity = 0.3
        backgroundView.layer.shadowRadius = 120

        topConstraint.constant = 15
        
        let isFirstPresentation = fullHeightConstraint.isActive
        if isFirstPresentation {
            variableHeightConstraint.constant = SuggestionTableViewCell.Constants.cellHeight * 6
        }
        
        variableWidthConstraint.constant = width
        fullWidthConstraint.isActive = false
        fullHeightConstraint.isActive = false
    }
    
    func fill() {
        autocompleteController?.showBackground = true

        containerView.layer.shadowColor = UIColor.clear.cgColor
        containerView.layer.cornerRadius = 0

        containerView.subviews.first?.layer.masksToBounds = false
        containerView.subviews.first?.layer.cornerRadius = 0
        backgroundView.layer.masksToBounds = false
        backgroundView.layer.cornerRadius = 0
        backgroundView.backgroundColor = UIColor.clear

        topConstraint.constant = 0
        fullWidthConstraint.isActive = true
        fullHeightConstraint.isActive = true
    }
    
    private func installDismissHandler() {
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(onDismiss))
        backgroundTap.cancelsTouchesInView = false
        
        let foregroundTap = UITapGestureRecognizer()
        foregroundTap.cancelsTouchesInView = false
        
        backgroundTap.require(toFail: foregroundTap)
        
        view.addGestureRecognizer(backgroundTap)
        containerView.addGestureRecognizer(foregroundTap)
    }
    
    private var canDisplayFavorites: Bool {
        favoritesModel.favorites.count > 0
    }
    
    private func displayFavoritesIfNeeded(onInstall: @escaping () -> Void = {}) {
        if favoritesOverlay == nil {
            installFavoritesOverlay(onInstall: onInstall)
        }
    }
    
    private func installFavoritesOverlay(onInstall: @escaping () -> Void = {}) {
        let controller = FavoritesOverlay(favoritesViewModel: favoritesModel)
        controller.delegate = favoritesOverlayDelegate
        install(controller: controller, completion: onInstall)
        favoritesOverlay = controller
    }
    
    private func canDisplayAutocompleteSuggestions(forQuery query: String) -> Bool {
        let canDisplay = appSettings.autocomplete && !query.isEmpty
        if !canDisplay {
            removeAutocomplete()
        }
        return canDisplay
    }
    
    private func displayAutocompleteSuggestions(forQuery query: String) {
        if autocompleteController == nil {
            installAutocompleteSuggestions()
        }
        autocompleteController?.updateQuery(query: query)
    }
    
    private func installAutocompleteSuggestions() {
        let controller = AutocompleteViewController.loadFromStoryboard(bookmarksSearch: bookmarksSearch)
        install(controller: controller)
        controller.delegate = autocompleteDelegate
        controller.presentationDelegate = self
        autocompleteController = controller
    }

    private func removeAutocomplete() {
        guard let controller = autocompleteController else { return }
        controller.removeFromParent()
        controller.view.removeFromSuperview()
        autocompleteController = nil
    }
    
    private func removeFavorites() {
        guard let controller = favoritesOverlay else { return }
        controller.removeFromParent()
        controller.view.removeFromSuperview()
        favoritesOverlay = nil
    }
    
    private func install(controller: UIViewController, completion: @escaping () -> Void = {}) {
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
        controller.view.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
            controller.view.alpha = 1
        }, completion: { _ in
            completion()
        })
    }
    
    func applyContentInset(_ inset: UIEdgeInsets) {
        autocompleteController?.tableView.contentInset = inset
        favoritesOverlay?.collectionView.contentInset = inset
    }
}

extension SuggestionTrayViewController: AutocompleteViewControllerPresentationDelegate {
    
    func autocompleteDidChangeContentHeight(height: CGFloat) {
        if autocompleteController != nil && !willRemoveAutocomplete {
            removeFavorites()
        }
        
        guard !fullHeightConstraint.isActive else { return }
        
        if height > variableHeightConstraint.constant {
            variableHeightConstraint.constant = height
        }
    }
    
}

extension SuggestionTrayViewController: Themable {
    
    // Only gets called if system theme changes while tray is open
    func decorate(with theme: Theme) {
        // only update the color if one has been set
        if backgroundView.backgroundColor != nil {
            backgroundView.backgroundColor = theme.tableCellBackgroundColor
        }
    }
    
}
