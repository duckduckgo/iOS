//
//  JavascriptLoader.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 24/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation
import WebKit

public enum ScriptFile: String {
    case documentExtension
}

public class JavascriptLoader {
    
    public func load(_ scriptFile: ScriptFile, withController controller: WKUserContentController) {
        let bundle = Bundle(for: JavascriptLoader.self)
        let path = bundle.path(forResource: scriptFile.rawValue, ofType: "js")!
        let scriptString = try! String(contentsOfFile: path)
        let script = WKUserScript(source: scriptString, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        controller.addUserScript(script)
    }
}
