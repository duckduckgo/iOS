//
//  ExternalSchemeHandler.swift
//  Core
//
//  Created by Bartek on 14/11/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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
    
    // Enum FTW
    private static let whitelistedSchemes: Set<String> = [
        "tel",
        "mailto",
        "maps",
        "sms",
        "itms",
        "itmss",
        "itms-apps",
        "itms-appss",
        "itunes"
    ]

    private static let blacklistedSchemes: Set<String> = [
        "about"
    ]
    
    public static func schemeType(for url: URL) -> SchemeType {
        guard let scheme = url.scheme else { return .other }
        
        guard !blacklistedSchemes.contains(scheme) else {
            return .external(.cancel)
        }
        
        if whitelistedSchemes.contains(scheme) {
            
            if scheme == "sms" {
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
