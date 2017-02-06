//
//  Version.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 30/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public struct Version {
    
    public struct Keys {
        static let name = kCFBundleNameKey as String
        static let buildNumber = kCFBundleVersionKey as String
        static let versionNumber = "CFBundleShortVersionString"
    }
    
    private let bundle: InfoBundle
    
    init(bundle: InfoBundle) {
        self.bundle = bundle
    }
    
    init() {
        self.init(bundle: Bundle.main)
    }
    
    func name() -> String? {
        return bundle.object(forInfoDictionaryKey: Version.Keys.name) as? String
    }
    
    func versionNumber() -> String? {
        return bundle.object(forInfoDictionaryKey: Version.Keys.versionNumber) as? String
    }
    
    func buildNumber() -> String? {
        return bundle.object(forInfoDictionaryKey: Version.Keys.buildNumber) as? String
    }
    
    func localized() -> String? {
        guard let name = name(), let versionNumber = versionNumber(), let buildNumber = buildNumber() else {
            return nil
        }
        
        guard (versionNumber != buildNumber) else {
            return String.localizedStringWithFormat(UserText.appInfo, name, versionNumber)
        }
        
        return String.localizedStringWithFormat(UserText.appInfoWithBuild, name, versionNumber, buildNumber)
    }
}

