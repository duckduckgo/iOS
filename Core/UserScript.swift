//
//  UserScript.swift
//  Core
//
//  Created by Chris Brind on 31/03/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import WebKit

public protocol UserScript: WKScriptMessageHandler {
        
    var source: String { get }
    var injectionTime: WKUserScriptInjectionTime { get }
    var forMainFrameOnly: Bool { get }
    
    var messageNames: [String] { get }
    
}

extension UserScript {
    
    public func loadJS(_ jsFile: String, withReplacements replacements: [String: String] = [:]) -> String {
        
        let bundle = Bundle(for: JavascriptLoader.self)
        let path = bundle.path(forResource: jsFile, ofType: "js")!
        
        guard var js = try? String(contentsOfFile: path) else {
            fatalError("Failed to load JavaScript \(jsFile) from \(path)")
        }
        
        for (key, value) in replacements {
            js = js.replacingOccurrences(of: key, with: value, options: .literal)
        }

        return js
    }
    
}
