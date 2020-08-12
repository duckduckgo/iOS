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
    
    public static let appUnlock = NSLocalizedString("app.authentication.unlock", value: "Unlock DuckDuckGo", comment: "Unlock DuckDuckGo")
    public static let searchDuckDuckGo = NSLocalizedString("search.hint.duckduckgo", value: "Search or enter address", comment: "Search or enter address")
    public static let webSaveBookmarkDone = NSLocalizedString("web.url.save.bookmark.done", value: "Bookmark saved", comment: "Bookmark saved")
    public static let webBookmarkAlreadySaved = NSLocalizedString("web.url.save.bookmark.exists", value: "Bookmark already saved", comment: "Bookmark already saved")
    public static let webSaveFavoriteDone = NSLocalizedString("web.url.save.favorite.done", value: "Favorite saved", comment: "Favorite saved")
    public static let webSaveBookmarkNone = NSLocalizedString("web.url.save.bookmark.none", value: "No webpage to bookmark", comment: "No webpage to bookmark")
    
    public static let actionPasteAndGo = NSLocalizedString("action.title.pasteAndGo", value: "Paste & Go", comment: "Paste and Go action")
    public static let actionRefresh = NSLocalizedString("action.title.refresh", value: "Refresh", comment: "Refresh action")
    public static let actionAdd = NSLocalizedString("action.title.add", value: "Add", comment: "Add action")
    public static let actionSave = NSLocalizedString("action.title.save", value: "Save", comment: "Save action")
    public static let actionCancel = NSLocalizedString("action.title.cancel", value: "Cancel", comment: "Cancel action")
    public static let actionBookmark = NSLocalizedString("action.title.bookmark", value: "Bookmark", comment: "Bookmark action")
    public static let actionNewTab = NSLocalizedString("action.title.newTab", value: "New Tab", comment: "New Tab action")
    public static let actionNewTabForUrl = NSLocalizedString("action.title.newTabForUrl", value: "Open in New Tab", comment: "Open in New Tab action")
    public static let actionNewBackgroundTabForUrl = NSLocalizedString("action.title.newBackgroundTabForUrl", value: "Open in Background", comment: "Open in New Background Tab action")
    public static let actionForgetAll = NSLocalizedString("action.title.forgetAll", value: "Close Tabs and Clear Data", comment: "Clear Tabs and Data action")
    public static let actionForgetAllDone = NSLocalizedString("action.title.forgetAllDone", value: "Tabs and data cleared", comment: "Tabs and Data Cleared")
    public static let actionOpen = NSLocalizedString("action.title.open", value: "Open", comment: "Open action")
    public static let actionReadingList = NSLocalizedString("action.title.readingList", value: "Add to Reading List", comment: "Reading List action")
    public static let actionCopy = NSLocalizedString("action.title.copy", value: "Copy", comment: "Copy action")
    public static let actionShare = NSLocalizedString("action.title.share", value: "Share...", comment: "Share action")
    public static let actionEnableProtection = NSLocalizedString("action.title.enable.protection", value: "Enable Privacy Protection", comment: "Enable protection action")
    public static let actionDisableProtection = NSLocalizedString("action.title.disable.protection", value: "Disable Privacy Protection", comment: "Disable protection action")
    public static let actionRequestDesktopSite = NSLocalizedString("action.title.request.desktop.site", value: "Request Desktop Site", comment: "Request Mobile Site")
    public static let actionRequestMobileSite = NSLocalizedString("action.title.request.mobile.site", value: "Request Mobile Site", comment: "Request Desktop Site")
    public static let actionSaveBookmark = NSLocalizedString("action.title.save.bookmark", value: "Add to Bookmarks", comment: "Save Bookmark action")
    public static let actionSaveFavorite = NSLocalizedString("action.title.save.favorite", value: "Add to Favorites", comment: "Save Favorite action")
    public static let actionReportBrokenSite = NSLocalizedString("action.title.reportBrokenSite", value: "Report Broken Site", comment: "Report broken site action")
    public static let actionSettings = NSLocalizedString("action.title.settings", value: "Settings...", comment: "Settings action")
    public static let alertSaveBookmark = NSLocalizedString("alert.title.save.bookmark", value: "Save Bookmark", comment: "Save Bookmark action")
    public static let alertSaveFavorite = NSLocalizedString("alert.title.save.favorite", value: "Save Favorite", comment: "Save Favorite action")
    public static let alertEditBookmark = NSLocalizedString("alert.title.edit.bookmark", value: "Edit Bookmark", comment: "Edit Bookmark action")
    public static let alertBookmarkAllTitle = NSLocalizedString("alert.title.bookmarkAll", value: "Bookmark All Tabs?", comment: "Bookmark All Tabs?")
    public static let alertBookmarkAllMessage = NSLocalizedString("alert.message.bookmarkAll", value: "Existing bookmarks will not be duplicated.", comment: "Existing bookmarks will not be duplicated.")
    
    public static let alertDisableProtection = NSLocalizedString("alert.title.disable.protection", value: "Add to Unprotected Sites", comment: "Disable protection alert")
    public static let alertDisableProtectionPlaceholder = NSLocalizedString("alert.title.disable.protection.placeholder", value: "www.example.com", comment: "Disable potection alert placeholder")
    public static let toastProtectionDisabled = NSLocalizedString("toast.protection.disabled", value: "%@ added to unprotected sites", comment: "Protection Disabled")
    public static let toastProtectionEnabled = NSLocalizedString("toast.protection.enabled", value: "%@ removed from unprotected sites", comment: "Protection Enabled")
    
    public static let authAlertTitle = NSLocalizedString("auth.alert.title", value: "Authentication required", comment: "Authentication Alert Title")
    public static let authAlertEncryptedConnectionMessage = NSLocalizedString("auth.alert.message.encrypted", value: "Log in to %@. Your login information will be sent securely.", comment: "Authentication Alert Encrypted Connection Message")
    public static let authAlertPlainConnectionMessage = NSLocalizedString("auth.alert.message.plain", value: "Log in to %@. Your password will be sent insecurely because the connection is unencrypted.", comment: "Authentication Alert Plain Connection Message")
    public static let authAlertUsernamePlaceholder = NSLocalizedString("auth.alert.username.placeholder", value: "Username", comment: "Authentication User name Placeholder")
    public static let authAlertPasswordPlaceholder = NSLocalizedString("auth.alert.password.placeholder", value: "Password", comment: "Authentication Password Placeholder")
    public static let authAlertLogInButtonTitle = NSLocalizedString("auth.alert.login.button", value: "Log In", comment: "Authentication Alert Log In Button")
    
    public static let navigationTitleEdit = NSLocalizedString("navigation.title.edit", value: "Edit", comment: "Navbar Edit button title")
    
    public static let privacyProtectionTrackersBlocked = NSLocalizedString("privacy.protection.trackers.blocked", comment: "Trackers blocked")
    public static let privacyProtectionTrackersFound = NSLocalizedString("privacy.protection.trackers.found", comment: "Trackers found")
    public static let privacyProtectionMajorTrackersBlocked = NSLocalizedString("privacy.protection.major.trackers.blocked", comment: "Major trackers blocked")
    public static let privacyProtectionMajorTrackersFound = NSLocalizedString("privacy.protection.major.trackers.found", comment: "Major trackers found")
    
    public static let privacyProtectionTOSUnknown = NSLocalizedString("privacy.protection.tos.unknown", value: "Unknown Privacy Practices", comment: "Unknown Privacy Practices")
    public static let privacyProtectionTOSGood = NSLocalizedString("privacy.protection.tos.good", value: "Good Privacy Practices", comment: "Good Privacy Practices")
    public static let privacyProtectionTOSMixed = NSLocalizedString("privacy.protection.tos.mixed", value: "Mixed Privacy Practices", comment: "Mixed Privacy Practices")
    public static let privacyProtectionTOSPoor = NSLocalizedString("privacy.protection.tos.poor", value: "Poor Privacy Practices", comment: "Poor Privacy Practices")
    
    public static let ppEncryptionCertError = NSLocalizedString("privacy.protection.encryption.cert.error", value: "Error extracting certificate", comment: "Error extracting certificate")
    public static let ppEncryptionSubjectName = NSLocalizedString("privacy.protection.encryption.subject.name", value: "Subject Name", comment: "Subject Name")
    public static let ppEncryptionPublicKey = NSLocalizedString("privacy.protection.encryption.public.key", value: "Public Key", comment: "Public Key")
    public static let ppEncryptionIssuer = NSLocalizedString("privacy.protection.encryption.issuer", value: "Issuer", comment: "Issuer")
    public static let ppEncryptionSummary = NSLocalizedString("privacy.protection.encryption.summary", value: "Summary", comment: "Summary")
    public static let ppEncryptionCommonName = NSLocalizedString("privacy.protection.encryption.common.name", value: "Common Name", comment: "Common Name")
    public static let ppEncryptionEmail = NSLocalizedString("privacy.protection.encryption.email", value: "Email", comment: "Email")
    public static let ppEncryptionAlgorithm = NSLocalizedString("privacy.protection.encryption.algorithm", value: "Algorithm", comment: "Algorithm")
    public static let ppEncryptionKeySize = NSLocalizedString("privacy.protection.encryption.key.size", value: "Key Size", comment: "Key Size")
    public static let ppEncryptionEffectiveSize = NSLocalizedString("privacy.protection.encryption.effective.size", value: "Effective Size", comment: "Effective Size")
    public static let ppEncryptionUsageDecrypt = NSLocalizedString("privacy.protection.encryption.usage.decrypt", value: "Decrypt", comment: "Decrypt")
    public static let ppEncryptionUsageEncrypt = NSLocalizedString("privacy.protection.encryption.usage.encrypt", value: "Encrypt", comment: "Encrypt")
    public static let ppEncryptionUsageDerive = NSLocalizedString("privacy.protection.encryption.usage.derive", value: "Derive", comment: "Derive")
    public static let ppEncryptionUsageWrap = NSLocalizedString("privacy.protection.encryption.usage.wrap", value: "Wrap", comment: "Wrap")
    public static let ppEncryptionUsageUnwrap = NSLocalizedString("privacy.protection.encryption.usage.unwrap", value: "Unwrap", comment: "Unwrap")
    public static let ppEncryptionUsageSign = NSLocalizedString("privacy.protection.encryption.usage.sign", value: "Sign", comment: "Sign")
    public static let ppEncryptionUsageVerify = NSLocalizedString("privacy.protection.encryption.usage.verify", value: "Verify", comment: "Verify")
    public static let ppEncryptionUsage = NSLocalizedString("privacy.protection.encryption.usage", value: "Usage", comment: "Usage")
    public static let ppEncryptionPermanent = NSLocalizedString("privacy.protection.encryption.permanent", value: "Permanent", comment: "Permanent")
    public static let ppEncryptionId = NSLocalizedString("privacy.protection.encryption.id", value: "Subject Key Identifier", comment: "ID")
    public static let ppEncryptionKey = NSLocalizedString("privacy.protection.encryption.key", value: "Public Key", comment: "Key")
    public static let ppEncryptionYes = NSLocalizedString("privacy.protection.encryption.yes", value: "Yes", comment: "Yes")
    public static let ppEncryptionNo = NSLocalizedString("privacy.protection.encryption.no", value: "No", comment: "No")
    public static let ppEncryptionUnknown = NSLocalizedString("privacy.protection.encryption.unknown", value: "Unknown", comment: "Unknown")
    public static let ppEncryptionBits = NSLocalizedString("privacy.protection.encryption.bits", value: "%d bits", comment: "%d bits")
    
    public static let ppEncryptionStandardMessage = NSLocalizedString("privacy.protection.encryption.standard.message", value: "An encrypted connection prevents eavesdropping of any personal information you send to a website.", comment: "An encrypted connection prevents eavesdropping of any personal information you send to a website.")
    public static let ppEncryptionMixedMessage = NSLocalizedString("privacy.protection.encryption.mixed.message", value: "This site has mixed encryption because some content is being served over unencrypted connections.", comment: "This site has mixed encryption because some content is being served over unencrypted connections. Encrypted connections prevent eavesdropping of personal information you send to websites.")
    public static let ppEncryptionForcedMessage = NSLocalizedString("privacy.protection.encryption.forced.message", value: "We’ve forced this site to use an encrypted connection, preventing eavesdropping of any personal information you send to it.", comment: "We've forced this site to use an encrypted connection, preventing eavesdropping of any personal information you send to it.")
    
    public static let ppEncryptionEncryptedHeading = NSLocalizedString("privacy.protection.encryption.encrypted.heading", value: "Encrypted Connection", comment: "Encrypted")
    public static let ppEncryptionForcedHeading = NSLocalizedString("privacy.protection.encryption.forced.heading", value: "Forced Encryption", comment: "Forced")
    public static let ppEncryptionMixedHeading = NSLocalizedString("privacy.protection.encryption.mixed.heading", value: "Mixed Encryption", comment: "Mixed")
    public static let ppEncryptionUnencryptedHeading = NSLocalizedString("privacy.protection.encryption.unencrypted.heading", value: "Unencrypted Connection", comment: "Unencrypted")
    
    public static let ppNetworkLeaderboard = NSLocalizedString("privacy.protection.network.leaderboard", value: "Tracker networks were found on %@ of web sites you’ve visited since %@.", comment: "Trackers networks were found on %@ of web sites you’ve visited since %@.")
    
    static let brokenSiteSectionTitle = NSLocalizedString("brokensite.sectionTitle", value: "DESCRIBE WHAT HAPPENED", comment: "Broken Site Section Title")
    
    static let brokenSiteCategoryImages = NSLocalizedString("brokensite.category.images", value: "Images didn’t load", comment: "Broken Site Category")
    static let brokenSiteCategoryPaywall = NSLocalizedString("brokensite.category.paywall", value: "The site asked me to disable", comment: "Broken Site Category")
    static let brokenSiteCategoryComments = NSLocalizedString("brokensite.category.comments", value: "Comments didn’t load", comment: "Broken Site Category")
    static let brokenSiteCategoryVideos = NSLocalizedString("brokensite.category.videos", value: "Video didn’t play", comment: "Broken Site Category")
    static let brokenSiteCategoryLinks = NSLocalizedString("brokensite.category.links", value: "Links or buttons don’t work", comment: "Broken Site Category")
    static let brokenSiteCategoryContent = NSLocalizedString("brokensite.category.content", value: "Content is missing", comment: "Broken Site Category")
    static let brokenSiteCategoryLogin = NSLocalizedString("brokensite.category.login", value: "I can’t login", comment: "Broken Site Category")
    static let brokenSiteCategoryUnsupported = NSLocalizedString("brokensite.category.unsupported", value: "The browser is incompatible", comment: "Broken Site Category")
    static let brokenSiteCategoryOther = NSLocalizedString("brokensite.category.other", value: "Something else", comment: "Broken Site Category")
    
    public static let unknownErrorOccurred = NSLocalizedString("unknown.error.occurred", value: "An unknown error occured", comment: "Unknown error occurred")
    
    public static let homeRowReminderTitle = NSLocalizedString("home.row.reminder.title", value: "Take DuckDuckGo home", comment: "Home Row Reminder Title")
    public static let homeRowReminderMessage = NSLocalizedString("home.row.reminder.message", value: "Add DuckDuckGo to your dock for easy access!", comment: "Home Row Reminder Message")
    
    public static let homeRowOnboardingHeader = NSLocalizedString("home.row.onboarding.header", value: "Add DuckDuckGo to your home screen!", comment: "Home Row onboarding Header")
    
    public static let feedbackSumbittedConfirmation = NSLocalizedString("feedback.submitted.confirmation", value: "Thank You! Feedback submitted.", comment: "Feedback submitted confirmation")
    
    public static let customUrlSchemeTitle = NSLocalizedString("prompt.custom.url.scheme.title", value: "Open in Another App?", comment: "Switch apps?")
    public static func forCustomUrlSchemePrompt(url: URL) -> String {
        let message = NSLocalizedString("prompt.custom.url.scheme.prompt", comment: "Would you like to open this URL... ")
        return message.format(arguments: url.absoluteString)
    }
    public static let customUrlSchemeOpen = NSLocalizedString("prompt.custom.url.scheme.open", value: "Yes", comment: "Open custom url button")
    public static let customUrlSchemeDontOpen = NSLocalizedString("prompt.custom.url.scheme.dontopen", value: "No", comment: "Don't open custom url button")
    
    public static let failedToOpenExternally = NSLocalizedString("open.externally.failed", value: "Sorry, no app can handle that link.", comment: "Don't open custom url button")
    
    public static let sectionTitleBookmarks = NSLocalizedString("section.title.bookmarks", value: "Bookmarks", comment: "Bookmarks section title")
    public static let sectionTitleFavorites = NSLocalizedString("section.title.favorites", value: "Favorites", comment: "Favorites section title")
    
    public static let favoriteMenuDelete = NSLocalizedString("favorite.menu.delete", value: "Delete", comment: "Favorite menu: delete")
    public static let favoriteMenuEdit = NSLocalizedString("favorite.menu.edit", value: "Edit", comment: "Favorite menu: edit")
    
    public static let emptyBookmarks = NSLocalizedString("empty.bookmarks", value: "No bookmarks yet", comment: "No bookmarks")
    public static let emptyFavorites = NSLocalizedString("empty.favorites", value: "No favorites yet", comment: "No favorites")
    
    public static let bookmarkTitlePlaceholder = NSLocalizedString("bookmark.title.placeholder", value: "Website title", comment: "Bookmark Title Placeholder")
    public static let bookmarkAddressPlaceholder = NSLocalizedString("bookmark.address.placeholder", value: "www.example.com", comment: "Bookmark Address Placeholder")
    
    public static let findInPage = NSLocalizedString("findinpage.title", value: "Find in Page", comment: "Find in Page")
    public static let findInPageCount = NSLocalizedString("findinpage.count", value: "%1$d of %2$d", comment: "%d of %d")
    
    public static let keyCommandShowAllTabs = NSLocalizedString("keyCommandShowAllTabs", value: "Show All Tabs", comment: "Show all tabs")
    public static let keyCommandNewTab = NSLocalizedString("keyCommandNewTab", value: "New Tab", comment: "New tab")
    public static let keyCommandCloseTab = NSLocalizedString("keyCommandCloseTab", value: "Close Tab", comment: "Close tab")
    public static let keyCommandNextTab = NSLocalizedString("keyCommandNextTab", value: "Next Tab", comment: "Next tab")
    public static let keyCommandPreviousTab = NSLocalizedString("keyCommandPreviousTab", value: "Previous Tab", comment: "Previous tab")
    public static let keyCommandBrowserForward = NSLocalizedString("keyCommandBrowserForward", value: "Browse Forward", comment: "Browse forward")
    public static let keyCommandBrowserBack = NSLocalizedString("keyCommandBrowserBack", value: "Browse Back", comment: "Browse back")
    public static let keyCommandFind = NSLocalizedString("keyCommandFind", value: "Find in Page", comment: "Find in page")
    public static let keyCommandLocation = NSLocalizedString("keyCommandLocation", value: "Search or Enter Address", comment: "Search or enter address")
    public static let keyCommandFire = NSLocalizedString("keyCommandFire", value: "Clear All Tabs and Data", comment: "Clear all tabs and data")
    public static let keyCommandClose = NSLocalizedString("keyCommandClose", value: "Close", comment: "Close")
    public static let keyCommandSelect = NSLocalizedString("keyCommandSelect", value: "Select", comment: "Select")
    public static let keyCommandFindNext = NSLocalizedString("keyCommandFindNext", value: "Find Next", comment: "Find next")
    public static let keyCommandFindPrevious = NSLocalizedString("keyCommandFindPrevious", value: "Find Previous", comment: "Find previous")
    public static let keyCommandReload = NSLocalizedString("keyCommandReload", value: "Reload", comment: "Reload")
    public static let keyCommandPrint = NSLocalizedString("keyCommandPrint", value: "Print", comment: "Print")
    public static let keyCommandAddBookmark = NSLocalizedString("keyCommandAddBookmark", value: "Add Bookmark", comment: "Add Bookmark")
    public static let keyCommandAddFavorite = NSLocalizedString("keyCommandAddFavorite", value: "Add Favorite", comment: "Add Favorite")
    public static let keyCommandOpenInNewTab = NSLocalizedString("keyCommandOpenInNewTab", value: "Open Link in New Tab", comment: "Open in new tab")
    public static let keyCommandOpenInNewBackgroundTab = NSLocalizedString("keyCommandOpenInNewBackgroundTab", value: "Open Link in Background", comment: "Open in background")
    
    public static let contextualOnboardingSearchPrivately = NSLocalizedString("contextualOnboardingSearchPrivately", value: "Your searches are always private on DuckDuckGo.", comment: "Searching with DuckDuckGo means your searches are never tracked. Ever.")
    public static let contextualOnboardingCustomizeTheme = NSLocalizedString("contextualOnboardingCustomizeTheme", value: "Want a different look? Try changing the theme!", comment: "Want a different look? Try changing current theme!")
    public static let contextualOnboardingPrivacyGrade = NSLocalizedString("contextualOnboardingPrivacyGrade", value: "DuckDuckGo enhances your privacy as you browse. Tap the privacy grade icon to learn how.", comment: "DuckDuckGo enhances your privacy as you browse. Tap the privacy grade icon to learn how.")
    public static let contextualOnboardingFireButton = NSLocalizedString("contextualOnboardingFireButton", value: "Tap the flame icon to erase your tabs and browsing data, or make it automatic in settings.", comment: "Tap the flame icon to erase your tabs and browsing data, or make it automatic in settings.")
    
    public static let bookmarkAllTabsSaved = NSLocalizedString("bookmarkAll.tabs.saved", value: "All tabs bookmarked", comment: "All open tabs are bookmarked")
    public static let bookmarkAllTabsFailedToSave = NSLocalizedString("bookmarkAll.tabs.failed", value: "Unable to bookmark some tabs", comment: "Failed to bookmark %lu out of %lu tabs")
    
    public static let themeNameDefault = NSLocalizedString("theme.name.default", value: "System Default", comment: "System Default")
    public static let themeNameLight = NSLocalizedString("theme.name.light", value: "Light", comment: "Light")
    public static let themeNameDark = NSLocalizedString("theme.name.dark", value: "Dark", comment: "Dark")
    
    public static let themeAccessoryDefault = NSLocalizedString("theme.acc.default", value: "System", comment: "System")
    public static let themeAccessoryLight = NSLocalizedString("theme.acc.light", value: "Light", comment: "Light")
    public static let themeAccessoryDark = NSLocalizedString("theme.acc.dark", value: "Dark", comment: "Dark")
    
    public static let autoClearAccessoryOn = NSLocalizedString("autoclear.on", value: "On", comment: "On")
    public static let autoClearAccessoryOff = NSLocalizedString("autoclear.off", value: "Off", comment: "Off")
    
    public static let homePageNavigationBar = NSLocalizedString("homepage.navigationBar", value: "Top", comment: "Navigation Bar Search")
    
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

    public static let openHomeTab = NSLocalizedString("tab.open.home", value: "Open home tab", comment: "Open home tab")
    public static let closeHomeTab = NSLocalizedString("tab.close.home", value: "Close home tab", comment: "Close home tab")

    public static func closeTab(withTitle title: String, atAddress address: String) -> String {
        let message = NSLocalizedString("tab.close.with.title.and.address", comment: "Close tab with address")
        return message.format(arguments: title, address)
    }
    
    public static let favorite = NSLocalizedString("favorite", value: "Favorite", comment: "Favorite")
    
    public static let onboardingWelcomeHeader = NSLocalizedString("onboardingWelcomeHeader", value: "Welcome to DuckDuckGo!", comment: "Welcome to DuckDuckGo!")
    public static let onboardingContinue = NSLocalizedString("onboardingContinue", value: "Continue", comment: "Continue")
    public static let onboardingSkip = NSLocalizedString("onboardingSkip", value: "Skip", comment: "Skip")
    public static let onboardingStartBrowsing = NSLocalizedString("onboardingStartBrowsing", value: "Start Browsing", comment: "Start browsing")
    public static let onboardingSetAppIcon = NSLocalizedString("onboardingSetAppIcon", value: "Set App Icon", comment: "Set App Icon")
    public static let onboardingNotificationsAccept = NSLocalizedString("onboardingNotificationsAccept", value: "Turn on Notifications", comment: "Turn on Notifications")
    public static let onboardingNotificationsDeny = NSLocalizedString("onboardingNotificationsDeny", value: "Not now", comment: "Not now")
    
    public static let preserveLoginsSwitchTitle = NSLocalizedString("preserveLogins.switch.title", value: "Ask to Fireproof Websites", comment: "Ask to Fireproof Websites")
    
    public static let preserveLoginsListTitle = NSLocalizedString("preserveLogins.domain.list.title", value: "Websites", comment: "Websites")
    public static let preserveLoginsListFooter = NSLocalizedString("preserveLogins.domain.list.footer", value: "Websites rely on cookies to keep you signed in. When you Fireproof a site, cookies won’t be erased and you’ll stay signed in, even after using the Fire Button.", comment: "Websites rely on cookies ...")
    public static let preserveLoginsRemoveAll = NSLocalizedString("preserveLogins.remove.all", value: "Remove All", comment: "Remove All")
    public static let preserveLoginsRemoveAllOk = NSLocalizedString("preserveLogins.remove.all.ok", value: "OK", comment: "OK")
    
    public static let preserveLoginsFireproofAsk = NSLocalizedString("preserveLogins.fireproof.message", value: "Would you like to Fireproof %@?", comment: "Would you like to Fireproof %@?")
    public static let preserveLoginsFireproofConfirm = NSLocalizedString("preserveLogins.menu.confirm", value: "Fireproof Website", comment: "Fireproof Website")
    public static let preserveLoginsFireproofDefer = NSLocalizedString("preserveLogins.menu.defer", value: "Not Now", comment: "Not Now")
    
    public static let preserveLoginsToast = NSLocalizedString("preserveLogins.toast", value: "%@ is now Fireproof! Visit settings to remove.", comment: "%@ is now Fireproof! Visit settings to remove.")
    
    public static let homeTabSearchAndFavorites = NSLocalizedString("homeTab.searchAndFavorites", value: "Search and favorites in a new tab", comment: "Home tab search and favorites")
    public static let homeTabTitle = NSLocalizedString("homeTab.title", value: "Home", comment: "Home tab title")
    
    public static let daxDialogHomeInitial = NSLocalizedString("dax.onboarding.home.initial", value: "Next, try visiting one of your favorite sites!nnI’ll block trackers so they can’t spy on you. I’ll also upgrade the security of your connection if possible. 🔒", comment: "Next, try visiting one of your favorite sites!")
    public static let daxDialogHomeSubsequent = NSLocalizedString("dax.onboarding.home.subsequent", value: "You’ve got this!nnRemember: every time you browse with me a creepy ad loses its wings. 👍", comment: "You’ve got this!")
    
    public static let daxDialogBrowsingAfterSearch = NSLocalizedString("dax.onboarding.browsing.after.search", value: "Your DuckDuckGo searches are anonymous and I never store your search history.  Ever. 🙌", comment: "Your DuckDuckGo searches are anonymous...")
    public static let daxDialogBrowsingAfterSearchCTA = NSLocalizedString("dax.onboarding.browsing.after.search.cta", value: "Phew!", comment: "Phew!")
    
    public static let daxDialogBrowsingWithoutTrackers = NSLocalizedString("dax.onboarding.browsing.without.trackers", value: "As you tap and scroll, I’ll block pesky trackers.nnGo ahead - keep browsing!", comment: "As you tap and scroll, I'll block pesky trackers.")
    public static let daxDialogBrowsingWithoutTrackersCTA = NSLocalizedString("dax.onboarding.browsing.without.trackers.cta", value: "Got It", comment: "Got It")
    
    public static let daxDialogBrowsingSiteIsMajorTracker = NSLocalizedString("dax.onboarding.browsing.site.is.major.tracker", value: "Heads up! %1$@ is a major tracking network.nnTheir trackers lurk on about %2$.0lf%% of top sites 😱 but don’t worry!nnI’ll block %1$@ from seeing your activity on those sites.", comment: "Heads up! %1$@ is a major tracking network.")
    public static let daxDialogBrowsingSiteIsMajorTrackerCTA = NSLocalizedString("dax.onboarding.browsing.site.is.major.tracker.cta", value:  "Got It", comment: "Got It")
    
    public static let daxDialogBrowsingSiteOwnedByMajorTracker = NSLocalizedString("dax.onboarding.browsing.site.owned.by.major.tracker", value: "Heads up! %1$@ is owned by %2$@.nn%2$@’s trackers lurk on about %3$.0lf%% of top websites 😱 but don’t worry!nnI’ll block %2$@ from seeing your activity on those sites.", comment: "Heads up! %1$@ is owned by %2$@.")
    public static let daxDialogBrowsingSiteOwnedByMajorTrackerCTA = NSLocalizedString("dax.onboarding.browsing.site.owned.by.major.tracker.cta", value: "Got It", comment: "Got It")
    
    public static let daxDialogBrowsingWithOneTracker = NSLocalizedString("dax.onboarding.browsing.one.tracker", value: "*%1$@* was trying to track you here.nnI blocked them!nn☝️ You can check the URL bar to see who is trying to track you when you visit a new site.", comment: "*%1$@* was trying to track you here.")
    public static let daxDialogBrowsingWithOneTrackerCTA = NSLocalizedString("dax.onboarding.browsing.one.tracker.cta", value: "High Five!", comment: "High Five!")
    
    public static let daxDialogBrowsingWithTwoTrackers = NSLocalizedString("dax.onboarding.browsing.two.trackers", value: "*%1$@ and %2$@* were trying to track you here.nnI blocked them!nn☝️ You can check the URL bar to see who is trying to track you when you visit a new site.", comment: "*%1$@ and %2$@* were trying to track you here.")
    public static let daxDialogBrowsingWithTwoTrackersCTA = NSLocalizedString("dax.onboarding.browsing.two.trackers.cta", value: "High Five!", comment: "High Five!")
    
    public static let daxDialogBrowsingWithMultipleTrackers = NSLocalizedString("dax.onboarding.browsing.multiple.trackers", value: "*%1$@, %2$@* and *1 other* were trying to track you here.nnI blocked them!nn☝️ You can check the URL bar to see who is trying to track you when you visit a new site.", comment: "*%1$@, %2$@* and *1 other* were trying to track you here.")
    public static let daxDialogBrowsingWithMultipleTrackersPlural = NSLocalizedString("dax.onboarding.browsing.multiple.trackers.plural", value: "*%1$@, %2$@* and *%3$d others* were trying to track you here.nnI blocked them!nn☝️ You can check the URL bar to see who is trying to track you when you visit a new site.", comment: "*%1$@, %2$@* and *%3$d others* were trying to track you here.")
    public static let daxDialogBrowsingWithMultipleTrackersCTA = NSLocalizedString("dax.onboarding.browsing.multiple.trackers.cta" , value: "High Five!", comment: "High Five!")
    
    public static let daxDialogOnboardingMessage = NSLocalizedString("dax.onboarding.message", value: "The Internet can be kinda creepy.nnNot to worry! Searching and browsing privately is easier than you think.", comment: "The Internet can be kinda creepy.")
    
    public static let daxDialogHideTitle = NSLocalizedString("dax.hide.title", value: "Hide remaining tips?", comment: "Hide remaining tips?")
    public static let daxDialogHideMessage = NSLocalizedString("dax.hide.message", value: "There are only a few, and we tried to make them informative.", comment: "There are only a few, and we tried to make them informative.")
    public static let daxDialogHideButton = NSLocalizedString("dax.hide.button", value: "Hide tips forever", comment: "Hide tips forever")
    public static let daxDialogHideCancel = NSLocalizedString("dax.hide.cancel", value: "Cancel", comment: "Cancel")
}
