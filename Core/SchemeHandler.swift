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
import BrowserServicesKit

public class SchemeHandler {

    public enum Action: Equatable {
        case open
        case askForConfirmation
        case cancel
    }

    public enum SchemeType: Equatable {
        case allow
        case navigational
        case external(Action)
        case blob
        case unknown
        case duck
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
        case shortcuts
        case shortcutsProduction = "shortcuts-production"
        case workflow
        case marketplaceKit = "marketplace-kit"
    }

    private enum BlockedScheme: String {
        case appleDataDetectors = "x-apple-data-detectors"
    }

    public static func schemeType(for url: URL) -> SchemeType {
        guard let schemeString = url.scheme else { return .unknown }

        guard BlockedScheme(rawValue: schemeString) == nil else {
            return .external(.cancel)
        }

        let scheme = URL.NavigationalScheme(rawValue: schemeString)
        if case .blob = scheme {
            return .blob
        } else if case .duck = scheme {
            return .duck
        } else if URL.NavigationalScheme.navigationalSchemes.contains(scheme) {
            return .navigational
        }

        switch PlatformScheme(rawValue: schemeString) {
        case .marketplaceKit:
            // marketplaceKit urls have to be allowed through without interference
            if #available(iOS 17.4, *) {
                return .allow
            } else {
                return .unknown
            }
        case .sms, .mailto, .itms, .itmss, .itunes, .itmsApps, .itmsAppss, .shortcuts, .shortcutsProduction, .workflow:
            return .external(.askForConfirmation)
        case .none:
            return .unknown
        default:
            return .external(.open)
        }
        
        
    }

}
