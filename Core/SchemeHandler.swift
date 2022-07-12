//
//  SchemeHandler.swift
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

public class SchemeHandler {
    
    public enum Action: Equatable {
        case open
        case askForConfirmation
        case cancel
    }
    
    public enum SchemeType: Equatable {
        case navigational
        case external(Action)
        case blob
        case unknown
    }
    
    public enum NavigationalScheme: String {
        case http
        case https
        case ftp
        case file
        case data
        case blob
        case about
    }
    
    private enum PlatformScheme: String {
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
    
    private enum BlockedScheme: String {
        case appleDataDetectors = "x-apple-data-detectors"
    }
    
    public static func schemeType(for url: URL) -> SchemeType {
        guard let schemeString = url.scheme else { return .unknown }
        
        guard BlockedScheme(rawValue: schemeString) == nil else {
            return .external(.cancel)
        }

        switch NavigationalScheme(rawValue: schemeString) {
        case .none:
            break
        case .blob:
            return .blob
        default:
            return .navigational
        }
        
        if let scheme = PlatformScheme(rawValue: schemeString) {
            
            switch scheme {
            case .sms, .mailto, .itms, .itmss, .itunes, .itmsApps, .itmsAppss:
                return .external(.askForConfirmation)
            default:
                return .external(.open)
            }
        }
        
        return .unknown
    }
    
}
