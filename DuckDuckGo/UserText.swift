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
    
    public static let webPageFailedLoad = NSLocalizedString("web.page.load.failed", comment: "DuckDuckGo cannot load this page because...")

    public static let appUnlock = NSLocalizedString("app.authentication.unlock", comment: "Unlock DuckDuckGo")
    public static let homeLinkTitle = NSLocalizedString("home.link.title", comment: "DuckDuckGo Home")
    public static let searchDuckDuckGo = NSLocalizedString("search.hint.duckduckgo", comment: "Search or enter address")
    public static let webSessionCleared = NSLocalizedString("web.session.clear", comment: "Session cleared")
    public static let webSaveBookmarkDone = NSLocalizedString("web.url.save.bookmark.done", comment: "Bookmark saved")
    public static let webBookmarkAlreadySaved = NSLocalizedString("web.url.save.bookmark.exists", comment: "Bookmark already saved")
    public static let webSaveFavoriteDone = NSLocalizedString("web.url.save.favorite.done", comment: "Favorite saved")
    public static let webSaveBookmarkNone = NSLocalizedString("web.url.save.bookmark.none", comment: "No webpage to bookmark")

    public static let tabSwitcherTitleHasTabs = NSLocalizedString("tabswitcher.title.tabs", comment: "Private Tabs title")
    public static let tabSwitcherTitleNoTabs = NSLocalizedString("tabswitcher.title.notabs", comment: "No Tabs title")
        
    public static let actionPasteAndGo = NSLocalizedString("action.title.pasteAndGo", comment: "Paste and Go action")
    public static let actionRefresh = NSLocalizedString("action.title.refresh", comment: "Refresh action")
    public static let actionAdd = NSLocalizedString("action.title.add", comment: "Add action")
    public static let actionConfirm = NSLocalizedString("action.title.confirm", comment: "Confirm action")
    public static let actionSave = NSLocalizedString("action.title.save", comment: "Save action")
    public static let actionCancel = NSLocalizedString("action.title.cancel", comment: "Cancel action")
    public static let actionBookmark = NSLocalizedString("action.title.bookmark", comment: "Bookmark action")
    public static let actionNewTab = NSLocalizedString("action.title.newTab", comment: "New Tab action")
    public static let actionNewTabForUrl = NSLocalizedString("action.title.newTabForUrl", comment: "Open in New Tab action")
    public static let actionNewBackgroundTabForUrl = NSLocalizedString("action.title.newBackgroundTabForUrl", comment: "Open in New Background Tab action")
    public static let actionForgetTabs = NSLocalizedString("action.title.forgetTabs", comment: "Clear Tabs action")
    public static let actionForgetAll = NSLocalizedString("action.title.forgetAll", comment: "Clear Tabs and Data action")
    public static let actionForgetTabsDone = NSLocalizedString("action.title.forgetTabsDone", comment: "Tabs Cleared")
    public static let actionForgetAllDone = NSLocalizedString("action.title.forgetAllDone", comment: "Tabs and Data Cleared")
    public static let actionOpen = NSLocalizedString("action.title.open", comment: "Open action")
    public static let actionReadingList = NSLocalizedString("action.title.readingList", comment: "Reading List action")
    public static let actionCopy = NSLocalizedString("action.title.copy", comment: "Copy action")
    public static let actionShare = NSLocalizedString("action.title.share", comment: "Share action")
    public static let actionEnableProtection = NSLocalizedString("action.title.enable.protection", comment: "Enable protection action")
    public static let actionDisableProtection = NSLocalizedString("action.title.disable.protection", comment: "Disable protection action")
    public static let actionRequestDesktopSite = NSLocalizedString("action.title.request.desktop.site", comment: "Request Mobile Site")
    public static let actionRequestMobileSite = NSLocalizedString("action.title.request.mobile.site", comment: "Request Desktop Site")
    public static let actionSaveBookmark = NSLocalizedString("action.title.save.bookmark", comment: "Save Bookmark action")
    public static let actionSaveFavorite = NSLocalizedString("action.title.save.favorite", comment: "Save Favorite action")
    public static let actionRemoveBookmark = NSLocalizedString("action.title.remove.bookmark", comment: "Remove Bookmark action")
    public static let actionReportBrokenSite = NSLocalizedString("action.title.reportBrokenSite", comment: "Report broken site action")
    public static let actionSettings = NSLocalizedString("action.title.settings", comment: "Settings action")
    public static let alertSaveBookmark = NSLocalizedString("alert.title.save.bookmark", comment: "Save Bookmark action")
    public static let alertSaveFavorite = NSLocalizedString("alert.title.save.favorite", comment: "Save Favorite action")
    public static let alertEditBookmark = NSLocalizedString("alert.title.edit.bookmark", comment: "Edit Bookmark action")
    public static let alertBookmarkAllTitle = NSLocalizedString("alert.title.bookmarkAll", comment: "Bookmark All Tabs?")
    public static let alertBookmarkAllMessage = NSLocalizedString("alert.message.bookmarkAll", comment: "Existing bookmarks will not be duplicated.")

    public static let alertAddToWhitelist = NSLocalizedString("alert.title.add.to.whitelist", comment: "Add to Whitelist action")
    public static let alertAddToWhitelistPlaceholder = NSLocalizedString("alert.title.add.to.whitelist.placeholder", comment: "Add to Whitelist placeholder")
    public static let toastProtectionDisabled = NSLocalizedString("toast.protection.disabled", comment: "Protection Disabled")
    public static let toastProtectionEnabled = NSLocalizedString("toast.protection.enabled", comment: "Protection Enabled")
    
    public static let authAlertTitle = NSLocalizedString("auth.alert.title", comment: "Authentication Alert Title")
    public static let authAlertEncryptedConnectionMessage = NSLocalizedString("auth.alert.message.encrypted", comment: "Authentication Alert Encrypted Connection Message")
    public static let authAlertPlainConnectionMessage = NSLocalizedString("auth.alert.message.plain", comment: "Authentication Alert Plain Connection Message")
    public static let authAlertUsernamePlaceholder = NSLocalizedString("auth.alert.username.placeholder", comment: "Authentication User name Placeholder")
    public static let authAlertPasswordPlaceholder = NSLocalizedString("auth.alert.password.placeholder", comment: "Authentication Password Placeholder")
    public static let authAlertLogInButtonTitle = NSLocalizedString("auth.alert.login.button", comment: "Authentication Alert Log In Button")

    public static let navigationTitleEdit = NSLocalizedString("navigation.title.edit", comment: "Navbar Edit button title")

    public static let secureConnection = NSLocalizedString("monitoring.connection.secure", comment: "Secure conection")
    public static let unsecuredConnection = NSLocalizedString("monitoring.connection.unsecured", comment: "Unsecured conection")

    public static let privacyProtectionTrackersBlocked = NSLocalizedString("privacy.protection.trackers.blocked", comment: "Trackers blocked")
    public static let privacyProtectionTrackersFound = NSLocalizedString("privacy.protection.trackers.found", comment: "Trackers found")
    public static let privacyProtectionMajorTrackersBlocked = NSLocalizedString("privacy.protection.major.trackers.blocked", comment: "Major trackers blocked")
    public static let privacyProtectionMajorTrackersFound = NSLocalizedString("privacy.protection.major.trackers.found", comment: "Major trackers found")

    public static let privacyProtectionTOSUnknown = NSLocalizedString("privacy.protection.tos.unknown", comment: "Unknown Privacy Practices")
    public static let privacyProtectionTOSGood = NSLocalizedString("privacy.protection.tos.good", comment: "Good Privacy Practices")
    public static let privacyProtectionTOSMixed = NSLocalizedString("privacy.protection.tos.mixed", comment: "Mixed Privacy Practices")
    public static let privacyProtectionTOSPoor = NSLocalizedString("privacy.protection.tos.poor", comment: "Poor Privacy Practices")

    public static let ppEncryptionCertError = NSLocalizedString("privacy.protection.encryption.cert.error", comment: "Error extracting certificate")
    public static let ppEncryptionSubjectName = NSLocalizedString("privacy.protection.encryption.subject.name", comment:  "Subject Name")
    public static let ppEncryptionPublicKey = NSLocalizedString("privacy.protection.encryption.public.key", comment:  "Public Key")
    public static let ppEncryptionIssuer = NSLocalizedString("privacy.protection.encryption.issuer", comment:  "Issuer")
    public static let ppEncryptionSummary = NSLocalizedString("privacy.protection.encryption.summary", comment:  "Summary")
    public static let ppEncryptionCommonName = NSLocalizedString("privacy.protection.encryption.common.name", comment:  "Common Name")
    public static let ppEncryptionEmail = NSLocalizedString("privacy.protection.encryption.email", comment:  "Email")
    public static let ppEncryptionAlgorithm = NSLocalizedString("privacy.protection.encryption.algorithm", comment:  "Algorithm")
    public static let ppEncryptionKeySize = NSLocalizedString("privacy.protection.encryption.key.size", comment:  "Key Size")
    public static let ppEncryptionEffectiveSize = NSLocalizedString("privacy.protection.encryption.effective.size", comment:  "Effective Size")
    public static let ppEncryptionUsageDecrypt = NSLocalizedString("privacy.protection.encryption.usage.decrypt", comment:  "Decrypt")
    public static let ppEncryptionUsageEncrypt = NSLocalizedString("privacy.protection.encryption.usage.encrypt", comment:  "Encrypt")
    public static let ppEncryptionUsageDerive = NSLocalizedString("privacy.protection.encryption.usage.derive", comment:  "Derive")
    public static let ppEncryptionUsageWrap = NSLocalizedString("privacy.protection.encryption.usage.wrap", comment:  "Wrap")
    public static let ppEncryptionUsageUnwrap = NSLocalizedString("privacy.protection.encryption.usage.unwrap", comment:  "Unwrap")
    public static let ppEncryptionUsageSign = NSLocalizedString("privacy.protection.encryption.usage.sign", comment:  "Sign")
    public static let ppEncryptionUsageVerify = NSLocalizedString("privacy.protection.encryption.usage.verify", comment:  "Verify")
    public static let ppEncryptionUsage = NSLocalizedString("privacy.protection.encryption.usage", comment:  "Usage")
    public static let ppEncryptionPermanent = NSLocalizedString("privacy.protection.encryption.permanent", comment:  "Permanent")
    public static let ppEncryptionId = NSLocalizedString("privacy.protection.encryption.id", comment:  "ID")
    public static let ppEncryptionKey = NSLocalizedString("privacy.protection.encryption.key", comment:  "Key")
    public static let ppEncryptionYes = NSLocalizedString("privacy.protection.encryption.yes", comment:  "Yes")
    public static let ppEncryptionNo = NSLocalizedString("privacy.protection.encryption.no", comment:  "No")
    public static let ppEncryptionUnknown = NSLocalizedString("privacy.protection.encryption.unknown", comment:  "Unknown")
    public static let ppEncryptionBits = NSLocalizedString("privacy.protection.encryption.bits", comment:  "%d bits")
    
    public static let ppEncryptionStandardMessage = NSLocalizedString("privacy.protection.encryption.standard.message", comment: "An encrypted connection prevents eavesdropping of any personal information you send to a website.")
    public static let ppEncryptionMixedMessage = NSLocalizedString("privacy.protection.encryption.mixed.message", comment: "This site has mixed encryption because some content is being served over unencrypted connections. Encrypted connections prevent eavesdropping of personal information you send to websites.")
    public static let ppEncryptionForcedMessage = NSLocalizedString("privacy.protection.encryption.forced.message", comment: "We've forced this site to use an encrypted connection, preventing eavesdropping of any personal information you send to it.")
    
    public static let ppEncryptionEncryptedHeading = NSLocalizedString("privacy.protection.encryption.encrypted.heading", comment:  "Encrypted")
    public static let ppEncryptionForcedHeading = NSLocalizedString("privacy.protection.encryption.forced.heading", comment:  "Forced")
    public static let ppEncryptionMixedHeading = NSLocalizedString("privacy.protection.encryption.mixed.heading", comment:  "Mixed")
    public static let ppEncryptionUnencryptedHeading = NSLocalizedString("privacy.protection.encryption.unencrypted.heading", comment:  "Unencrypted")

    public static let ppTrackerNetworksMajorMessage = NSLocalizedString("privacy.protection.tracker.networks.major.message", comment: "Major tracker networks are more harmful because they can track and target you across more of the internet.")

    public static let ppNetworkLeaderboard = NSLocalizedString("privacy.protection.network.leaderboard", comment:  "Trackers networks were found on %@ of web sites you’ve visited since %@.")

    public static let ppTrackerNetworkUnknown = NSLocalizedString("privacy.protection.tracker.network.unknown", comment:  "Unknown tracker networks")
    
    static let brokenSiteSectionTitle = NSLocalizedString("brokensite.sectionTitle", comment: "Broken Site Section Title")
    
    static let brokenSiteCategoryImages = NSLocalizedString("brokensite.category.images", comment: "Broken Site Category")
    static let brokenSiteCategoryPaywall = NSLocalizedString("brokensite.category.paywall", comment: "Broken Site Category")
    static let brokenSiteCategoryComments = NSLocalizedString("brokensite.category.comments", comment: "Broken Site Category")
    static let brokenSiteCategoryVideos = NSLocalizedString("brokensite.category.videos", comment: "Broken Site Category")
    static let brokenSiteCategoryLinks = NSLocalizedString("brokensite.category.links", comment: "Broken Site Category")
    static let brokenSiteCategoryContent = NSLocalizedString("brokensite.category.content", comment: "Broken Site Category")
    static let brokenSiteCategoryLogin = NSLocalizedString("brokensite.category.login", comment: "Broken Site Category")
    static let brokenSiteCategoryUnsupported = NSLocalizedString("brokensite.category.unsupported", comment: "Broken Site Category")
    static let brokenSiteCategoryOther = NSLocalizedString("brokensite.category.other", comment: "Broken Site Category")

    
    public static let privacyReportTrackersBlocked = NSLocalizedString("privacy.report.trackersBlocked", comment: "Trackers Blocked")
    
    public static let privacyReportSitesEncrypted = NSLocalizedString("privacy.report.sitesEncrypted", comment: "Sites Encrypted")
    
    public static let privacyReportDate = NSLocalizedString("privacy.report.date", comment: "Since %@")

    public static let unknownErrorOccurred = NSLocalizedString("unknown.error.occurred", comment:  "Unknown error occurred")
    
    public static let homeRowReminderTitle = NSLocalizedString("home.row.reminder.title", comment:  "Home Row Reminder Title")
    public static let homeRowReminderMessage = NSLocalizedString("home.row.reminder.message", comment:  "Home Row Reminder Message")
    
    public static let homeRowOnboardingHeader = NSLocalizedString("home.row.onboarding.header", comment:  "Home Row onboarding Header")
    
    public static let feedbackSumbittedConfirmation = NSLocalizedString("feedback.submitted.confirmation", comment:  "Feedback submitted confirmation")
    
    public static let customUrlSchemeTitle = NSLocalizedString("prompt.custom.url.scheme.title", comment: "Switch apps?")
    public static func forCustomUrlSchemePrompt(url: URL) -> String {
        let message = NSLocalizedString("prompt.custom.url.scheme.prompt", comment: "Would you like to open this URL... ")
        return message.format(arguments: url.absoluteString)
    }
    public static let customUrlSchemeOpen = NSLocalizedString("prompt.custom.url.scheme.open", comment: "Open custom url button")
    public static let customUrlSchemeDontOpen = NSLocalizedString("prompt.custom.url.scheme.dontopen", comment: "Don't open custom url button")

    public static let failedToOpenExternally = NSLocalizedString("open.externally.failed", comment: "Don't open custom url button")
    
    public static let sectionTitleBookmarks = NSLocalizedString("section.title.bookmarks", comment: "Bookmarks section title")
    public static let sectionTitleFavorites = NSLocalizedString("section.title.favorites", comment: "Favorites section title")

    public static let favoriteMenuDelete = NSLocalizedString("favorite.menu.delete", comment: "Favorite menu: delete")
    public static let favoriteMenuEdit = NSLocalizedString("favorite.menu.edit", comment: "Favorite menu: edit")

    public static let emptyBookmarks = NSLocalizedString("empty.bookmarks", comment: "No bookmarks")
    public static let emptyFavorites = NSLocalizedString("empty.favorites", comment: "No favorites")

    public static let bookmarkTitlePlaceholder = NSLocalizedString("bookmark.title.placeholder", comment: "Bookmark Title Placeholder")
    public static let bookmarkAddressPlaceholder = NSLocalizedString("bookmark.address.placeholder", comment: "Bookmark Address Placeholder")

    public static let findInPage = NSLocalizedString("findinpage.title", comment: "Find in Page")
    public static let findInPageCount = NSLocalizedString("findinpage.count", comment: "%d of %d")

    public static let keyCommandShowAllTabs = NSLocalizedString("keyCommandShowAllTabs", comment: "Show all tabs")
    public static let keyCommandNewTab = NSLocalizedString("keyCommandNewTab", comment: "New tab")
    public static let keyCommandCloseTab = NSLocalizedString("keyCommandCloseTab", comment: "Close tab")
    public static let keyCommandNextTab = NSLocalizedString("keyCommandNextTab", comment: "Next tab")
    public static let keyCommandPreviousTab = NSLocalizedString("keyCommandPreviousTab", comment: "Previous tab")
    public static let keyCommandBrowserForward = NSLocalizedString("keyCommandBrowserForward", comment: "Browse forward")
    public static let keyCommandBrowserBack = NSLocalizedString("keyCommandBrowserBack", comment: "Browse back")
    public static let keyCommandFind = NSLocalizedString("keyCommandFind", comment: "Find in page")
    public static let keyCommandLocation = NSLocalizedString("keyCommandLocation", comment: "Search or enter address")
    public static let keyCommandFire = NSLocalizedString("keyCommandFire", comment: "Clear all tabs and data")
    public static let keyCommandClose = NSLocalizedString("keyCommandClose", comment: "Close")
    public static let keyCommandSelect = NSLocalizedString("keyCommandSelect", comment: "Select")

    public static let contextualOnboardingSearchPrivately = NSLocalizedString("contextualOnboardingSearchPrivately", comment: "Searching with DuckDuckGo means your searches are never tracked. Ever.")
    public static let contextualOnboardingCustomizeTheme = NSLocalizedString("contextualOnboardingCustomizeTheme", comment: "Want a different look? Try changing current theme!")
    public static let contextualOnboardingPrivacyGrade = NSLocalizedString("contextualOnboardingPrivacyGrade", comment: "DuckDuckGo enhances your privacy as you browse. Tap the privacy grade icon to learn how.")
    public static let contextualOnboardingFireButton = NSLocalizedString("contextualOnboardingFireButton", comment: "Tap the flame icon to erase your tabs and browsing data, or make it automatic in settings.")

    public static let bookmarkAllTabsNotFound = NSLocalizedString("bookmarkAll.tabs.notfound", comment: "No open tabs found to bookmark")
    public static let bookmarkAllTabsSaved = NSLocalizedString("bookmarkAll.tabs.saved", comment: "All open tabs are bookmarked")
    public static let bookmarkAllTabsFailedToSave = NSLocalizedString("bookmarkAll.tabs.failed", comment: "Failed to bookmark %lu out of %lu tabs")
    
    public static let themeNameDefault = NSLocalizedString("theme.name.default", comment: "System Default")
    public static let themeNameLight = NSLocalizedString("theme.name.light", comment: "Light")
    public static let themeNameDark = NSLocalizedString("theme.name.dark", comment: "Dark")
    
    public static let themeAccessoryDefault = NSLocalizedString("theme.acc.default", comment: "System")
    public static let themeAccessoryLight = NSLocalizedString("theme.acc.light", comment: "Light")
    public static let themeAccessoryDark = NSLocalizedString("theme.acc.dark", comment: "Dark")

    public static let autoClearAccessoryOn = NSLocalizedString("autoclear.on", comment: "On")
    public static let autoClearAccessoryOff = NSLocalizedString("autoclear.off", comment: "Off")

    public static let homePageNavigationBar = NSLocalizedString("homepage.navigationBar", comment: "Navigation Bar Search")
    public static let homePageCenterSearch = NSLocalizedString("homepage.centerSearch", comment: "Center Search")
    
    public static func privacyGrade(_ grade: String) -> String {
        let message = NSLocalizedString("privacy.protection.site.grade", comment: "Privacy grade %@")
        return message.format(arguments: grade)
    }

    public static func numberOfTabs(_ number: Int) -> String {
        let message = NSLocalizedString("number.of.tabs", comment: "%d Private Tabs")
        return message.format(arguments: number)
    }
    
    public static func openTab(withTitle title: String, atAddress address: String) -> String {
        let message = NSLocalizedString("tab.open.with.title.and.address", comment: "Open tab with address")
        return message.format(arguments: title, address)
    }

    public static func closeTab(withTitle title: String, atAddress address: String) -> String {
        let message = NSLocalizedString("tab.close.with.title.and.address", comment: "Close tab with address")
        return message.format(arguments: title, address)
    }

    public static let favorite = NSLocalizedString("favorite", comment: "Favorite")
    public static let privacyFeatures = NSLocalizedString("privacy.features", comment: "Privacy Features")

    public static let onboardingWelcomeHeader = NSLocalizedString("onboardingWelcomeHeader", comment: "Welcome to DuckDuckGo!")
    public static let onboardingContinue = NSLocalizedString("onboardingContinue", comment: "Continue")
    public static let onboardingSkip = NSLocalizedString("onboardingSkip", comment: "Skip")
    public static let onboardingStartBrowsing = NSLocalizedString("onboardingStartBrowsing", comment: "Start browsing")
    public static let onboardingSetAppIcon = NSLocalizedString("onboardingSetAppIcon", comment: "Set App Icon")
    public static let onboardingNotificationsAccept = NSLocalizedString("onboardingNotificationsAccept", comment: "Turn on Notifications")
    public static let onboardingNotificationsDeny = NSLocalizedString("onboardingNotificationsDeny", comment: "Not now")
    
    public static let preserveLoginsSwitchTitle = NSLocalizedString("preserveLogins.switch.title", comment: "Ask to Fireproof Websites")

    public static let preserveLoginsListTitle = NSLocalizedString("preserveLogins.domain.list.title", comment: "Websites")
    public static let preserveLoginsListFooter = NSLocalizedString("preserveLogins.domain.list.footer", comment: "Websites rely on cookies ...")
    public static let preserveLoginsRemoveAll = NSLocalizedString("preserveLogins.remove.all", comment: "Remove All")
    public static let preserveLoginsRemoveAllOk = NSLocalizedString("preserveLogins.remove.all.ok", comment: "OK")

    public static let preserveLoginsFireproofAsk = NSLocalizedString("preserveLogins.fireproof.message", comment: "Would you like to Fireproof %@?")
    public static let preserveLoginsFireproofConfirm = NSLocalizedString("preserveLogins.menu.confirm", comment: "Fireproof Website")
    public static let preserveLoginsFireproofCancel = NSLocalizedString("preserveLogins.menu.cancel", comment: "Cancel")
    public static let preserveLoginsFireproofDefer = NSLocalizedString("preserveLogins.menu.defer", comment: "Not Now")

    public static let preserveLoginsToast = NSLocalizedString("preserveLogins.toast", comment: "%@ is now Fireproof! Visit settings to remove.")

    public static let homeTabSearchOnly = NSLocalizedString("homeTab.searchOnly", comment: "Home tab search only")
    public static let homeTabSearchAndFavorites = NSLocalizedString("homeTab.searchAndFavorites", comment: "Home tab search and favorites")
    public static let homeTabTitle = NSLocalizedString("homeTab.title", comment: "Home tab title")

    public static let daxDialogHomeInitial = NSLocalizedString("dax.onboarding.home.initial", comment: "Next, try visiting one of your favorite sites!")
    public static let daxDialogHomeSubsequent = NSLocalizedString("dax.onboarding.home.subsequent", comment: "You’ve got this!")

    public static let daxDialogBrowsingAfterSearch = NSLocalizedString("dax.onboarding.browsing.after.search", comment: "Your DuckDuckGo searches are anonymous...")
    public static let daxDialogBrowsingAfterSearchCTA = NSLocalizedString("dax.onboarding.browsing.after.search.cta", comment: "Phew!")

    public static let daxDialogBrowsingWithoutTrackers = NSLocalizedString("dax.onboarding.browsing.without.trackers", comment: "As you tap and scroll, I'll block pesky trackers.")
    public static let daxDialogBrowsingWithoutTrackersCTA = NSLocalizedString("dax.onboarding.browsing.without.trackers.cta", comment: "Got It")

    public static let daxDialogBrowsingSiteIsMajorTracker = NSLocalizedString("dax.onboarding.browsing.site.is.major.tracker", comment: "Heads up! %1$@ is a major tracking network.")
    public static let daxDialogBrowsingSiteIsMajorTrackerCTA = NSLocalizedString("dax.onboarding.browsing.site.is.major.tracker.cta", comment: "Got It")

    public static let daxDialogBrowsingSiteOwnedByMajorTracker = NSLocalizedString("dax.onboarding.browsing.site.owned.by.major.tracker", comment: "Heads up! %1$@ is owned by %2$@.")
    public static let daxDialogBrowsingSiteOwnedByMajorTrackerCTA = NSLocalizedString("dax.onboarding.browsing.site.owned.by.major.tracker.cta", comment: "Got It")

    public static let daxDialogBrowsingWithOneTracker = NSLocalizedString("dax.onboarding.browsing.one.tracker", comment: "*%1$@* was trying to track you here.")
    public static let daxDialogBrowsingWithOneTrackerCTA = NSLocalizedString("dax.onboarding.browsing.one.tracker.cta", comment: "High Five!")

    public static let daxDialogBrowsingWithTwoTrackers = NSLocalizedString("dax.onboarding.browsing.two.trackers", comment: "*%1$@ and %2$@* were trying to track you here.")
    public static let daxDialogBrowsingWithTwoTrackersCTA = NSLocalizedString("dax.onboarding.browsing.two.trackers.cta", comment: "High Five!")

    public static let daxDialogBrowsingWithMultipleTrackers = NSLocalizedString("dax.onboarding.browsing.multiple.trackers", comment: "*%1$@, %2$@* and *%3$d others* were trying to track you here.")
    public static let daxDialogBrowsingWithMultipleTrackersCTA = NSLocalizedString("dax.onboarding.browsing.multiple.trackers.cta", comment: "High Five!")
    
    public static let daxDialogOnboardingMessage = NSLocalizedString("dax.onboarding.message", comment: "The Internet can be kinda creepy.")
    
    public static let daxDialogHideTitle = NSLocalizedString("dax.hide.title", comment: "Hide remaining tips?")
    public static let daxDialogHideMessage = NSLocalizedString("dax.hide.message", comment: "There are only a few, and we tried to make them informative.")
    public static let daxDialogHideButton = NSLocalizedString("dax.hide.button", comment: "Hide tips forever")
    public static let daxDialogHideCancel = NSLocalizedString("dax.hide.cancel", comment: "Cancel")
    
}
