//
//  UserText.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 24/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public struct UserText {
    
    public static let appTitle = NSLocalizedString("app.title", comment: "App title DuckDuckGo")
    public static let appInfo = NSLocalizedString("app.info" , comment: "App name and version number")
    public static let appInfoWithBuild = NSLocalizedString("app.infoWithBuild" , comment: "App name, version and build number")
    
    public static let searchDuckDuckGo = NSLocalizedString("search.hint.duckduckgo", comment: "Search bar hint")
    
    public static let webSessionCleared = NSLocalizedString("web.session.clear", comment: "Web session cleared / deleted")
    public static let webSaveLinkDone = NSLocalizedString("web.url.save.done", comment: "Confirmation message when quick link saved to the today extension")
}
