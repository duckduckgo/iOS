//
//  UserText.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 24/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public struct UserText {
    
    public static let appTitle = forKey("app.title")
    public static let appInfo = forKey("app.info")
    public static let appInfoWithBuild = forKey("app.infoWithBuild")
    
    public static let homeLinkTitle = forKey("home.link.title")
    public static let searchDuckDuckGo = forKey("search.hint.duckduckgo")
    
    public static let webSessionCleared = forKey("web.session.clear")
    public static let webSaveLinkDone = forKey("web.url.save.done")
    
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

    public static let actionSave = forKey("action.title.save")
    public static let actionCancel = forKey("action.title.cancel")
    public static let actionNewTab = forKey("action.title.newTab")
    public static let actionOpen = forKey("action.title.open")
    public static let actionReadingList = forKey("action.title.readingList")
    public static let actionCopy = forKey("action.title.copy")
    public static let actionShare = forKey("action.title.share")
    public static let actionSaveBookmark = forKey("action.title.save.bookmark")
    
    public static let alertSaveBookmark = forKey("alert.title.save.bookmark")
    public static let alertEditBookmark = forKey("alert.title.edit.bookmark")

    public static let navigationTitleEdit = forKey("navigation.title.edit")
  
    public static func forDateFilter(_ dateFilter: DateFilter) -> String {
        if dateFilter == .any {
            return forKey("datefilter.code.any")
        }
        let key = "datefilter.code.\(dateFilter.rawValue)"
        return forKey(key)
    }
    
    fileprivate static func forKey(_ key: String) -> String {
        return NSLocalizedString(key, comment: key)
    }
}

