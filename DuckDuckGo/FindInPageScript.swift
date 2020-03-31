//
//  FindInPageScript.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 31/03/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import Core
import WebKit

public class FindInPageScript: NSObject, UserScript {

    public lazy var source: String = {
        return loadJS("findinpage")
    }()
    
    public var injectionTime: WKUserScriptInjectionTime = .atDocumentStart
    
    public var forMainFrameOnly: Bool = false
    
    public var messageNames: [String] = ["findInPageHandler"]
    
    var findInPage: FindInPage?
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let dict = message.body as? [String: Any] else { return }
        let currentResult = dict["currentResult"] as? Int
        let totalResults = dict["totalResults"] as? Int
        findInPage?.update(currentResult: currentResult, totalResults: totalResults)
    }
    
    deinit {
        print("*** deinit FIPS")
    }
    
}
