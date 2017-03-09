//
//  AutocompleteViewControllerDelegate.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 09/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation


protocol AutocompleteViewControllerDelegate {
    
    func autocomplete(selectedSuggestion suggestion: String)
}
