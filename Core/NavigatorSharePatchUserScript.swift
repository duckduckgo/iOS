//
//  NavigatorSharePatchUserScript.swift
//  Core
//
//  Created by Brad Slayter on 8/26/20.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit
import WebKit

public class NavigatorSharePatchUserScript: NSObject, UserScript {
    public var source: String {
        return loadJS("navigatorsharepatch")
    }
    
    public var injectionTime: WKUserScriptInjectionTime = .atDocumentStart
    
    public var forMainFrameOnly: Bool = false
    
    public var messageNames: [String] = []
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
    

}
