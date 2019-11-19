//
//  ExternalSchemeHandler.swift
//  Core
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

public class ExternalSchemeHandler {
    
    public enum Action: Equatable {
        case open
        case askForConfirmation
        case cancel
    }
    
    public enum SchemeType {
        case external(Action)
        case other
    }
    
    private enum WhitelistedScheme: String {
        case tel
        case mailto
        case maps
        case sms
        case facetime
        case facetimeAudio = "facetime-audio"
        case itms
        case itmss
        case itmsApps = "itms-apps"
        case itmsAppss = "itms-appss"
        case itunes
    }
    
    private enum BlacklistedScheme: String {
        case about
        case appleDataDetectors = "x-apple-data-detectors"
    }
    
    public static func schemeType(for url: URL) -> SchemeType {
        guard let schemeString = url.scheme else { return .other }
        
        guard BlacklistedScheme(rawValue: schemeString) == nil else {
            return .external(.cancel)
        }
        
        if let scheme = WhitelistedScheme(rawValue: schemeString) {
            
            if scheme == .sms || scheme == .mailto {
                return .external(.askForConfirmation)
            }
            
            return .external(.open)
        }
        
        return .other
    }
    
}

extension ExternalSchemeHandler.SchemeType: Equatable {
    
    static public func == (lhs: ExternalSchemeHandler.SchemeType,
                           rhs: ExternalSchemeHandler.SchemeType) -> Bool {
        switch (lhs, rhs) {
        case (.other, .other):
            return true
        case (.external(let la), .external(let ra)):
            return la == ra
        default:
            return false
        }
    }
}
