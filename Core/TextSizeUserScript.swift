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
import WebKit
import UserScript

public class TextSizeUserScript: NSObject, UserScript {
    
    public static let knownDynamicTypeExceptions: [String] = ["wikipedia.org"]
    public var textSizeAdjustmentInPercents: Int = 100
    
    public var source: String { TextSizeUserScript.makeSource(for: textSizeAdjustmentInPercents) }

    public var injectionTime: WKUserScriptInjectionTime = .atDocumentStart
    public var forMainFrameOnly: Bool = false
    public var messageNames: [String] = []
    
    public init(textSizeAdjustmentInPercents: Int) {
        self.textSizeAdjustmentInPercents = textSizeAdjustmentInPercents
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) { }
    
    fileprivate static func makeSource(for textSizeAdjustmentInPercents: Int) -> String {
        let dynamicTypeScalePercentage = UIFontMetrics.default.scaledValue(for: 100)
        
        return loadJS("textsize", from: Bundle.core, withReplacements: [
            "$KNOWN_DYNAMIC_TYPE_EXCEPTIONS$": knownDynamicTypeExceptions.joined(separator: "\n"),
            "$TEXT_SIZE_ADJUSTMENT_IN_PERCENTS$": "\(textSizeAdjustmentInPercents)",
            "$DYNAMIC_TYPE_SCALE_PERCENTAGE$": "\(dynamicTypeScalePercentage)"
        ])
    }
}

public extension WKWebView {
    
    func adjustTextSize(_ percentage: Int) {
        let jsString = TextSizeUserScript.makeSource(for: percentage)
        evaluateJavaScript(jsString, completionHandler: nil)
    }
}
