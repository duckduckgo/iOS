//
//  OmniBar.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 17/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class OmniBar: UISearchBar {

    weak var omniDelegate: OmniBarDelegate?
    
    init() {
        super.init(frame: .zero)
        placeholder = UserText.searchDuckDuckGo
        textColor = UIColor.darkGray
        tintColor = UIColor.accent
        autocapitalizationType = .none
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshText(forUrl url: URL?) {
        guard let url = url else {
            text = nil
            return
        }
        
        if let query = AppUrls.searchQuery(fromUrl: url) {
            text = query
            return
        }
        
        if AppUrls.isDuckDuckGo(url: url) {
            text = nil
            return
        }
        
        text = url.absoluteString
    }
    
    func onQuerySubmitted() {
        resignFirstResponder()
        guard let query = text?.trimWhitespace() else {
            return
        }
        if let omniDelegate = omniDelegate {
            omniDelegate.onOmniQuerySubmitted(query)
        }
    }
}

extension OmniBar: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        onQuerySubmitted()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        onQuerySubmitted()
    }
}
