//
//  UserText.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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


import Core


public struct UserText {
    
    public static let appTitle = NSLocalizedString("app.title", comment: "DuckDuckGo")
    public static let appInfo = NSLocalizedString("app.info", comment: "DuckDuckGo version")
    public static let appInfoWithBuild = NSLocalizedString("app.infoWithBuild", comment:  "DuckDuckGo version (build)")
    public static let appUnlock = NSLocalizedString("app.authentication.unlock", comment: "Unlock DuckDuckGo")
    public static let homeLinkTitle = NSLocalizedString("home.link.title", comment: "DuckDuckGo Home")
    public static let searchDuckDuckGo = NSLocalizedString("search.hint.duckduckgo", comment: "Search or type URL")
    public static let webSessionCleared = NSLocalizedString("web.session.clear", comment: "Session cleared")
    public static let webSaveLinkDone = NSLocalizedString("web.url.save.done", comment: "Bookmark saved")
    
    public static let tabSwitcherTitleHasTabs = NSLocalizedString("tabswitcher.title.tabs", comment: "Private Tabs title")
    public static let tabSwitcherTitleNoTabs = NSLocalizedString("tabswitcher.title.notabs", comment: "No Tabs title")
    
    public static let feedbackEmailSubject = NSLocalizedString("feedbackemail.subject", comment: "Feedback email subject text ")
    public static let feedbackEmailBody = NSLocalizedString("feedbackemail.body", comment: "Feedback email body text")
    
    public static let actionPasteAndGo = NSLocalizedString("action.title.pasteAndGo", comment: "Paste and Go action")
    public static let actionRefresh = NSLocalizedString("action.title.refresh", comment: "Refresh action")
    public static let actionAdd = NSLocalizedString("action.title.add", comment: "Add action")
    public static let actionSave = NSLocalizedString("action.title.save", comment: "Save action")
    public static let actionCancel = NSLocalizedString("action.title.cancel", comment: "Cancel action")
    public static let actionNewTab = NSLocalizedString("action.title.newTab", comment: "New Tab action")
    public static let actionNewTabForUrl = NSLocalizedString("action.title.newTabForUrl", comment: "Open in New Tab action")
    public static let actionForgetAll = NSLocalizedString("action.title.forgetAll", comment: "Clear Tabs and Data action")
    public static let actionForgetAllDone = NSLocalizedString("action.title.forgetAllDone", comment: "Tabs and Data Cleared")
    public static let actionOpen = NSLocalizedString("action.title.open", comment: "Open action")
    public static let actionReadingList = NSLocalizedString("action.title.readingList", comment: "Reading List action")
    public static let actionCopy = NSLocalizedString("action.title.copy", comment: "Copy action")
    public static let actionShare = NSLocalizedString("action.title.share", comment: "Share action")
    public static let actionAddToWhitelist = NSLocalizedString("action.title.add.to.whitelist", comment: "Add to Whitelist action")
    public static let actionRemoveFromWhitelist = NSLocalizedString("action.title.remove.from.whitelist", comment: "Remove from Whitelist action")
    public static let actionSaveBookmark = NSLocalizedString("action.title.save.bookmark", comment: "Save Bookmark action")
    public static let actionRemoveBookmark = NSLocalizedString("action.title.remove.bookmark", comment: "Remove Bookmark action")
    public static let actionSettings = NSLocalizedString("action.title.settings", comment: "Settings action")
    public static let alertSaveBookmark = NSLocalizedString("alert.title.save.bookmark", comment: "Save Bookmark action")
    public static let alertEditBookmark = NSLocalizedString("alert.title.edit.bookmark", comment: "Edit Bookmark action")

    public static let alertAddToWhitelist = NSLocalizedString("alert.title.add.to.whitelist", comment: "Add to Whitelist action")
    public static let alertAddToWhitelistPlaceholder = NSLocalizedString("alert.title.add.to.whitelist.placeholder", comment: "Add to Whitelist placeholder")

    public static let navigationTitleEdit = NSLocalizedString("navigation.title.edit", comment: "Navbar Edit button title")

    public static let secureConnection = NSLocalizedString("monitoring.connection.secure", comment: "Secure conection")
    public static let unsecuredConnection = NSLocalizedString("monitoring.connection.unsecured", comment: "Unsecured conection")

    public static let privacyProtectionEncryptedConnection = NSLocalizedString("privacy.protection.encrypted.connection", comment: "Encrypted conection")
    public static let privacyProtectionUnencryptedConnection = NSLocalizedString("privacy.protection.unencrypted.connection", comment: "Unencrypted conection")
    public static let privacyProtectionTrackersBlocked = NSLocalizedString("privacy.protection.trackers.blocked", comment: "Trackers blocked")
    public static let privacyProtectionTrackersFound = NSLocalizedString("privacy.protection.trackers.found", comment: "Trackers found")
    public static let privacyProtectionMajorTrackersBlocked = NSLocalizedString("privacy.protection.major.trackers.blocked", comment: "Major trackers blocked")
    public static let privacyProtectionMajorTrackersFound = NSLocalizedString("privacy.protection.major.trackers.found", comment: "Major trackers found")

    public static let privacyProtectionTOSUnknown = NSLocalizedString("privacy.protection.tos.unknown", comment: "Unknown Privacy Practices")
    public static let privacyProtectionTOSGood = NSLocalizedString("privacy.protection.tos.good", comment: "Good Privacy Practices")
    public static let privacyProtectionTOSMixed = NSLocalizedString("privacy.protection.tos.mixed", comment: "Mixed Privacy Practices")
    public static let privacyProtectionTOSPoor = NSLocalizedString("privacy.protection.tos.poor", comment: "Poor Privacy Practices")

    public static func forSiteGrade(_ grade: SiteGrade) -> String {
        let key = "monitoring.sitegrade.\(grade.rawValue)"
        return NSLocalizedString(key, comment: "Grade \(grade.rawValue)")
    }
}
