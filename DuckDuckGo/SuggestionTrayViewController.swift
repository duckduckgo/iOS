//
//  SuggestionTrayViewController.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 30/07/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class SuggestionTrayViewController: UIViewController {
    
    private let appSettings = AppUserDefaults()
    private let homePageSettings = DefaultHomePageSettings()
    private let bookmarkStore: BookmarkStore = BookmarkUserDefaults()

    weak var autocompleteDelegate: AutocompleteViewControllerDelegate?
    weak var favoritesOverlayDelegate: FavoritesOverlayDelegate?
    
    private var autocompleteController: AutocompleteViewController?
    private var favoritesOverlay: FavoritesOverlay?
    
    enum SuggestionType {
        
        case autocomplete(query: String)
        case favorites
        
    }

    func willShow(for type: SuggestionType) -> Bool {
        print("***", #function, type)
        
        switch type {
        case .autocomplete(let query):
            removeFavorites()
            return displayAutocompleteSuggestions(forQuery: query)
            
        case.favorites:
            removeAutocomplete()
            return displayFavorites()
        }
        
    }
    
    func didHide() {
        removeAutocomplete()
        removeFavorites()
    }
    
    func keyboardMoveSelectionDown() {
        print("***", #function)
        autocompleteController?.keyboardMoveSelectionDown()
    }

    func keyboardMoveSelectionUp() {
        print("***", #function)
        autocompleteController?.keyboardMoveSelectionUp()
    }

    private func displayFavorites() -> Bool {
        guard homePageSettings.favorites, !bookmarkStore.favorites.isEmpty else { return false }

        if favoritesOverlay == nil {
            let controller = FavoritesOverlay()
            addChild(controller)
            controller.view.frame = view.frame
            view.addSubview(controller.view)
            controller.didMove(toParent: self)

            if let delegate = favoritesOverlayDelegate {
                controller.install(into: delegate)
            }

            controller.view.alpha = 0
            UIView.animate(withDuration: 0.2) {
                controller.view.alpha = 1
            }
            favoritesOverlay = controller
        }
        
        return true
    }
    
    private func displayAutocompleteSuggestions(forQuery query: String) -> Bool {
        guard appSettings.autocomplete && !query.isEmpty else { return false }
        
        if autocompleteController == nil {
            let controller = AutocompleteViewController.loadFromStoryboard()
            controller.delegate = autocompleteDelegate
            addChild(controller)
            view.addSubview(controller.view)
            controller.didMove(toParent: self)
            autocompleteController = controller
        }
        autocompleteController?.updateQuery(query: query)
        return true
    }

    private func removeAutocomplete() {
        guard let controller = autocompleteController else { return }
        controller.removeFromParent()
        controller.view.removeFromSuperview()
        autocompleteDelegate = nil
    }
    
    private func removeFavorites() {
        guard let controller = favoritesOverlay else { return }
        controller.removeFromParent()
        controller.view.removeFromSuperview()
        favoritesOverlay = nil
    }
    
}
