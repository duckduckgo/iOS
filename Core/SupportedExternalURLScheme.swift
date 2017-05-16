//
//  SupportedExternalURLScheme.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 05/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public enum SupportedExternalURLScheme: String {
    
    case tel
    case mailto
    case maps
    case sms
    
    public static func isSupported(url: URL) -> Bool {
        guard let scheme = url.scheme else { return false }
        return SupportedExternalURLScheme.init(rawValue: scheme) != nil
    }
}
