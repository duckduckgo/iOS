//
//  TextSizeUserScript.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

import Foundation
import BrowserServicesKit
import WebKit

public class TextSizeUserScript: NSObject, UserScript {

    public var textSizeAdjustmentInPercents: Int = 100
    
    public var source: String {
        let dynamicTypeScalePercentage = UIFontMetrics.default.scaledValue(for: 100)
        
        return Self.loadJS("textsize", from: Bundle.core, withReplacements: [
            "$TEXT_SIZE_ADJUSTMENT_IN_PERCENTS$": "\(textSizeAdjustmentInPercents)",
            "$DYNAMIC_TYPE_SCALE_PERCENTAGE$": "\(dynamicTypeScalePercentage)"
        ])
    }

    public var injectionTime: WKUserScriptInjectionTime = .atDocumentStart
    public var forMainFrameOnly: Bool = false
    public var messageNames: [String] = []

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) { }
}

public extension WKWebView {
    
    func adjustTextSize(_ percentage: Int) {
        let dynamicTypeScalePercentage = UIFontMetrics.default.scaledValue(for: 100)
        let jsString = TextSizeUserScript.loadJS("textsize", from: Bundle.core, withReplacements: [
            "$TEXT_SIZE_ADJUSTMENT_IN_PERCENTS$": "\(percentage)",
            "$DYNAMIC_TYPE_SCALE_PERCENTAGE$": "\(dynamicTypeScalePercentage)"
        ])
        
        evaluateJavaScript(jsString, completionHandler: nil)
    }
}
