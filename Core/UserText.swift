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


import Foundation

public struct UserText {
    
    public static let appTitle = forKey("app.title")
    public static let appInfo = forKey("app.info")
    public static let appInfoWithBuild = forKey("app.infoWithBuild")
    public static let appUnlock = forKey("app.authentication.unlock")
    
    public static let homeLinkTitle = forKey("home.link.title")
    public static let searchDuckDuckGo = forKey("search.hint.duckduckgo")
    
    public static let webSessionCleared = forKey("web.session.clear")
    public static let webSaveLinkDone = forKey("web.url.save.done")

    public static let tabSwitcherTitleHasTabs = forKey("tabswitcher.title.tabs")
    public static let tabSwitcherTitleNoTabs = forKey("tabswitcher.title.notabs")
    public static let tabSwitcherData = forKey("tabswitcher.data")
    
    public static let onboardingRealPrivacyTitle = forKey("onboarding.realprivacy.title")
    public static let onboardingRealPrivacyDescription = forKey( "onboarding.realprivacy.description")
    public static let onboardingContentBlockingTitle = forKey("onboarding.contentblocking.title")
    public static let onboardingContentBlockingDescription = forKey("onboarding.contentblocking.description")
    public static let onboardingTrackingTitle = forKey("onboarding.tracking.title")
    public static let onboardingTrackingDescription = forKey("onboarding.tracking.description")
    public static let onboardingPrivacyRightTitle = forKey("onboarding.privacyright.title")
    public static let onboardingPrivacyRightDescription = forKey("onboarding.privacyright.description")
    
    public static let feedbackEmailSubject = forKey("feedbackemail.subject")
    public static let feedbackEmailBody = forKey("feedbackemail.body")

    public static let actionPasteAndGo = forKey("action.title.pasteAndGo")
    public static let actionRefresh = forKey("action.title.refresh")
    public static let actionSave = forKey("action.title.save")
    public static let actionCancel = forKey("action.title.cancel")
    public static let actionNewTab = forKey("action.title.newTab")
    public static let actionNewTabForUrl = forKey("action.title.newTabForUrl")
    public static let actionTabClearAll = forKey("action.title.tabClearAll")
    public static let actionTabClose = forKey("action.title.tabClose")
    public static let actionOpen = forKey("action.title.open")
    public static let actionReadingList = forKey("action.title.readingList")
    public static let actionCopy = forKey("action.title.copy")
    public static let actionShare = forKey("action.title.share")
    public static let actionSaveBookmark = forKey("action.title.save.bookmark")
    public static let actionSettings = forKey("action.title.settings")
    public static let alertSaveBookmark = forKey("alert.title.save.bookmark")
    public static let alertEditBookmark = forKey("alert.title.edit.bookmark")

    public static let navigationTitleEdit = forKey("navigation.title.edit")
    
    fileprivate static func forKey(_ key: String) -> String {
        return NSLocalizedString(key, comment: key)
    }
}

