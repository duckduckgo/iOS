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
    private let homePageSettings = DefaultHomePageSettings()
    private let bookmarkStore: BookmarkStore = BookmarkUserDefaults()

    private var autocompleteController: AutocompleteViewController?
    private var favoritesOverlay: FavoritesOverlay?
    
    enum SuggestionType: Equatable {
        
        case autocomplete(query: String)
        case favorites
        
        func hideOmnibarSeparator() -> Bool {
            switch self {
            case .autocomplete: return true
            case .favorites: return false
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        installDismissHandler()
    }

    @IBAction func onDismiss() {
        dismissHandler?()
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
    
    func float(withWidth width: CGFloat) {
        containerView.clipsToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = .zero
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowRadius = 64

        containerView.subviews.first?.layer.masksToBounds = true
        containerView.subviews.first?.layer.cornerRadius = 16

        topConstraint.constant = 15
        variableHeightConstraint.constant = 276
        variableWidthConstraint.constant = width
        fullWidthConstraint.isActive = false
        fullHeightConstraint.isActive = false
    }
    
    func fill() {
        containerView.layer.shadowColor = UIColor.clear.cgColor
        containerView.layer.cornerRadius = 0

        containerView.subviews.first?.layer.masksToBounds = false
        containerView.subviews.first?.layer.cornerRadius = 0

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
    
    private func displayFavorites() -> Bool {
        guard homePageSettings.favorites, !bookmarkStore.favorites.isEmpty else { return false }

        if favoritesOverlay == nil {
            let controller = FavoritesOverlay()
            controller.delegate = favoritesOverlayDelegate
            install(controller: controller)
            favoritesOverlay = controller
        }
        
        return true
    }
    
    private func displayAutocompleteSuggestions(forQuery query: String) -> Bool {
        guard appSettings.autocomplete && !query.isEmpty else { return false }
        
        if autocompleteController == nil {
            let controller = AutocompleteViewController.loadFromStoryboard()
            install(controller: controller)
            controller.delegate = autocompleteDelegate
            autocompleteController = controller
        }
        
        autocompleteController?.updateQuery(query: query)
        return true
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
    
    private func install(controller: UIViewController) {
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
        controller.view.alpha = 0
        UIView.animate(withDuration: 0.2) {
            controller.view.alpha = 1
        }
        
    }
    
}
